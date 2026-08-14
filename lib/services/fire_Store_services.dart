// // ignore_for_file: file_names

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:service_hub/model/model.dart';

// import '../theme/app_theme.dart';

// class FirestoreService {
//   FirestoreService._();

//   static final FirestoreService instance = FirestoreService._();

//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // =========================================================
//   // USERS COLLECTION
//   // users/{uid}
//   // =========================================================

//   /// کسی user کا Firestore document load کریں۔
//   Future<AppUser?> getUser(String uid) async {
//     if (uid.trim().isEmpty) return null;

//     final document = await _db.collection(Col.users).doc(uid).get();

//     if (!document.exists || document.data() == null) {
//       return null;
//     }

//     return AppUser.fromDoc(document);
//   }

//   /// Current logged-in user load کریں۔
//   Future<AppUser?> getCurrentUser() async {
//     final firebaseUser = _auth.currentUser;

//     if (firebaseUser == null) return null;

//     return getUser(firebaseUser.uid);
//   }

//   /// User document realtime watch کریں۔
//   Stream<AppUser?> watchUser(String uid) {
//     if (uid.trim().isEmpty) {
//       return Stream<AppUser?>.value(null);
//     }

//     return _db.collection(Col.users).doc(uid).snapshots().map((document) {
//       if (!document.exists || document.data() == null) {
//         return null;
//       }

//       return AppUser.fromDoc(document);
//     });
//   }

//   /// نیا user document create/update کریں۔
//   ///
//   /// merge:true رکھنے سے پہلے سے موجود fields
//   /// delete نہیں ہوں گی۔
//   Future<void> createUser(AppUser user) async {
//     await _db.collection(Col.users).doc(user.uid).set(
//           user.toMap(),
//           SetOptions(merge: true),
//         );
//   }

//   /// Signup کے بعد basic account document بنانے کے لیے۔
//   ///
//   /// Normal user:
//   /// profileCompleted = true
//   ///
//   /// Provider:
//   /// profileCompleted = false
//   Future<void> createAccountDocument({
//     required String uid,
//     required String email,
//     required String role,
//   }) async {
//     final normalizedUid = uid.trim();
//     final normalizedEmail = email.trim().toLowerCase();
//     final normalizedRole = role.trim().toLowerCase();

//     if (normalizedUid.isEmpty) {
//       throw ArgumentError(
//         'User uid cannot be empty.',
//       );
//     }

//     if (normalizedRole != 'user' && normalizedRole != 'provider') {
//       throw ArgumentError(
//         'Role must be user or provider.',
//       );
//     }

//     await _db.collection(Col.users).doc(normalizedUid).set({
//       'uid': normalizedUid,
//       'email': normalizedEmail,
//       'role': normalizedRole,
//       'emailVerified': false,

//       // User کو provider profile نہیں بنانی۔
//       'profileCompleted': normalizedRole == 'user',

//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   /// User کا role حاصل کریں۔
//   Future<String?> getUserRole(String uid) async {
//     if (uid.trim().isEmpty) return null;

//     final document = await _db.collection(Col.users).doc(uid).get();

//     if (!document.exists) return null;

//     final role = document.data()?['role'] as String?;

//     return role?.trim().toLowerCase();
//   }

//   /// Current user کا role حاصل کریں۔
//   Future<String?> getCurrentUserRole() async {
//     final firebaseUser = _auth.currentUser;

//     if (firebaseUser == null) return null;

//     return getUserRole(firebaseUser.uid);
//   }

//   /// Email verification status Firestore میں update کریں۔
//   Future<void> updateEmailVerification({
//     required String uid,
//     required bool emailVerified,
//   }) async {
//     if (uid.trim().isEmpty) {
//       throw ArgumentError(
//         'User uid cannot be empty.',
//       );
//     }

//     await _db.collection(Col.users).doc(uid).set({
//       'emailVerified': emailVerified,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   /// Provider profile completion status update کریں۔
//   Future<void> updateProfileCompletion({
//     required String uid,
//     required bool profileCompleted,
//   }) async {
//     if (uid.trim().isEmpty) {
//       throw ArgumentError(
//         'User uid cannot be empty.',
//       );
//     }

//     await _db.collection(Col.users).doc(uid).set({
//       'profileCompleted': profileCompleted,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   /// Current provider profile کو completed کریں۔
//   Future<void> markCurrentProfileCompleted() async {
//     final firebaseUser = _auth.currentUser;

//     if (firebaseUser == null) {
//       throw FirebaseAuthException(
//         code: 'no-current-user',
//         message: 'Please login again.',
//       );
//     }

