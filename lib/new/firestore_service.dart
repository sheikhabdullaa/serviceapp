// // ignore_for_file: file_names

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:service_hub/new/appuser.dart';

// class FirestoreService {
//   FirestoreService._();

//   static final FirestoreService instance = FirestoreService._();

//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   CollectionReference<Map<String, dynamic>> get _users =>
//       _db.collection('users');

//   CollectionReference<Map<String, dynamic>> get _providers =>
//       _db.collection('providers');

//   CollectionReference<Map<String, dynamic>> get _bookings =>
//       _db.collection('bookings');

//   User get _requiredFirebaseUser {
//     final user = _auth.currentUser;

//     if (user == null) {
//       throw FirebaseAuthException(
//         code: 'no-current-user',
//         message: 'Your session has expired. Please login again.',
//       );
//     }

//     return user;
//   }

//   // ========================================================
//   // USERS
//   // users/{uid}
//   // ========================================================

//   Future<AppUser?> getUser(String uid) async {
//     if (uid.trim().isEmpty) return null;

//     final document = await _users.doc(uid.trim()).get();

//     if (!document.exists || document.data() == null) {
//       return null;
//     }

//     return AppUser.fromDoc(document);
//   }

//   Future<AppUser?> getCurrentUser() async {
//     final user = _auth.currentUser;

//     if (user == null) return null;

//     return getUser(user.uid);
//   }

//   Stream<AppUser?> watchUser(String uid) {
//     if (uid.trim().isEmpty) {
//       return Stream<AppUser?>.value(null);
//     }

//     return _users.doc(uid.trim()).snapshots().map((document) {
//       if (!document.exists || document.data() == null) {
//         return null;
//       }

//       return AppUser.fromDoc(document);
//     });
//   }

//   Future<void> createOrUpdateUser(
//     AppUser user,
//   ) async {
//     await _users.doc(user.uid).set(
//           user.toMap(),
//           SetOptions(merge: true),
//         );
//   }

//   Future<void> updateUserFields({
//     required String uid,
//     required Map<String, dynamic> data,
//   }) async {
//     if (uid.trim().isEmpty) {
//       throw ArgumentError('UID cannot be empty.');
//     }

//     await _users.doc(uid.trim()).set({
//       ...data,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   Future<String?> getUserRole(
//     String uid,
//   ) async {
//     final user = await getUser(uid);

//     return user?.role.trim().toLowerCase();
//   }

//   Future<void> updateEmailVerification({
//     required String uid,
//     required bool verified,
//   }) async {
//     await updateUserFields(
//       uid: uid,
//       data: {
//         'emailVerified': verified,
//       },
//     );
//   }

//   Future<void> updateProfileCompletion({
//     required String uid,
//     required bool completed,
//   }) async {
//     await updateUserFields(
//       uid: uid,
//       data: {
//         'profileCompleted': completed,
//       },
//     );
//   }

//   // ========================================================
//   // PROVIDER PROFILE
//   // providers/{providerId}
//   // ========================================================

//   Future<ProviderProfile?> getProvider(
//     String providerId,
//   ) async {
//     if (providerId.trim().isEmpty) {
//       return null;
//     }

//     final document = await _providers.doc(providerId.trim()).get();

//     if (!document.exists || document.data() == null) {
//       return null;
//     }

//     return ProviderProfile.fromDoc(document);
//   }

//   Future<ProviderProfile?> getCurrentProvider() async {
//     final user = _auth.currentUser;

//     if (user == null) return null;

//     return getProvider(user.uid);
//   }

//   Stream<ProviderProfile?> watchProvider(
//     String providerId,
//   ) {
//     if (providerId.trim().isEmpty) {
//       return Stream<ProviderProfile?>.value(
//         null,
//       );
//     }

//     return _providers.doc(providerId.trim()).snapshots().map((document) {
//       if (!document.exists || document.data() == null) {
//         return null;
//       }

//       return ProviderProfile.fromDoc(document);
//     });
//   }

//   Future<void> createOrUpdateProvider(
//     ProviderProfile provider,
//   ) async {
//     if (provider.uid.trim().isEmpty) {
//       throw ArgumentError(
//         'Provider UID cannot be empty.',
//       );
//     }

//     await _providers.doc(provider.uid).set(
//           provider.toMap(),
//           SetOptions(merge: true),
//         );
//   }

//   /// Provider profile save کرکے users document میں
//   /// profileCompleted true کرتا ہے۔
//   Future<void> saveCompletedProviderProfile(
//     ProviderProfile provider,
//   ) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != provider.uid) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot update another provider profile.',
//       );
//     }

//     final providerReference = _providers.doc(provider.uid);

//     final userReference = _users.doc(provider.uid);

//     final batch = _db.batch();

//     batch.set(
//       providerReference,
//       {
//         ...provider.toMap(),
//         if (provider.createdAt == null)
//           'createdAt': FieldValue.serverTimestamp(),
//       },
//       SetOptions(merge: true),
//     );

//     batch.set(
//       userReference,
//       {
//         'uid': provider.uid,
//         'email': provider.email.trim().toLowerCase(),
//         'name': provider.name.trim(),
//         'whatsapp': provider.whatsapp.trim(),
//         'role': 'provider',
//         'emailVerified': firebaseUser.emailVerified,
//         'profileCompleted': true,
//         'updatedAt': FieldValue.serverTimestamp(),
//       },
//       SetOptions(merge: true),
//     );

//     await batch.commit();
//   }

//   Future<void> updateProviderFields({
//     required String providerId,
//     required Map<String, dynamic> data,
//     required String uid,
//   }) async {
//     if (providerId.trim().isEmpty) {
//       throw ArgumentError(
//         'Provider ID cannot be empty.',
//       );
//     }

//     await _providers.doc(providerId.trim()).set({
//       ...data,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   // ========================================================
//   // PROVIDER SERVICES
//   // providers/{providerId}/services/{serviceId}
//   // ========================================================

//   CollectionReference<Map<String, dynamic>> _servicesReference(
//     String providerId,
//   ) {
//     return _providers.doc(providerId).collection('services');
//   }

//   /// نئی provider service add کریں۔
//   Future<String> addProviderService(
//     ProviderService service,
//   ) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != service.providerId) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot add a service for another provider.',
//       );
//     }

//     final serviceReference = _servicesReference(service.providerId).doc();

//     await serviceReference.set({
//       ...service.toMap(),
//       'serviceId': serviceReference.id,
//       'providerId': service.providerId,
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     });

//     /*
//      * Provider document میں categories بھی رکھیں،
//      * تاکہ user-side searching آسان ہو۔
//      */
//     await _providers.doc(service.providerId).set({
//       'serviceCategories': FieldValue.arrayUnion([
//         service.category.trim(),
//       ]),
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));

//     return serviceReference.id;
//   }

//   /// موجودہ service update کریں۔
//   Future<void> updateProviderService(
//     ProviderService service,
//   ) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != service.providerId) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot update another provider service.',
//       );
//     }

//     if (service.id.trim().isEmpty) {
//       throw ArgumentError(
//         'Service ID cannot be empty.',
//       );
//     }

//     await _servicesReference(
//       service.providerId,
//     ).doc(service.id).set({
//       ...service.toMap(),
//       'serviceId': service.id,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));

