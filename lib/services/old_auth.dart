// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class OldAuthService {
//   OldAuthService._();

//   static final OldAuthService instance = OldAuthService._();

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Stream<User?> get authStateChanges => _auth.authStateChanges();

//   /// Token اور email verification changes
//   Stream<User?> get userChanges => _auth.userChanges();

//   /// Current Firebase user
//   User? get currentUser => _auth.currentUser;

//   /// Current user logged in ہے یا نہیں
//   bool get isLoggedIn => _auth.currentUser != null;

//   /// Email/password کے ذریعے نیا account بنائیں۔
//   Future<UserCredential> registerWithEmailPassword({
//     required String email,
//     required String password,
//     required String role,
//   }) async {
//     final normalizedEmail = email.trim().toLowerCase();

//     final normalizedRole = role.trim().toLowerCase();

//     if (normalizedEmail.isEmpty) {
//       throw FirebaseAuthException(
//         code: 'invalid-email',
//         message: 'Please enter your email address.',
//       );
//     }

//     if (password.length < 6) {
//       throw FirebaseAuthException(
//         code: 'weak-password',
//         message: 'Password must contain at least 6 characters.',
//       );
//     }

//     if (normalizedRole != 'user' && normalizedRole != 'provider') {
//       throw FirebaseAuthException(
//         code: 'invalid-role',
//         message: 'Please select user or provider role.',
//       );
//     }

//     UserCredential? credential;

//     try {
//       /*
//        * Firebase Authentication account create ہوگا۔
//        * Account create ہونے کے بعد user automatically
//        * login بھی ہو جاتا ہے۔
//        */
//       credential = await _auth.createUserWithEmailAndPassword(
//         email: normalizedEmail,
//         password: password,
//       );

//       final user = credential.user;

//       if (user == null) {
//         throw FirebaseAuthException(
//           code: 'user-creation-failed',
//           message: 'Firebase account could not be created.',
//         );
//       }

//       /*
//        * User role Firestore میں save ہوگا۔
//        *
//        * Normal user کو additional provider profile
//        * complete نہیں کرنی، اس لیے true ہوگا۔
//        *
//        * Provider کو CNIC، service اور باقی details
//        * دینی ہیں، اس لیے false ہوگا۔
//        */
//       await _firestore.collection('users').doc(user.uid).set({
//         'uid': user.uid,
//         'email': normalizedEmail,
//         'role': normalizedRole,
//         'emailVerified': false,
//         'profileCompleted': normalizedRole == 'user',
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       /*
//        * Gmail پر email verification link بھیجیں۔
//        * یہ passwordless login link نہیں ہے۔
//        */
//       await user.sendEmailVerification();

//       return credential;
//     } on FirebaseAuthException {
//       rethrow;
//     } on FirebaseException catch (e) {
//       /*
//        * Firestore document save نہ ہو تو incomplete
//        * Firebase Authentication account delete کریں۔
//        */
//       final createdUser = credential?.user;

//       if (createdUser != null) {
//         try {
//           await createdUser.delete();
//         } catch (_) {
//           // Original Firebase error برقرار رہے گا۔
//         }
//       }

//       throw FirebaseAuthException(
//         code: e.code,
//         message: e.message ?? 'Could not save user information.',
//       );
//     } catch (e) {
//       final createdUser = credential?.user;

//       if (createdUser != null) {
//         try {
//           await createdUser.delete();
//         } catch (_) {
//           // Original error برقرار رہے گا۔
//         }
//       }

//       throw FirebaseAuthException(
//         code: 'registration-failed',
//         message: 'Could not create account: $e',
//       );
//     }
//   }

//   /// Email/password کے ذریعے login
//   Future<UserCredential> loginWithEmailPassword({
//     required String email,
//     required String password,
//   }) async {
//     final normalizedEmail = email.trim().toLowerCase();

//     if (normalizedEmail.isEmpty) {
//       throw FirebaseAuthException(
//         code: 'invalid-email',
//         message: 'Please enter your email address.',
//       );
//     }

//     if (password.isEmpty) {
//       throw FirebaseAuthException(
//         code: 'empty-password',
//         message: 'Please enter your password.',
//       );
//     }

//     final credential = await _auth.signInWithEmailAndPassword(
//       email: normalizedEmail,
//       password: password,
//     );

