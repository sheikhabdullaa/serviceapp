// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Login/logout state۔
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Email verification سمیت user changes۔
  Stream<User?> get userChanges => _auth.userChanges();

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  // ========================================================
  // REGISTER
  // ========================================================

  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
    required String role,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final normalizedRole = role.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Please enter your email address.',
      );
    }

    if (password.length < 6) {
      throw FirebaseAuthException(
        code: 'weak-password',
        message: 'Password must contain at least 6 characters.',
      );
    }

    if (normalizedRole != 'user' && normalizedRole != 'provider') {
      throw FirebaseAuthException(
        code: 'invalid-role',
        message: 'Please select User or Provider role.',
      );
    }

    UserCredential? credential;

    try {
      /*
       * Firebase Authentication account create ہوگا۔
       */
      credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-creation-failed',
          message: 'Firebase account could not be created.',
        );
      }

      /*
       * Normal user کی profile signup پر complete
       * مانی جائے گی۔
       *
       * Provider کو مزید profile، ID card اور
       * service details دینی ہیں۔
       */
      final bool profileCompleted = normalizedRole == 'user';

      try {
        await _users.doc(user.uid).set({
          'uid': user.uid,
          'email': normalizedEmail,
          'name': '',
          'whatsapp': '',
          'role': normalizedRole,
          'emailVerified': false,
          'profileCompleted': profileCompleted,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (error) {
        /*
         * Firestore account document نہ بنے تو
         * incomplete Auth account delete کریں۔
         */
        try {
          await user.delete();
        } catch (_) {}

        rethrow;
      }

      /*
       * Gmail verification link۔
       * یہ passwordless sign-in link نہیں ہے۔
       */
      await user.sendEmailVerification();

      return credential;
    } on FirebaseAuthException {
      rethrow;
    } on FirebaseException catch (error) {
      throw FirebaseAuthException(
        code: error.code,
        message: error.message ?? 'Could not save account information.',
      );
    } catch (error) {
      throw FirebaseAuthException(
        code: 'registration-failed',
        message: 'Could not complete registration: $error',
      );
    }
  }

  // ========================================================
  // LOGIN
  // ========================================================

  Future<UserCredential> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Please enter your email address.',
      );
    }

    if (password.isEmpty) {
      throw FirebaseAuthException(
        code: 'empty-password',
        message: 'Please enter your password.',
      );
    }

    final credential = await _auth.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    /*
     * Firebase server سے latest verification
     * status حاصل کریں۔
     */
    await credential.user?.reload();

    return credential;
  }

  // ========================================================
  // EMAIL VERIFICATION
  // ========================================================

  Future<bool> checkEmailVerification() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Your session has expired. Please login again.',
      );
    }

    await user.reload();

    final refreshedUser = _auth.currentUser;

    if (refreshedUser == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Your session has expired. Please login again.',
      );
    }

    final bool verified = refreshedUser.emailVerified;

    if (verified) {
      await _users.doc(refreshedUser.uid).set({
        'emailVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      /*
       * Current Firebase token refresh کریں۔
       */
      await refreshedUser.getIdToken(true);
    }

    return verified;
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Please login again before resending the verification email.',
      );
    }

    await user.reload();

    final refreshedUser = _auth.currentUser;

    if (refreshedUser == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Your session has expired. Please login again.',
      );
    }

    if (refreshedUser.emailVerified) {
      await _users.doc(refreshedUser.uid).set({
        'emailVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      throw FirebaseAuthException(
        code: 'email-already-verified',
        message: 'Your email is already verified.',
      );
    }

    await refreshedUser.sendEmailVerification();
  }

  // ========================================================
  // USER ACCOUNT INFORMATION
  // ========================================================

  Future<DocumentSnapshot<Map<String, dynamic>>>
      getCurrentUserDocument() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Your session has expired. Please login again.',
      );
    }

    return _users.doc(user.uid).get();
  }

  Future<String?> getCurrentUserRole() async {
    final document = await getCurrentUserDocument();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return (document.data()?['role'] as String?)?.trim().toLowerCase();
  }

  Future<bool> isCurrentUserProfileCompleted() async {
    final document = await getCurrentUserDocument();

    if (!document.exists || document.data() == null) {
      return false;
    }

    final data = document.data()!;

    final role = (data['role'] as String? ?? 'user').trim().toLowerCase();

    /*
     * پرانے normal user document میں field نہ ہو
     * تو true مانی جائے گی۔
     */
    return data['profileCompleted'] as bool? ?? role == 'user';
  }

  Future<void> updateCurrentUserFields(
    Map<String, dynamic> data,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Your session has expired. Please login again.',
      );
    }

    await _users.doc(user.uid).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> markProfileCompleted({
    bool completed = true,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Your session has expired. Please login again.',
      );
    }

    await _users.doc(user.uid).set({
      'profileCompleted': completed,
      'emailVerified': user.emailVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ========================================================
  // PASSWORD RESET
  // ========================================================

  Future<void> sendPasswordResetEmail(
    String email,
  ) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Please enter your email address.',
      );
    }

    await _auth.sendPasswordResetEmail(
      email: normalizedEmail,
    );
  }

  // ========================================================
  // RELOAD AND LOGOUT
  // ========================================================

  Future<User?> reloadCurrentUser() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    await user.reload();

    return _auth.currentUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