//     await _providers.doc(service.providerId).set({
//       'serviceCategories': FieldValue.arrayUnion([
//         service.category.trim(),
//       ]),
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   Future<ProviderService?> getProviderService({
//     required String providerId,
//     required String serviceId,
//   }) async {
//     final document = await _servicesReference(
//       providerId,
//     ).doc(serviceId).get();

//     if (!document.exists || document.data() == null) {
//       return null;
//     }

//     return ProviderService.fromDoc(document);
//   }

//   Stream<List<ProviderService>> watchProviderServices(
//     String providerId,
//   ) {
//     if (providerId.trim().isEmpty) {
//       return Stream<List<ProviderService>>.value(
//         const [],
//       );
//     }

//     return _servicesReference(providerId)
//         .orderBy(
//           'createdAt',
//           descending: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs.map(ProviderService.fromDoc).toList(),
//         );
//   }

//   Stream<List<ProviderService>> watchActiveProviderServices(
//     String providerId,
//   ) {
//     if (providerId.trim().isEmpty) {
//       return Stream<List<ProviderService>>.value(
//         const [],
//       );
//     }

//     return _servicesReference(providerId)
//         .where(
//           'isActive',
//           isEqualTo: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs.map(ProviderService.fromDoc).toList(),
//         );
//   }

//   /// User app کے لیے category کی تمام active
//   /// services حاصل کریں۔
//   Stream<List<ProviderService>> watchActiveServicesByCategory(
//     String category,
//   ) {
//     final normalizedCategory = category.trim();

//     if (normalizedCategory.isEmpty) {
//       return Stream<List<ProviderService>>.value(
//         const [],
//       );
//     }

//     return _db
//         .collectionGroup('services')
//         .where(
//           'category',
//           isEqualTo: normalizedCategory,
//         )
//         .where(
//           'isActive',
//           isEqualTo: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs.map(ProviderService.fromDoc).toList(),
//         );
//   }

//   Future<void> setServiceActive({
//     required String providerId,
//     required String serviceId,
//     required bool isActive,
//   }) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != providerId) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot update another provider service.',
//       );
//     }

//     await _servicesReference(providerId).doc(serviceId).update({
//       'isActive': isActive,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> deleteProviderService({
//     required String providerId,
//     required String serviceId,
//   }) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != providerId) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot delete another provider service.',
//       );
//     }

//     await _servicesReference(providerId).doc(serviceId).delete();

//     await _rebuildServiceCategories(
//       providerId,
//     );
//   }

//   /// Service delete یا category change ہونے کے بعد
//   /// provider categories دوبارہ بناتا ہے۔
//   Future<void> _rebuildServiceCategories(
//     String providerId,
//   ) async {
//     final snapshot = await _servicesReference(providerId).get();

//     final categories = snapshot.docs
//         .map(
//           (document) => (document.data()['category'] ?? '').toString().trim(),
//         )
//         .where(
//           (category) => category.isNotEmpty,
//         )
//         .toSet()
//         .toList();

//     await _providers.doc(providerId).set({
//       'serviceCategories': categories,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   // ========================================================
//   // PROVIDER LIVE STATUS
//   // ========================================================

//   Future<void> setProviderLive({
//     required String providerId,
//     required bool isLive,
//   }) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != providerId) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot change another provider status.',
//       );
//     }

//     /*
//      * Provider کم از کم ایک active service add کیے
//      * بغیر live نہیں ہوسکتا۔
//      */
//     if (isLive) {
//       final activeServices = await _servicesReference(providerId)
//           .where(
//             'isActive',
//             isEqualTo: true,
//           )
//           .limit(1)
//           .get();

//       if (activeServices.docs.isEmpty) {
//         throw StateError(
//           'Add at least one active service before going live.',
//         );
//       }
//     }

//     await _providers.doc(providerId).set({
//       'isLive': isLive,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   /// Category کے live providers۔
//   ///
//   /// چھوٹی MVP app کے لیے collectionGroup query کے
//   /// بعد provider documents load کیے جاتے ہیں۔
//   Stream<List<ProviderProfile>> watchLiveProvidersForCategory(
//     String category,
//   ) {
//     return watchActiveServicesByCategory(
//       category,
//     ).asyncMap((services) async {
//       final providerIds = services
//           .map((service) => service.providerId)
//           .where((id) => id.isNotEmpty)
//           .toSet();

//       final providers = <ProviderProfile>[];

//       for (final providerId in providerIds) {
//         final provider = await getProvider(providerId);

//         if (provider != null && provider.isLive) {
//           providers.add(provider);
//         }
//       }

//       providers.sort(
//         (first, second) => second.rating.compareTo(
//           first.rating,
//         ),
//       );

//       return providers;
//     });
//   }

//   // ========================================================
//   // DASHBOARD COUNTERS
//   // ========================================================

//   Future<void> incrementProviderCounter({
//     required String providerId,
//     required String field,
//   }) async {
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

//     await _providers.doc(providerId).set({
//       field: FieldValue.increment(1),
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   Future<void> incrementProfileViews(
//     String providerId,
//   ) {
//     return incrementProviderCounter(
//       providerId: providerId,
//       field: 'totalViews',
//     );
//   }

//   Future<void> incrementContacts(
//     String providerId,
//   ) {
//     return incrementProviderCounter(
//       providerId: providerId,
//       field: 'totalContacts',
//     );
//   }

//   // ========================================================
//   // BOOKINGS
//   // bookings/{bookingId}
//   // ========================================================

//   Future<String> createBooking(
//     BookingRequest booking,
//   ) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != booking.userId) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot create a booking for another user.',
//       );
//     }

//     final bookingReference = _bookings.doc();

//     final providerReference = _providers.doc(booking.providerId);

//     final batch = _db.batch();

//     batch.set(bookingReference, {
//       ...booking.toMap(),
//       'bookingId': bookingReference.id,
//       'status': 'requested',
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     });

//     batch.set(
//       providerReference,
//       {
//         'totalBookings': FieldValue.increment(1),
//         'updatedAt': FieldValue.serverTimestamp(),
//       },
//       SetOptions(merge: true),
//     );

//     await batch.commit();

//     return bookingReference.id;
//   }

//   Stream<List<BookingRequest>> watchProviderBookings(
//     String providerId,
//   ) {
//     if (providerId.trim().isEmpty) {
//       return Stream<List<BookingRequest>>.value(
//         const [],
//       );
//     }

//     return _bookings
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
//           (snapshot) => snapshot.docs.map(BookingRequest.fromDoc).toList(),
//         );
//   }

//   Stream<List<BookingRequest>> watchUserBookings(
//     String userId,
//   ) {
//     if (userId.trim().isEmpty) {
//       return Stream<List<BookingRequest>>.value(
//         const [],
//       );
//     }

//     return _bookings
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
//           (snapshot) => snapshot.docs.map(BookingRequest.fromDoc).toList(),
//         );
//   }

//   Future<void> updateBookingStatus({
//     required String bookingId,
//     required String status,
//   }) async {
//     final normalizedStatus = status.trim().toLowerCase();

//     const allowedStatuses = {
//       'requested',
//       'accepted',
//       'completed',
//       'rejected',
//       'cancelled',
//     };

//     if (!allowedStatuses.contains(
//       normalizedStatus,
//     )) {
//       throw ArgumentError(
//         'Invalid booking status: $status',
//       );
//     }

//     await _bookings.doc(bookingId).update({
//       'status': normalizedStatus,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> deleteBooking(
//     String bookingId,
//   ) async {
//     await _bookings.doc(bookingId).delete();
//   }

//   Future<void> createProviderService(ProviderService service) async {}
// }

// //ignore_for_file: file_names

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:service_hub/new/appuser.dart';

// class FirestoreService {
//   FirestoreService._();

//   static final FirestoreService instance = FirestoreService._();

//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   CollectionReference<Map<String, dynamic>> get _users =>
//       _db.collection('users');

//   CollectionReference<Map<String, dynamic>> get _providers =>
//       _db.collection('providers');

//   CollectionReference<Map<String, dynamic>> get _bookings =>
//       _db.collection('bookings');

//   User get _requiredFirebaseUser {
//     final user = _auth.currentUser;

//     if (user == null) {
//       throw FirebaseAuthException(
//         code: 'no-current-user',
//         message: 'Your session has expired. Please login again.',
//       );
//     }

//     return user;
//   }

//   // ========================================================
//   // USERS
//   // users/{uid}
//   // ========================================================

//   Future<AppUser?> getUser(String uid) async {
//     if (uid.trim().isEmpty) return null;

//     final document = await _users.doc(uid.trim()).get();

//     if (!document.exists || document.data() == null) {
//       return null;
//     }

//     return AppUser.fromDoc(document);
//   }

//   Future<AppUser?> getCurrentUser() async {
//     final user = _auth.currentUser;

//     if (user == null) return null;

//     return getUser(user.uid);
//   }

//   Stream<AppUser?> watchUser(String uid) {
//     if (uid.trim().isEmpty) {
//       return Stream<AppUser?>.value(null);
//     }

//     return _users.doc(uid.trim()).snapshots().map((document) {
//       if (!document.exists || document.data() == null) {
//         return null;
//       }

//       return AppUser.fromDoc(document);
//     });
//   }

//   Future<void> createOrUpdateUser(
//     AppUser user,
//   ) async {
//     await _users.doc(user.uid).set(
//           user.toMap(),
//           SetOptions(merge: true),
//         );
//   }

//   Future<void> updateUserFields({
//     required String uid,
//     required Map<String, dynamic> data,
//   }) async {
//     if (uid.trim().isEmpty) {
//       throw ArgumentError('UID cannot be empty.');
//     }

//     await _users.doc(uid.trim()).set({
//       ...data,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   Future<String?> getUserRole(
//     String uid,
//   ) async {
//     final user = await getUser(uid);

//     return user?.role.trim().toLowerCase();
//   }

//   Future<void> updateEmailVerification({
//     required String uid,
//     required bool verified,
//   }) async {
//     await updateUserFields(
//       uid: uid,
//       data: {
//         'emailVerified': verified,
//       },
//     );
//   }

//   Future<void> updateProfileCompletion({
//     required String uid,
//     required bool completed,
//   }) async {
//     await updateUserFields(
//       uid: uid,
//       data: {
//         'profileCompleted': completed,
//       },
//     );
//   }

//   // ========================================================
//   // PROVIDER PROFILE
//   // providers/{providerId}
//   // ========================================================

//   Future<ProviderProfile?> getProvider(
//     String providerId,
//   ) async {
//     if (providerId.trim().isEmpty) {
//       return null;
//     }

//     final document = await _providers.doc(providerId.trim()).get();

//     if (!document.exists || document.data() == null) {
//       return null;
//     }

//     return ProviderProfile.fromDoc(document);
//   }

//   Future<ProviderProfile?> getCurrentProvider() async {
//     final user = _auth.currentUser;

//     if (user == null) return null;

//     return getProvider(user.uid);
//   }

//   Stream<ProviderProfile?> watchProvider(
//     String providerId,
//   ) {
//     if (providerId.trim().isEmpty) {
//       return Stream<ProviderProfile?>.value(
//         null,
//       );
//     }

//     return _providers.doc(providerId.trim()).snapshots().map((document) {
//       if (!document.exists || document.data() == null) {
//         return null;
//       }

//       return ProviderProfile.fromDoc(document);
//     });
//   }

//   Future<void> createOrUpdateProvider(
//     ProviderProfile provider,
//   ) async {
//     if (provider.uid.trim().isEmpty) {
//       throw ArgumentError(
//         'Provider UID cannot be empty.',
//       );
//     }

//     await _providers.doc(provider.uid).set(
//           provider.toMap(),
//           SetOptions(merge: true),
//         );
//   }

//   /// Provider profile save کرکے users document میں
//   /// profileCompleted true کرتا ہے۔
//   Future<void> saveCompletedProviderProfile(
//     ProviderProfile provider,
//   ) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != provider.uid) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot update another provider profile.',
//       );
//     }

//     final providerReference = _providers.doc(provider.uid);

//     final userReference = _users.doc(provider.uid);

//     final batch = _db.batch();

//     batch.set(
//       providerReference,
//       {
//         ...provider.toMap(),
//         if (provider.createdAt == null)
//           'createdAt': FieldValue.serverTimestamp(),
//       },
//       SetOptions(merge: true),
//     );

//     batch.set(
//       userReference,
//       {
//         'uid': provider.uid,
//         'email': provider.email.trim().toLowerCase(),
//         'name': provider.name.trim(),
//         'whatsapp': provider.whatsapp.trim(),
//         'role': 'provider',
//         'emailVerified': firebaseUser.emailVerified,
//         'profileCompleted': true,
//         'updatedAt': FieldValue.serverTimestamp(),
//       },
//       SetOptions(merge: true),
//     );

//     await batch.commit();
//   }

//   Future<void> updateProviderFields({
//     required String providerId,
//     required Map<String, dynamic> data,
//     required String uid,
//   }) async {
//     if (providerId.trim().isEmpty) {
//       throw ArgumentError(
//         'Provider ID cannot be empty.',
//       );
//     }

//     await _providers.doc(providerId.trim()).set({
//       ...data,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   // ========================================================
//   // PROVIDER SERVICES
//   // providers/{providerId}/services/{serviceId}
//   // ========================================================

//   CollectionReference<Map<String, dynamic>> _servicesReference(
//     String providerId,
//   ) {
//     final cleanProviderId = providerId.trim();

//     if (cleanProviderId.isEmpty) {
//       throw ArgumentError('Provider ID cannot be empty.');
//     }

//     return _providers.doc(cleanProviderId).collection('services');
//   }

//   /// نئی provider service add کریں۔
//   Future<String> addProviderService(
//     ProviderService service,
//   ) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != service.providerId) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot add a service for another provider.',
//       );
//     }

//     final serviceReference = _servicesReference(service.providerId).doc();

//     await serviceReference.set({
//       ...service.toMap(),
//       'serviceId': serviceReference.id,
//       'providerId': service.providerId,
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     });