//     /*
//      * Firebase server سے latest emailVerified
//      * status load کریں۔
//      */
//     await credential.user?.reload();

//     return credential;
//   }

//   /// Current user کا latest verification status
//   Future<bool> checkEmailVerification() async {
//     final user = _auth.currentUser;

//     if (user == null) {
//       throw FirebaseAuthException(
//         code: 'no-current-user',
//         message: 'Please login again.',
//       );
//     }

//     // Firebase server سے latest user data لیں۔
//     await user.reload();

//     final refreshedUser = _auth.currentUser;

//     if (refreshedUser == null) {
//       throw FirebaseAuthException(
//         code: 'no-current-user',
//         message: 'Please login again.',
//       );
//     }

//     final verified = refreshedUser.emailVerified;

//     /*
//      * Email verify ہو گئی ہو تو Firestore میں بھی
//      * verification status update کریں۔
//      */
//     if (verified) {
//       await _firestore.collection('users').doc(refreshedUser.uid).set({
//         'emailVerified': true,
//         'updatedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));

//       /*
//        * Auth state listeners کو updated user ملے گا۔
//        */
//       await refreshedUser.getIdToken(true);
//     }

//     return verified;
//   }

//   /// Verification email دوبارہ بھیجیں
//   Future<void> resendVerificationEmail() async {
//     final user = _auth.currentUser;

//     if (user == null) {
//       throw FirebaseAuthException(
//         code: 'no-current-user',
//         message: 'Please login again before resending the link.',
//       );
//     }

//     await user.reload();

//     final refreshedUser = _auth.currentUser;

//     if (refreshedUser == null) {
//       throw FirebaseAuthException(
//         code: 'no-current-user',
//         message: 'Please login again.',
//       );
//     }

//     if (refreshedUser.emailVerified) {
//       await _firestore.collection('users').doc(refreshedUser.uid).set({
//         'emailVerified': true,
//         'updatedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));

//       throw FirebaseAuthException(
//         code: 'email-already-verified',
//         message: 'Your email is already verified.',
//       );
//     }

//     await refreshedUser.sendEmailVerification();
//   }

//   /// Current user کا Firestore document
//   Future<DocumentSnapshot<Map<String, dynamic>>>
//       getCurrentUserDocument() async {
//     final user = _auth.currentUser;

//     if (user == null) {
//       throw FirebaseAuthException(
//         code: 'no-current-user',
//         message: 'Please login again.',
//       );
//     }

//     return _firestore.collection('users').doc(user.uid).get();
//   }

//   /// Current user کا role load کریں
//   Future<String?> getCurrentUserRole() async {
//     final document = await getCurrentUserDocument();

//     if (!document.exists) return null;

//     final data = document.data();

//     return (data?['role'] as String?)?.trim().toLowerCase();
//   }

//   /// Provider profile complete ہے یا نہیں
//   Future<bool> isCurrentUserProfileCompleted() async {
//     final document = await getCurrentUserDocument();

//     if (!document.exists) return false;

//     final data = document.data();

//     return data?['profileCompleted'] as bool? ?? false;
//   }

//   /// Provider profile complete ہونے کے بعد call کریں
//   Future<void> markProfileCompleted() async {
//     final user = _auth.currentUser;

//     if (user == null) {
//       throw FirebaseAuthException(
//         code: 'no-current-user',
//         message: 'Please login again.',
//       );
//     }

//     await _firestore.collection('users').doc(user.uid).set({
//       'profileCompleted': true,
//       'emailVerified': user.emailVerified,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   /// Password reset email بھیجیں
//   Future<void> sendPasswordResetEmail(
//     String email,
//   ) async {
//     final normalizedEmail = email.trim().toLowerCase();

//     if (normalizedEmail.isEmpty) {
//       throw FirebaseAuthException(
//         code: 'invalid-email',
//         message: 'Please enter your email address.',
//       );
//     }

//     await _auth.sendPasswordResetEmail(
//       email: normalizedEmail,
//     );
//   }

//   /// Current Firebase user کو reload کریں
//   Future<User?> reloadCurrentUser() async {
//     final user = _auth.currentUser;

//     if (user == null) return null;

//     await user.reload();

//     return _auth.currentUser;
//   }

//   /// Logout
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }
// }