//     await updateProfileCompletion(
//       uid: firebaseUser.uid,
//       profileCompleted: true,
//     );
//   }

//   /// User document میں کوئی fields safely update کریں۔
//   Future<void> updateUserFields({
//     required String uid,
//     required Map<String, dynamic> data,
//   }) async {
//     if (uid.trim().isEmpty) {
//       throw ArgumentError(
//         'User uid cannot be empty.',
//       );
//     }

//     await _db.collection(Col.users).doc(uid).set({
//       ...data,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   // =========================================================
//   // PROVIDERS COLLECTION
//   // providers/{uid}
//   // =========================================================

//   /// Provider کی information create یا update کریں۔
//   ///
//   /// یہ method profileCompleted خود true نہیں کرتی،
//   /// کیونکہ provider اپنی profile کئی steps میں بھی
//   /// save کر سکتا ہے۔
//   Future<void> createOrUpdateProvider(
//     ProviderProfile provider,
//   ) async {
//     if (provider.uid.trim().isEmpty) {
//       throw ArgumentError(
//         'Provider uid cannot be empty.',
//       );
//     }

//     await _db.collection(Col.providers).doc(provider.uid).set(
//           provider.toMap(),
//           SetOptions(merge: true),
//         );
//   }

//   /// Provider کی final profile save کریں اور users document
//   /// میں profileCompleted true کریں۔
//   ///
//   /// اسے Profile Preview کے Save Profile button پر call کریں۔
//   Future<void> saveCompletedProviderProfile(
//     ProviderProfile provider,
//   ) async {
//     if (provider.uid.trim().isEmpty) {
//       throw ArgumentError(
//         'Provider uid cannot be empty.',
//       );
//     }

//     final userReference = _db.collection(Col.users).doc(provider.uid);

//     final providerReference = _db.collection(Col.providers).doc(provider.uid);

//     /*
//      * WriteBatch استعمال کیا ہے تاکہ provider profile اور
//      * profileCompleted دونوں ایک ساتھ save ہوں۔
//      */
//     final batch = _db.batch();

//     batch.set(
//       providerReference,
//       {
//         ...provider.toMap(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       },
//       SetOptions(merge: true),
//     );

//     batch.set(
//       userReference,
//       {
//         'role': 'provider',
//         'profileCompleted': true,
//         'emailVerified': _auth.currentUser?.emailVerified ?? false,
//         'updatedAt': FieldValue.serverTimestamp(),
//       },
//       SetOptions(merge: true),
//     );

//     await batch.commit();
//   }

//   /// ایک provider profile load کریں۔
//   Future<ProviderProfile?> getProvider(
//     String uid,
//   ) async {
//     if (uid.trim().isEmpty) return null;

//     final document = await _db.collection(Col.providers).doc(uid).get();

//     if (!document.exists || document.data() == null) {
//       return null;
//     }

//     return ProviderProfile.fromDoc(document);
//   }

//   /// Current provider کی profile load کریں۔
//   Future<ProviderProfile?> getCurrentProvider() async {
//     final firebaseUser = _auth.currentUser;

//     if (firebaseUser == null) return null;

//     return getProvider(firebaseUser.uid);
//   }

//   /// Provider profile realtime watch کریں۔
//   Stream<ProviderProfile?> watchProvider(
//     String uid,
//   ) {
//     if (uid.trim().isEmpty) {
//       return Stream<ProviderProfile?>.value(null);
//     }

//     return _db.collection(Col.providers).doc(uid).snapshots().map((document) {
//       if (!document.exists || document.data() == null) {
//         return null;
//       }

//       return ProviderProfile.fromDoc(document);
//     });
//   }

//   /// Selected service کے live providers دکھائیں۔
//   ///
//   /// Firestore provider document میں fields:
//   /// service: Electrician
//   /// isLive: true
//   Stream<List<ProviderProfile>> watchProvidersForService(
//     String service,
//   ) {
//     final normalizedService = service.trim();

//     if (normalizedService.isEmpty) {
//       return Stream<List<ProviderProfile>>.value(
//         const [],
//       );
//     }

//     return _db
//         .collection(Col.providers)
//         .where(
//           'service',
//           isEqualTo: normalizedService,
//         )
//         .where(
//           'isLive',
//           isEqualTo: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs
//               .map(
//                 (document) => ProviderProfile.fromDoc(document),
//               )
//               .toList(),
//         );
//   }

//   /// تمام live providers load کریں۔
//   Stream<List<ProviderProfile>> watchAllLiveProviders() {
//     return _db
//         .collection(Col.providers)
//         .where(
//           'isLive',
//           isEqualTo: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs
//               .map(
//                 (document) => ProviderProfile.fromDoc(document),
//               )
//               .toList(),
//         );
//   }