//     /*
//      * Provider document میں categories بھی رکھیں،
//      * تاکہ user-side searching آسان ہو۔
//      */
//     await _providers.doc(service.providerId).set({
//       'serviceCategories': FieldValue.arrayUnion([
//         service.category.trim(),
//       ]),
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));

//     return serviceReference.id;
//   }

//   /// موجودہ service update کریں۔
//   Future<String> _resolveProviderServiceDocumentId(
//     ProviderService service,
//   ) async {
//     final services = _servicesReference(service.providerId);
//     final incomingId = service.id.trim();

//     // Naye/correct data mein model ID hi Firestore document ID hoti hai.
//     if (incomingId.isNotEmpty) {
//       final directDocument = await services.doc(incomingId).get();

//       if (directDocument.exists) {
//         return directDocument.id;
//       }

//       // Purane data mein serviceId field aur document ID different ho sakte hain.
//       final storedIdResult = await services
//           .where('serviceId', isEqualTo: incomingId)
//           .limit(1)
//           .get();

//       if (storedIdResult.docs.isNotEmpty) {
//         return storedIdResult.docs.first.id;
//       }
//     }

//     // Legacy service mein ID empty/mismatched ho to uske existing fields se
//     // sirf usi provider ke services collection mein document locate karein.
//     final snapshot = await services.get();
//     final cleanTitle = service.title.trim().toLowerCase();
//     final cleanCategory = service.category.trim().toLowerCase();
//     final cleanArea = service.serviceArea.trim().toLowerCase();

//     final matchingDocuments = snapshot.docs.where((document) {
//       final data = document.data();

//       final title = (data['title'] ?? '').toString().trim().toLowerCase();
//       final category = (data['category'] ?? '').toString().trim().toLowerCase();
//       final area = (data['serviceArea'] ?? '').toString().trim().toLowerCase();

//       return title == cleanTitle &&
//           category == cleanCategory &&
//           area == cleanArea;
//     }).toList();

//     if (matchingDocuments.length == 1) {
//       return matchingDocuments.first.id;
//     }

//     throw StateError(
//       matchingDocuments.isEmpty
//           ? 'Existing service document could not be found.'
//           : 'More than one matching service was found. Delete the duplicate service first.',
//     );
//   }

//   Future<void> updateProviderService(ProviderService service,
//       {ProviderService? originalService}) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != service.providerId) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot update another provider service.',
//       );
//     }

//     final resolvedServiceId = await _resolveProviderServiceDocumentId(service);

//     await _servicesReference(
//       service.providerId,
//     ).doc(resolvedServiceId).set({
//       ...service.toMap(),
//       'serviceId': resolvedServiceId,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));