//   /// Provider کو live یا offline کریں۔
//   Future<void> setLive(
//     String uid,
//     bool isLive,
//   ) async {
//     if (uid.trim().isEmpty) {
//       throw ArgumentError(
//         'Provider uid cannot be empty.',
//       );
//     }

//     await _db.collection(Col.providers).doc(uid).set({
//       'isLive': isLive,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   /// Provider profile کے views بڑھائیں۔
//   Future<void> incrementProfileViews(
//     String uid,
//   ) async {
//     await incrementCounter(
//       uid,
//       'totalViews',
//     );
//   }

//   /// Provider کے contacts/calls/WhatsApp count بڑھائیں۔
//   Future<void> incrementContacts(
//     String uid,
//   ) async {
//     await incrementCounter(
//       uid,
//       'totalContacts',
//     );
//   }

//   /// Provider کی booking count بڑھائیں۔
//   Future<void> incrementBookings(
//     String uid,
//   ) async {
//     await incrementCounter(
//       uid,
//       'totalBookings',
//     );
//   }

//   /// کسی allowed counter کو increment کریں۔
//   Future<void> incrementCounter(
//     String uid,
//     String field,
//   ) async {
//     if (uid.trim().isEmpty) {
//       throw ArgumentError(
//         'Provider uid cannot be empty.',
//       );
//     }

//     const allowedFields = {
//       'totalViews',
//       'totalContacts',
//       'totalBookings',
//     };

//     if (!allowedFields.contains(field)) {
//       throw ArgumentError(
//         'Invalid provider counter: $field',
//       );
//     }

//     await _db.collection(Col.providers).doc(uid).set({
//       field: FieldValue.increment(1),
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   // =========================================================
//   // BOOKINGS COLLECTION
//   // bookings/{bookingId}
//   // =========================================================

//   /// نئی booking/request create کریں۔
//   Future<DocumentReference<Map<String, dynamic>>> createBooking(
//     BookingRequest booking,
//   ) async {
//     final bookingReference = _db.collection(Col.bookings).doc();

//     final bookingData = booking.toMap();

//     await bookingReference.set({
//       ...bookingData,
//       'bookingId': bookingReference.id,
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     });

//     return bookingReference;
//   }

//   /// Provider کی bookings realtime load کریں۔
//   Stream<List<BookingRequest>> watchProviderBookings(
//     String providerId,
//   ) {
//     if (providerId.trim().isEmpty) {
//       return Stream<List<BookingRequest>>.value(
//         const [],
//       );
//     }

//     return _db
//         .collection(Col.bookings)
//         .where(
//           'providerId',
//           isEqualTo: providerId,
//         )
//         .orderBy(
//           'createdAt',
//           descending: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs
//               .map(
//                 (document) => BookingRequest.fromDoc(document),
//               )
//               .toList(),
//         );
//   }

//   /// Normal user کی booking requests realtime load کریں۔
//   Stream<List<BookingRequest>> watchUserBookings(
//     String userId,
//   ) {
//     if (userId.trim().isEmpty) {
//       return Stream<List<BookingRequest>>.value(
//         const [],
//       );
//     }

//     return _db
//         .collection(Col.bookings)
//         .where(
//           'userId',
//           isEqualTo: userId,
//         )
//         .orderBy(
//           'createdAt',
//           descending: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs
//               .map(
//                 (document) => BookingRequest.fromDoc(document),
//               )
//               .toList(),
//         );
//   }

//   /// Booking status update کریں۔
//   ///
//   /// Example statuses:
//   /// pending, accepted, completed, rejected
//   Future<void> updateBookingStatus({
//     required String bookingId,
//     required String status,
//   }) async {
//     final normalizedStatus = status.trim().toLowerCase();

//     const allowedStatuses = {
//       'pending',
//       'accepted',
//       'completed',
//       'rejected',
//       'cancelled',
//     };

//     if (bookingId.trim().isEmpty) {
//       throw ArgumentError(
//         'Booking id cannot be empty.',
//       );
//     }

//     if (!allowedStatuses.contains(normalizedStatus)) {
//       throw ArgumentError(
//         'Invalid booking status: $status',
//       );
//     }

//     await _db.collection(Col.bookings).doc(bookingId).update({
//       'status': normalizedStatus,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   /// Booking document delete کریں۔
//   Future<void> deleteBooking(
//     String bookingId,
//   ) async {
//     if (bookingId.trim().isEmpty) {
//       throw ArgumentError(
//         'Booking id cannot be empty.',
//       );
//     }

//     await _db.collection(Col.bookings).doc(bookingId).delete();
//   }
// }