//     await _providers.doc(service.providerId).set({
//       'serviceCategories': FieldValue.arrayUnion([
//         service.category.trim(),
//       ]),
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   Future<ProviderService?> getProviderService({
//     required String providerId,
//     required String serviceId,
//   }) async {
//     final document = await _servicesReference(
//       providerId,
//     ).doc(serviceId).get();

//     if (!document.exists || document.data() == null) {
//       return null;
//     }

//     return ProviderService.fromDoc(document);
//   }

//   Stream<List<ProviderService>> watchProviderServices(
//     String providerId,
//   ) {
//     if (providerId.trim().isEmpty) {
//       return Stream<List<ProviderService>>.value(
//         const [],
//       );
//     }

//     return _servicesReference(providerId)
//         .orderBy(
//           'createdAt',
//           descending: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs
//               .map(
//                 (document) => ProviderService.fromDoc(document).copyWith(
//                   id: document.id,
//                 ),
//               )
//               .toList(),
//         );
//   }

//   Stream<List<ProviderService>> watchActiveProviderServices(
//     String providerId,
//   ) {
//     if (providerId.trim().isEmpty) {
//       return Stream<List<ProviderService>>.value(
//         const [],
//       );
//     }

//     return _servicesReference(providerId)
//         .where(
//           'isActive',
//           isEqualTo: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs
//               .map(
//                 (document) => ProviderService.fromDoc(document).copyWith(
//                   id: document.id,
//                 ),
//               )
//               .toList(),
//         );
//   }

//   /// User app کے لیے category کی تمام active
//   /// services حاصل کریں۔
//   Stream<List<ProviderService>> watchActiveServicesByCategory(
//     String category,
//   ) {
//     final normalizedCategory = category.trim();

//     if (normalizedCategory.isEmpty) {
//       return Stream<List<ProviderService>>.value(
//         const [],
//       );
//     }

//     return _db
//         .collectionGroup('services')
//         .where(
//           'category',
//           isEqualTo: normalizedCategory,
//         )
//         .where(
//           'isActive',
//           isEqualTo: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs
//               .map(
//                 (document) => ProviderService.fromDoc(document).copyWith(
//                   id: document.id,
//                 ),
//               )
//               .toList(),
//         );
//   }

//   Future<void> setServiceActive({
//     required String providerId,
//     required String serviceId,
//     required bool isActive,
//   }) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != providerId) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot update another provider service.',
//       );
//     }

//     await _servicesReference(providerId).doc(serviceId).update({
//       'isActive': isActive,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> deleteProviderService({
//     required String providerId,
//     required String serviceId,
//   }) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != providerId) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot delete another provider service.',
//       );
//     }

//     await _servicesReference(providerId).doc(serviceId).delete();

//     await _rebuildServiceCategories(
//       providerId,
//     );
//   }

//   /// Service delete یا category change ہونے کے بعد
//   /// provider categories دوبارہ بناتا ہے۔
//   Future<void> _rebuildServiceCategories(
//     String providerId,
//   ) async {
//     final snapshot = await _servicesReference(providerId).get();

//     final categories = snapshot.docs
//         .map(
//           (document) => (document.data()['category'] ?? '').toString().trim(),
//         )
//         .where(
//           (category) => category.isNotEmpty,
//         )
//         .toSet()
//         .toList();

//     await _providers.doc(providerId).set({
//       'serviceCategories': categories,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   // ========================================================
//   // PROVIDER LIVE STATUS
//   // ========================================================

//   Future<void> setProviderLive({
//     required String providerId,
//     required bool isLive,
//   }) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != providerId) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot change another provider status.',
//       );
//     }

//     /*
//      * Provider کم از کم ایک active service add کیے
//      * بغیر live نہیں ہوسکتا۔
//      */
//     if (isLive) {
//       final activeServices = await _servicesReference(providerId)
//           .where(
//             'isActive',
//             isEqualTo: true,
//           )
//           .limit(1)
//           .get();

//       if (activeServices.docs.isEmpty) {
//         throw StateError(
//           'Add at least one active service before going live.',
//         );
//       }
//     }

//     await _providers.doc(providerId).set({
//       'isLive': isLive,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   /// Category کے live providers۔
//   ///
//   /// چھوٹی MVP app کے لیے collectionGroup query کے
//   /// بعد provider documents load کیے جاتے ہیں۔
//   Stream<List<ProviderProfile>> watchLiveProvidersForCategory(
//     String category,
//   ) {
//     return watchActiveServicesByCategory(
//       category,
//     ).asyncMap((services) async {
//       final providerIds = services
//           .map((service) => service.providerId)
//           .where((id) => id.isNotEmpty)
//           .toSet();

//       final providers = <ProviderProfile>[];

//       for (final providerId in providerIds) {
//         final provider = await getProvider(providerId);

//         if (provider != null && provider.isLive) {
//           providers.add(provider);
//         }
//       }

//       providers.sort(
//         (first, second) => second.rating.compareTo(
//           first.rating,
//         ),
//       );

//       return providers;
//     });
//   }

//   // ========================================================
//   // DASHBOARD COUNTERS
//   // ========================================================

//   Future<void> incrementProviderCounter({
//     required String providerId,
//     required String field,
//   }) async {
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

//     await _providers.doc(providerId).set({
//       field: FieldValue.increment(1),
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   Future<void> incrementProfileViews(
//     String providerId,
//   ) {
//     return incrementProviderCounter(
//       providerId: providerId,
//       field: 'totalViews',
//     );
//   }

//   Future<void> incrementContacts(
//     String providerId,
//   ) {
//     return incrementProviderCounter(
//       providerId: providerId,
//       field: 'totalContacts',
//     );
//   }

//   // ========================================================
//   // BOOKINGS
//   // bookings/{bookingId}
//   // ========================================================

//   Future<String> createBooking(
//     BookingRequest booking,
//   ) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != booking.userId) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot create a booking for another user.',
//       );
//     }

//     final bookingReference = _bookings.doc();

//     final providerReference = _providers.doc(booking.providerId);

//     final batch = _db.batch();

//     batch.set(bookingReference, {
//       ...booking.toMap(),
//       'bookingId': bookingReference.id,
//       'status': 'requested',
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     });

//     batch.set(
//       providerReference,
//       {
//         'totalBookings': FieldValue.increment(1),
//         'updatedAt': FieldValue.serverTimestamp(),
//       },
//       SetOptions(merge: true),
//     );

//     await batch.commit();

//     return bookingReference.id;
//   }

//   Stream<List<BookingRequest>> watchProviderBookings(
//     String providerId,
//   ) {
//     if (providerId.trim().isEmpty) {
//       return Stream<List<BookingRequest>>.value(
//         const [],
//       );
//     }

//     return _bookings
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
//           (snapshot) => snapshot.docs.map(BookingRequest.fromDoc).toList(),
//         );
//   }

//   Stream<List<BookingRequest>> watchUserBookings(
//     String userId,
//   ) {
//     if (userId.trim().isEmpty) {
//       return Stream<List<BookingRequest>>.value(
//         const [],
//       );
//     }

//     return _bookings
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
//           (snapshot) => snapshot.docs.map(BookingRequest.fromDoc).toList(),
//         );
//   }

//   Future<void> updateBookingStatus({
//     required String bookingId,
//     required String status,
//   }) async {
//     final normalizedStatus = status.trim().toLowerCase();

//     const allowedStatuses = {
//       'requested',
//       'accepted',
//       'completed',
//       'rejected',
//       'cancelled',
//     };

//     if (!allowedStatuses.contains(
//       normalizedStatus,
//     )) {
//       throw ArgumentError(
//         'Invalid booking status: $status',
//       );
//     }

//     await _bookings.doc(bookingId).update({
//       'status': normalizedStatus,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> deleteBooking(
//     String bookingId,
//   ) async {
//     await _bookings.doc(bookingId).delete();
//   }

//   Future<String> createProviderService(ProviderService service) {
//     return addProviderService(service);
//   }
// }

// // ignore_for_file: file_names

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:service_hub/new/appuser.dart';

// class FirestoreService {
//   FirestoreService._();

//   static final FirestoreService instance = FirestoreService._();

//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   CollectionReference<Map<String, dynamic>> get _users =>
//       _db.collection('users');

//   CollectionReference<Map<String, dynamic>> get _providers =>
//       _db.collection('providers');

//   CollectionReference<Map<String, dynamic>> get _bookings =>
//       _db.collection('bookings');

//   User get _requiredFirebaseUser {
//     final user = _auth.currentUser;

//     if (user == null) {
//       throw FirebaseAuthException(
//         code: 'no-current-user',
//         message: 'Your session has expired. Please login again.',
//       );
//     }

//     return user;
//   }

//   // ========================================================
//   // USERS
//   // users/{uid}
//   // ========================================================

//   Future<AppUser?> getUser(String uid) async {
//     if (uid.trim().isEmpty) return null;

//     final document = await _users.doc(uid.trim()).get();

//     if (!document.exists || document.data() == null) {
//       return null;
//     }

//     return AppUser.fromDoc(document);
//   }

//   Future<AppUser?> getCurrentUser() async {
//     final user = _auth.currentUser;

//     if (user == null) return null;

//     return getUser(user.uid);
//   }

//   Stream<AppUser?> watchUser(String uid) {
//     if (uid.trim().isEmpty) {
//       return Stream<AppUser?>.value(null);
//     }

//     return _users.doc(uid.trim()).snapshots().map((document) {
//       if (!document.exists || document.data() == null) {
//         return null;
//       }

//       return AppUser.fromDoc(document);
//     });
//   }

//   Future<void> createOrUpdateUser(
//     AppUser user,
//   ) async {
//     await _users.doc(user.uid).set(
//           user.toMap(),
//           SetOptions(merge: true),
//         );
//   }

//   Future<void> updateUserFields({
//     required String uid,
//     required Map<String, dynamic> data,
//   }) async {
//     if (uid.trim().isEmpty) {
//       throw ArgumentError('UID cannot be empty.');
//     }

//     await _users.doc(uid.trim()).set({
//       ...data,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   Future<String?> getUserRole(
//     String uid,
//   ) async {
//     final user = await getUser(uid);

//     return user?.role.trim().toLowerCase();
//   }

//   Future<void> updateEmailVerification({
//     required String uid,
//     required bool verified,
//   }) async {
//     await updateUserFields(
//       uid: uid,
//       data: {
//         'emailVerified': verified,
//       },
//     );
//   }

//   Future<void> updateProfileCompletion({
//     required String uid,
//     required bool completed,
//   }) async {
//     await updateUserFields(
//       uid: uid,
//       data: {
//         'profileCompleted': completed,
//       },
//     );
//   }

//   // ========================================================
//   // PROVIDER PROFILE
//   // providers/{providerId}
//   // ========================================================

//   Future<ProviderProfile?> getProvider(
//     String providerId,
//   ) async {
//     if (providerId.trim().isEmpty) {
//       return null;
//     }

//     final document = await _providers.doc(providerId.trim()).get();

//     if (!document.exists || document.data() == null) {
//       return null;
//     }

//     return ProviderProfile.fromDoc(document);
//   }

//   Future<ProviderProfile?> getCurrentProvider() async {
//     final user = _auth.currentUser;

//     if (user == null) return null;

//     return getProvider(user.uid);
//   }

//   Stream<ProviderProfile?> watchProvider(
//     String providerId,
//   ) {
//     if (providerId.trim().isEmpty) {
//       return Stream<ProviderProfile?>.value(
//         null,
//       );
//     }

//     return _providers.doc(providerId.trim()).snapshots().map((document) {
//       if (!document.exists || document.data() == null) {
//         return null;
//       }

//       return ProviderProfile.fromDoc(document);
//     });
//   }

//   Future<void> createOrUpdateProvider(
//     ProviderProfile provider,
//   ) async {
//     if (provider.uid.trim().isEmpty) {
//       throw ArgumentError(
//         'Provider UID cannot be empty.',
//       );
//     }

//     await _providers.doc(provider.uid).set(
//           provider.toMap(),
//           SetOptions(merge: true),
//         );
//   }

//   /// Provider profile save کرکے users document میں
//   /// profileCompleted true کرتا ہے۔
//   Future<void> saveCompletedProviderProfile(
//     ProviderProfile provider,
//   ) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != provider.uid) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot update another provider profile.',
//       );
//     }

//     final providerReference = _providers.doc(provider.uid);

//     final userReference = _users.doc(provider.uid);

//     final batch = _db.batch();

//     batch.set(
//       providerReference,
//       {
//         ...provider.toMap(),
//         if (provider.createdAt == null)
//           'createdAt': FieldValue.serverTimestamp(),
//       },
//       SetOptions(merge: true),
//     );

//     batch.set(
//       userReference,
//       {
//         'uid': provider.uid,
//         'email': provider.email.trim().toLowerCase(),
//         'name': provider.name.trim(),
//         'whatsapp': provider.whatsapp.trim(),
//         'role': 'provider',
//         'emailVerified': firebaseUser.emailVerified,
//         'profileCompleted': true,
//         'updatedAt': FieldValue.serverTimestamp(),
//       },
//       SetOptions(merge: true),
//     );

//     await batch.commit();
//   }

//   Future<void> updateProviderFields({
//     required String providerId,
//     required Map<String, dynamic> data,
//     required String uid,
//   }) async {
//     if (providerId.trim().isEmpty) {
//       throw ArgumentError(
//         'Provider ID cannot be empty.',
//       );
//     }

//     await _providers.doc(providerId.trim()).set({
//       ...data,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   // ========================================================
//   // PROVIDER SERVICES
//   // providers/{providerId}/services/{serviceId}
//   // ========================================================

//   CollectionReference<Map<String, dynamic>> _servicesReference(
//     String providerId,
//   ) {
//     final cleanProviderId = providerId.trim();

//     if (cleanProviderId.isEmpty) {
//       throw ArgumentError('Provider ID cannot be empty.');
//     }

//     return _providers.doc(cleanProviderId).collection('services');
//   }

//   /// نئی provider service add کریں۔
//   Future<String> addProviderService(
//     ProviderService service,
//   ) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != service.providerId) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot add a service for another provider.',
//       );
//     }

//     final serviceReference = _servicesReference(service.providerId).doc();

//     await serviceReference.set({
//       ...service.toMap(),
//       'serviceId': serviceReference.id,
//       'providerId': service.providerId,
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     });

//     /*
//      * Provider document میں categories بھی رکھیں،
//      * تاکہ user-side searching آسان ہو۔
//      */
//     await _providers.doc(service.providerId).set({
//       'serviceCategories': FieldValue.arrayUnion([
//         service.category.trim(),
//       ]),
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));

//     return serviceReference.id;
//   }

//   /// موجودہ service update کریں۔
//   Future<String> _resolveProviderServiceDocumentId(
//     ProviderService service,
//   ) async {
//     final services = _servicesReference(service.providerId);
//     final incomingId = service.id.trim();

//     // Naye/correct data mein model ID hi Firestore document ID hoti hai.
//     if (incomingId.isNotEmpty) {
//       final directDocument = await services.doc(incomingId).get();

//       if (directDocument.exists) {
//         return directDocument.id;
//       }

//       // Purane data mein serviceId field aur document ID different ho sakte hain.
//       final storedIdResult = await services
//           .where('serviceId', isEqualTo: incomingId)
//           .limit(1)
//           .get();

//       if (storedIdResult.docs.isNotEmpty) {
//         return storedIdResult.docs.first.id;
//       }
//     }

//     // Legacy service mein ID empty/mismatched ho to uske existing fields se
//     // sirf usi provider ke services collection mein document locate karein.
//     final snapshot = await services.get();
//     final cleanTitle = service.title.trim().toLowerCase();
//     final cleanCategory = service.category.trim().toLowerCase();
//     final cleanArea = service.serviceArea.trim().toLowerCase();

//     final matchingDocuments = snapshot.docs.where((document) {
//       final data = document.data();

//       final title = (data['title'] ?? '').toString().trim().toLowerCase();
//       final category = (data['category'] ?? '').toString().trim().toLowerCase();
//       final area = (data['serviceArea'] ?? '').toString().trim().toLowerCase();

//       return title == cleanTitle &&
//           category == cleanCategory &&
//           area == cleanArea;
//     }).toList();

//     if (matchingDocuments.length == 1) {
//       return matchingDocuments.first.id;
//     }

//     throw StateError(
//       matchingDocuments.isEmpty
//           ? 'Existing service document could not be found.'
//           : 'More than one matching service was found. Delete the duplicate service first.',
//     );
//   }

//   Future<void> updateProviderService(
//     ProviderService service,
//   ) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != service.providerId) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot update another provider service.',
//       );
//     }

//     final resolvedServiceId = await _resolveProviderServiceDocumentId(service);

//     await _servicesReference(
//       service.providerId,
//     ).doc(resolvedServiceId).set({
//       ...service.toMap(),
//       'serviceId': resolvedServiceId,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));

//     await _providers.doc(service.providerId).set({
//       'serviceCategories': FieldValue.arrayUnion([
//         service.category.trim(),
//       ]),
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   Future<ProviderService?> getProviderService({
//     required String providerId,
//     required String serviceId,
//   }) async {
//     final document = await _servicesReference(
//       providerId,
//     ).doc(serviceId).get();

//     if (!document.exists || document.data() == null) {
//       return null;
//     }

//     return ProviderService.fromDoc(document);
//   }

//   Stream<List<ProviderService>> watchProviderServices(
//     String providerId,
//   ) {
//     if (providerId.trim().isEmpty) {
//       return Stream<List<ProviderService>>.value(
//         const [],
//       );
//     }

//     return _servicesReference(providerId)
//         .orderBy(
//           'createdAt',
//           descending: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs
//               .map(
//                 (document) => ProviderService.fromDoc(document).copyWith(
//                   id: document.id,
//                 ),
//               )
//               .toList(),
//         );
//   }

//   Stream<List<ProviderService>> watchActiveProviderServices(
//     String providerId,
//   ) {
//     if (providerId.trim().isEmpty) {
//       return Stream<List<ProviderService>>.value(
//         const [],
//       );
//     }

//     return _servicesReference(providerId)
//         .where(
//           'isActive',
//           isEqualTo: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs
//               .map(
//                 (document) => ProviderService.fromDoc(document).copyWith(
//                   id: document.id,
//                 ),
//               )
//               .toList(),
//         );
//   }

//   /// User app کے لیے category کی تمام active
//   /// services حاصل کریں۔
//   Stream<List<ProviderService>> watchActiveServicesByCategory(
//     String category,
//   ) {
//     final normalizedCategory = category.trim();

//     if (normalizedCategory.isEmpty) {
//       return Stream<List<ProviderService>>.value(
//         const [],
//       );
//     }

//     return _db
//         .collectionGroup('services')
//         .where(
//           'category',
//           isEqualTo: normalizedCategory,
//         )
//         .where(
//           'isActive',
//           isEqualTo: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs
//               .map(
//                 (document) => ProviderService.fromDoc(document).copyWith(
//                   id: document.id,
//                 ),
//               )
//               .toList(),
//         );
//   }

//   Future<void> setServiceActive({
//     required String providerId,
//     required String serviceId,
//     required bool isActive,
//   }) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != providerId) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot update another provider service.',
//       );
//     }

//     await _servicesReference(providerId).doc(serviceId).update({
//       'isActive': isActive,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> deleteProviderService({
//     required String providerId,
//     required String serviceId,
//   }) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != providerId) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot delete another provider service.',
//       );
//     }

//     await _servicesReference(providerId).doc(serviceId).delete();

//     await _rebuildServiceCategories(
//       providerId,
//     );
//   }

//   /// Service delete یا category change ہونے کے بعد
//   /// provider categories دوبارہ بناتا ہے۔
//   Future<void> _rebuildServiceCategories(
//     String providerId,
//   ) async {
//     final snapshot = await _servicesReference(providerId).get();

//     final categories = snapshot.docs
//         .map(
//           (document) => (document.data()['category'] ?? '').toString().trim(),
//         )
//         .where(
//           (category) => category.isNotEmpty,
//         )
//         .toSet()
//         .toList();

//     await _providers.doc(providerId).set({
//       'serviceCategories': categories,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   // ========================================================
//   // PROVIDER LIVE STATUS
//   // ========================================================

//   Future<void> setProviderLive({
//     required String providerId,
//     required bool isLive,
//   }) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != providerId) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot change another provider status.',
//       );
//     }

//     /*
//      * Provider کم از کم ایک active service add کیے
//      * بغیر live نہیں ہوسکتا۔
//      */
//     if (isLive) {
//       final activeServices = await _servicesReference(providerId)
//           .where(
//             'isActive',
//             isEqualTo: true,
//           )
//           .limit(1)
//           .get();

//       if (activeServices.docs.isEmpty) {
//         throw StateError(
//           'Add at least one active service before going live.',
//         );
//       }
//     }

//     await _providers.doc(providerId).set({
//       'isLive': isLive,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   /// Category کے live providers۔
//   ///
//   /// چھوٹی MVP app کے لیے collectionGroup query کے
//   /// بعد provider documents load کیے جاتے ہیں۔
//   Stream<List<ProviderProfile>> watchLiveProvidersForCategory(
//     String category,
//   ) {
//     return watchActiveServicesByCategory(
//       category,
//     ).asyncMap((services) async {
//       final providerIds = services
//           .map((service) => service.providerId)
//           .where((id) => id.isNotEmpty)
//           .toSet();

//       final providers = <ProviderProfile>[];

//       for (final providerId in providerIds) {
//         final provider = await getProvider(providerId);

//         if (provider != null && provider.isLive) {
//           providers.add(provider);
//         }
//       }

//       providers.sort(
//         (first, second) => second.rating.compareTo(
//           first.rating,
//         ),
//       );

//       return providers;
//     });
//   }

//   // ========================================================
//   // DASHBOARD COUNTERS
//   // ========================================================

//   Future<void> incrementProviderCounter({
//     required String providerId,
//     required String field,
//   }) async {
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

//     await _providers.doc(providerId).set({
//       field: FieldValue.increment(1),
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   Future<void> incrementProfileViews(
//     String providerId,
//   ) {
//     return incrementProviderCounter(
//       providerId: providerId,
//       field: 'totalViews',
//     );
//   }

//   Future<void> incrementContacts(
//     String providerId,
//   ) {
//     return incrementProviderCounter(
//       providerId: providerId,
//       field: 'totalContacts',
//     );
//   }

//   // ========================================================
//   // BOOKINGS
//   // bookings/{bookingId}
//   // ========================================================

//   Future<String> createBooking(
//     BookingRequest booking,
//   ) async {
//     final firebaseUser = _requiredFirebaseUser;

//     if (firebaseUser.uid != booking.userId) {
//       throw FirebaseAuthException(
//         code: 'permission-denied',
//         message: 'You cannot create a booking for another user.',
//       );
//     }

//     final bookingReference = _bookings.doc();

//     final providerReference = _providers.doc(booking.providerId);

//     final batch = _db.batch();

//     batch.set(bookingReference, {
//       ...booking.toMap(),
//       'bookingId': bookingReference.id,
//       'status': 'requested',
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     });

//     batch.set(
//       providerReference,
//       {
//         'totalBookings': FieldValue.increment(1),
//         'updatedAt': FieldValue.serverTimestamp(),
//       },
//       SetOptions(merge: true),
//     );

//     await batch.commit();

//     return bookingReference.id;
//   }

//   Stream<List<BookingRequest>> watchProviderBookings(
//     String providerId,
//   ) {
//     if (providerId.trim().isEmpty) {
//       return Stream<List<BookingRequest>>.value(
//         const [],
//       );
//     }

//     return _bookings
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
//           (snapshot) => snapshot.docs.map(BookingRequest.fromDoc).toList(),
//         );
//   }

//   Stream<List<BookingRequest>> watchUserBookings(
//     String userId,
//   ) {
//     if (userId.trim().isEmpty) {
//       return Stream<List<BookingRequest>>.value(
//         const [],
//       );
//     }

//     return _bookings
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
//           (snapshot) => snapshot.docs.map(BookingRequest.fromDoc).toList(),
//         );
//   }

//   Future<void> updateBookingStatus({
//     required String bookingId,
//     required String status,
//   }) async {
//     final normalizedStatus = status.trim().toLowerCase();

//     const allowedStatuses = {
//       'requested',
//       'accepted',
//       'completed',
//       'rejected',
//       'cancelled',
//     };

//     if (!allowedStatuses.contains(
//       normalizedStatus,
//     )) {
//       throw ArgumentError(
//         'Invalid booking status: $status',
//       );
//     }

//     await _bookings.doc(bookingId).update({
//       'status': normalizedStatus,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> deleteBooking(
//     String bookingId,
//   ) async {
//     await _bookings.doc(bookingId).delete();
//   }

//   Future<String> createProviderService(ProviderService service) {
//     return addProviderService(service);
//   }
// }

// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:service_hub/new/appuser.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _providers =>
      _db.collection('providers');

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _db.collection('bookings');

  User get _requiredFirebaseUser {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Your session has expired. Please login again.',
      );
    }

    return user;
  }

  // ========================================================
  // USERS
  // users/{uid}
  // ========================================================

  Future<AppUser?> getUser(String uid) async {
    if (uid.trim().isEmpty) return null;

    final document = await _users.doc(uid.trim()).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return AppUser.fromDoc(document);
  }

  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    return getUser(user.uid);
  }

  Stream<AppUser?> watchUser(String uid) {
    if (uid.trim().isEmpty) {
      return Stream<AppUser?>.value(null);
    }

    return _users.doc(uid.trim()).snapshots().map((document) {
      if (!document.exists || document.data() == null) {
        return null;
      }

      return AppUser.fromDoc(document);
    });
  }

  Future<void> createOrUpdateUser(
    AppUser user,
  ) async {
    await _users.doc(user.uid).set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<void> updateUserFields({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    if (uid.trim().isEmpty) {
      throw ArgumentError('UID cannot be empty.');
    }

    await _users.doc(uid.trim()).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String?> getUserRole(
    String uid,
  ) async {
    final user = await getUser(uid);

    return user?.role.trim().toLowerCase();
  }

  Future<void> updateEmailVerification({
    required String uid,
    required bool verified,
  }) async {
    await updateUserFields(
      uid: uid,
      data: {
        'emailVerified': verified,
      },
    );
  }

  Future<void> updateProfileCompletion({
    required String uid,
    required bool completed,
  }) async {
    await updateUserFields(
      uid: uid,
      data: {
        'profileCompleted': completed,
      },
    );
  }

  // ========================================================
  // PROVIDER PROFILE
  // providers/{providerId}
  // ========================================================

  Future<ProviderProfile?> getProvider(
    String providerId,
  ) async {
    if (providerId.trim().isEmpty) {
      return null;
    }

    final document = await _providers.doc(providerId.trim()).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return ProviderProfile.fromDoc(document);
  }

  Future<ProviderProfile?> getCurrentProvider() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    return getProvider(user.uid);
  }

  Stream<ProviderProfile?> watchProvider(
    String providerId,
  ) {
    if (providerId.trim().isEmpty) {
      return Stream<ProviderProfile?>.value(
        null,
      );
    }

    return _providers.doc(providerId.trim()).snapshots().map((document) {
      if (!document.exists || document.data() == null) {
        return null;
      }

      return ProviderProfile.fromDoc(document);
    });
  }

  Future<void> createOrUpdateProvider(
    ProviderProfile provider,
  ) async {
    if (provider.uid.trim().isEmpty) {
      throw ArgumentError(
        'Provider UID cannot be empty.',
      );
    }

    await _providers.doc(provider.uid).set(
          provider.toMap(),
          SetOptions(merge: true),
        );
  }

  /// Provider profile save کرکے users document میں
  /// profileCompleted true کرتا ہے۔
  Future<void> saveCompletedProviderProfile(
    ProviderProfile provider,
  ) async {
    final firebaseUser = _requiredFirebaseUser;

    if (firebaseUser.uid != provider.uid) {
      throw FirebaseAuthException(
        code: 'permission-denied',
        message: 'You cannot update another provider profile.',
      );
    }

    final providerReference = _providers.doc(provider.uid);

    final userReference = _users.doc(provider.uid);

    final batch = _db.batch();

    batch.set(
      providerReference,
      {
        ...provider.toMap(),
        if (provider.createdAt == null)
          'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(
      userReference,
      {
        'uid': provider.uid,
        'email': provider.email.trim().toLowerCase(),
        'name': provider.name.trim(),
        'whatsapp': provider.whatsapp.trim(),
        'role': 'provider',
        'emailVerified': firebaseUser.emailVerified,
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<void> updateProviderFields({
    required String providerId,
    required Map<String, dynamic> data,
    required String uid,
  }) async {
    if (providerId.trim().isEmpty) {
      throw ArgumentError(
        'Provider ID cannot be empty.',
      );
    }

    await _providers.doc(providerId.trim()).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ========================================================
  // PROVIDER SERVICES
  // providers/{providerId}/services/{serviceId}
  // ========================================================

  CollectionReference<Map<String, dynamic>> _servicesReference(
    String providerId,
  ) {
    final cleanProviderId = providerId.trim();

    if (cleanProviderId.isEmpty) {
      throw ArgumentError('Provider ID cannot be empty.');
    }

    return _providers.doc(cleanProviderId).collection('services');
  }

  /// نئی provider service add کریں۔
  Future<String> addProviderService(
    ProviderService service,
  ) async {
    final firebaseUser = _requiredFirebaseUser;

    if (firebaseUser.uid != service.providerId) {
      throw FirebaseAuthException(
        code: 'permission-denied',
        message: 'You cannot add a service for another provider.',
      );
    }

    final serviceReference = _servicesReference(service.providerId).doc();

    await serviceReference.set({
      ...service.toMap(),
      'serviceId': serviceReference.id,
      'providerId': service.providerId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    /*
     * Provider document میں categories بھی رکھیں،
     * تاکہ user-side searching آسان ہو۔
     */
    await _providers.doc(service.providerId).set({
      'serviceCategories': FieldValue.arrayUnion([
        service.category.trim(),
      ]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return serviceReference.id;
  }

  Future<String> _resolveProviderServiceDocumentId(
    ProviderService service,
  ) async {
    final services = _servicesReference(service.providerId);
    final incomingId = service.id.trim();
    if (incomingId.isNotEmpty) {
      final directDocument = await services.doc(incomingId).get();

      if (directDocument.exists) {
        return directDocument.id;
      }
      final storedIdResult = await services
          .where('serviceId', isEqualTo: incomingId)
          .limit(1)
          .get();

      if (storedIdResult.docs.isNotEmpty) {
        return storedIdResult.docs.first.id;
      }
    }

    // Legacy service mein ID empty/mismatched ho to uske existing fields se
    // sirf usi provider ke services collection mein document locate karein.
    final snapshot = await services.get();
    final cleanTitle = service.title.trim().toLowerCase();
    final cleanCategory = service.category.trim().toLowerCase();
    final cleanArea = service.serviceArea.trim().toLowerCase();

    final matchingDocuments = snapshot.docs.where((document) {
      final data = document.data();

      final title = (data['title'] ?? '').toString().trim().toLowerCase();
      final category = (data['category'] ?? '').toString().trim().toLowerCase();
      final area = (data['serviceArea'] ?? '').toString().trim().toLowerCase();

      return title == cleanTitle &&
          category == cleanCategory &&
          area == cleanArea;
    }).toList();

    if (matchingDocuments.length == 1) {
      return matchingDocuments.first.id;
    }

    throw StateError(
      matchingDocuments.isEmpty
          ? 'Existing service document could not be found.'
          : 'More than one matching service was found. Delete the duplicate service first.',
    );
  }

  Future<void> updateProviderService(ProviderService service,
      {ProviderService? originalService}) async {
    final firebaseUser = _requiredFirebaseUser;

    if (firebaseUser.uid != service.providerId) {
      throw FirebaseAuthException(
        code: 'permission-denied',
        message: 'You cannot update another provider service.',
      );
    }

    final resolvedServiceId = await _resolveProviderServiceDocumentId(service);

    await _servicesReference(
      service.providerId,
    ).doc(resolvedServiceId).set({
      ...service.toMap(),
      'serviceId': resolvedServiceId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _providers.doc(service.providerId).set({
      'serviceCategories': FieldValue.arrayUnion([
        service.category.trim(),
      ]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<ProviderService?> getProviderService({
    required String providerId,
    required String serviceId,
  }) async {
    final document = await _servicesReference(
      providerId,
    ).doc(serviceId).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return ProviderService.fromDoc(document);
  }

  Stream<List<ProviderService>> watchProviderServices(
    String providerId,
  ) {
    if (providerId.trim().isEmpty) {
      return Stream<List<ProviderService>>.value(
        const [],
      );
    }

    return _servicesReference(providerId)
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => ProviderService.fromDoc(document).copyWith(
                  id: document.id,
                ),
              )
              .toList(),
        );
  }

  Stream<List<ProviderService>> watchActiveProviderServices(
    String providerId,
  ) {
    if (providerId.trim().isEmpty) {
      return Stream<List<ProviderService>>.value(
        const [],
      );
    }

    return _servicesReference(providerId)
        .where(
          'isActive',
          isEqualTo: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => ProviderService.fromDoc(document).copyWith(
                  id: document.id,
                ),
              )
              .toList(),
        );
  }

  /// User app کے لیے category کی تمام active
  /// services حاصل کریں۔
  Stream<List<ProviderService>> watchActiveServicesByCategory(
    String category,
  ) {
    final normalizedCategory = category.trim();

    if (normalizedCategory.isEmpty) {
      return Stream<List<ProviderService>>.value(
        const [],
      );
    }

    return _db
        .collectionGroup('services')
        .where(
          'category',
          isEqualTo: normalizedCategory,
        )
        .where(
          'isActive',
          isEqualTo: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => ProviderService.fromDoc(document).copyWith(
                  id: document.id,
                ),
              )
              .toList(),
        );
  }

  Future<void> setServiceActive({
    required String providerId,
    required String serviceId,
    required bool isActive,
  }) async {
    final firebaseUser = _requiredFirebaseUser;

    if (firebaseUser.uid != providerId) {
      throw FirebaseAuthException(
        code: 'permission-denied',
        message: 'You cannot update another provider service.',
      );
    }

    await _servicesReference(providerId).doc(serviceId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteProviderService({
    required String providerId,
    required String serviceId,
  }) async {
    final firebaseUser = _requiredFirebaseUser;

    if (firebaseUser.uid != providerId) {
      throw FirebaseAuthException(
        code: 'permission-denied',
        message: 'You cannot delete another provider service.',
      );
    }

    await _servicesReference(providerId).doc(serviceId).delete();

    await _rebuildServiceCategories(
      providerId,
    );
  }

  /// Service delete یا category change ہونے کے بعد
  /// provider categories دوبارہ بناتا ہے۔
  Future<void> _rebuildServiceCategories(
    String providerId,
  ) async {
    final snapshot = await _servicesReference(providerId).get();

    final categories = snapshot.docs
        .map(
          (document) => (document.data()['category'] ?? '').toString().trim(),
        )
        .where(
          (category) => category.isNotEmpty,
        )
        .toSet()
        .toList();

    await _providers.doc(providerId).set({
      'serviceCategories': categories,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ========================================================
  // PROVIDER LIVE STATUS
  // ========================================================

  Future<void> setProviderLive({
    required String providerId,
    required bool isLive,
  }) async {
    final firebaseUser = _requiredFirebaseUser;

    if (firebaseUser.uid != providerId) {
      throw FirebaseAuthException(
        code: 'permission-denied',
        message: 'You cannot change another provider status.',
      );
    }

    /*
     * Provider کم از کم ایک active service add کیے
     * بغیر live نہیں ہوسکتا۔
     */
    if (isLive) {
      final activeServices = await _servicesReference(providerId)
          .where(
            'isActive',
            isEqualTo: true,
          )
          .limit(1)
          .get();

      if (activeServices.docs.isEmpty) {
        throw StateError(
          'Add at least one active service before going live.',
        );
      }
    }

    await _providers.doc(providerId).set({
      'isLive': isLive,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Category کے live providers۔
  ///
  /// چھوٹی MVP app کے لیے collectionGroup query کے
  /// بعد provider documents load کیے جاتے ہیں۔
  Stream<List<ProviderProfile>> watchLiveProvidersForCategory(
    String category,
  ) {
    return watchActiveServicesByCategory(
      category,
    ).asyncMap((services) async {
      final providerIds = services
          .map((service) => service.providerId)
          .where((id) => id.isNotEmpty)
          .toSet();

      final providers = <ProviderProfile>[];

      for (final providerId in providerIds) {
        final provider = await getProvider(providerId);

        if (provider != null && provider.isLive) {
          providers.add(provider);
        }
      }

      providers.sort(
        (first, second) => second.rating.compareTo(
          first.rating,
        ),
      );

      return providers;
    });
  }

  // ========================================================
  // DASHBOARD COUNTERS
  // ========================================================

  Future<void> incrementProviderCounter({
    required String providerId,
    required String field,
  }) async {
    const allowedFields = {
      'totalViews',
      'totalContacts',
      'totalBookings',
    };

    if (!allowedFields.contains(field)) {
      throw ArgumentError(
        'Invalid provider counter: $field',
      );
    }

    await _providers.doc(providerId).set({
      field: FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> incrementProfileViews(
    String providerId,
  ) {
    return incrementProviderCounter(
      providerId: providerId,
      field: 'totalViews',
    );
  }

  Future<void> incrementContacts(
    String providerId,
  ) {
    return incrementProviderCounter(
      providerId: providerId,
      field: 'totalContacts',
    );
  }

  // ========================================================
  // BOOKINGS
  // bookings/{bookingId}
  // ========================================================

  Future<String> createBooking(
    BookingRequest booking,
  ) async {
    final firebaseUser = _requiredFirebaseUser;

    if (firebaseUser.uid != booking.userId) {
      throw FirebaseAuthException(
        code: 'permission-denied',
        message: 'You cannot create a booking for another user.',
      );
    }

    final bookingReference = _bookings.doc();

    final providerReference = _providers.doc(booking.providerId);

    final batch = _db.batch();

    batch.set(bookingReference, {
      ...booking.toMap(),
      'bookingId': bookingReference.id,
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(
      providerReference,
      {
        'totalBookings': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();

    return bookingReference.id;
  }

  Stream<List<BookingRequest>> watchProviderBookings(
    String providerId,
  ) {
    if (providerId.trim().isEmpty) {
      return Stream<List<BookingRequest>>.value(
        const [],
      );
    }

    return _bookings
        .where(
          'providerId',
          isEqualTo: providerId,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(BookingRequest.fromDoc).toList(),
        );
  }

  Stream<List<BookingRequest>> watchUserBookings(
    String userId,
  ) {
    if (userId.trim().isEmpty) {
      return Stream<List<BookingRequest>>.value(
        const [],
      );
    }

    return _bookings
        .where(
          'userId',
          isEqualTo: userId,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(BookingRequest.fromDoc).toList(),
        );
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    final normalizedStatus = status.trim().toLowerCase();

    const allowedStatuses = {
      'requested',
      'accepted',
      'completed',
      'rejected',
      'cancelled',
    };

    if (!allowedStatuses.contains(
      normalizedStatus,
    )) {
      throw ArgumentError(
        'Invalid booking status: $status',
      );
    }

    await _bookings.doc(bookingId).update({
      'status': normalizedStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteBooking(
    String bookingId,
  ) async {
    await _bookings.doc(bookingId).delete();
  }

  Future<String> createProviderService(ProviderService service) {
    return addProviderService(service);
  }
}
