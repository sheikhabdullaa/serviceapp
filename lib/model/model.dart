// import 'package:cloud_firestore/cloud_firestore.dart';

// /// Firestore Timestamp کو محفوظ طریقے سے DateTime میں بدلتا ہے۔
// DateTime? _dateTimeFromFirestore(dynamic value) {
//   if (value == null) return null;

//   if (value is Timestamp) {
//     return value.toDate();
//   }

//   if (value is DateTime) {
//     return value;
//   }

//   if (value is String) {
//     return DateTime.tryParse(value);
//   }

//   return null;
// }

// /// Firestore number کو محفوظ طریقے سے int میں بدلتا ہے۔
// int _intFromFirestore(dynamic value) {
//   if (value is int) return value;

//   if (value is num) {
//     return value.toInt();
//   }

//   if (value is String) {
//     return int.tryParse(value) ?? 0;
//   }

//   return 0;
// }

// /// Firestore number کو محفوظ طریقے سے double میں بدلتا ہے۔
// double _doubleFromFirestore(dynamic value) {
//   if (value is double) return value;

//   if (value is num) {
//     return value.toDouble();
//   }

//   if (value is String) {
//     return double.tryParse(value) ?? 0;
//   }

//   return 0;
// }

// // ===========================================================
// // APP USER
// // Firestore path: users/{uid}
// // ===========================================================

// /// User اور Provider دونوں کا basic account.
// ///
// /// `role`:
// /// user یا provider
// ///
// /// `profileCompleted`:
// /// normal user کے لیے true
// /// provider registration کے وقت false
// /// provider profile save ہونے کے بعد true
// class AppUser {
//   final String uid;
//   final String email;
//   final String name;
//   final String whatsapp;
//   final String role;
//   final bool emailVerified;
//   final bool profileCompleted;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;

//   const AppUser({
//     required this.uid,
//     required this.email,
//     required this.name,
//     required this.whatsapp,
//     required this.role,
//     this.emailVerified = false,
//     this.profileCompleted = false,
//     this.createdAt,
//     this.updatedAt,
//   });

//   /// New AppUser بنانے کے لیے آسان factory۔
//   factory AppUser.newAccount({
//     required String uid,
//     required String email,
//     required String role,
//     String name = '',
//     String whatsapp = '',
//   }) {
//     final normalizedRole = role.trim().toLowerCase();

//     return AppUser(
//       uid: uid.trim(),
//       email: email.trim().toLowerCase(),
//       name: name.trim(),
//       whatsapp: whatsapp.trim(),
//       role: normalizedRole,
//       emailVerified: false,

//       // User کو provider profile setup کی ضرورت نہیں۔
//       profileCompleted: normalizedRole == 'user',
//     );
//   }

//   /// Firestore میں save کرنے کے لیے map۔
//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'email': email.trim().toLowerCase(),
//       'name': name.trim(),
//       'whatsapp': whatsapp.trim(),
//       'role': role.trim().toLowerCase(),
//       'emailVerified': emailVerified,
//       'profileCompleted': profileCompleted,

//       /*
//        * اگر createdAt پہلے سے موجود ہو تو وہی save ہوگا۔
//        * نیا document ہو تو server timestamp استعمال ہوگا۔
//        */
//       'createdAt': createdAt != null
//           ? Timestamp.fromDate(createdAt!)
//           : FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     };
//   }

//   factory AppUser.fromDoc(
//     DocumentSnapshot<Map<String, dynamic>> document,
//   ) {
//     final data = document.data() ?? {};

//     final role = (data['role'] as String? ?? 'user').trim().toLowerCase();

//     return AppUser(
//       uid: (data['uid'] as String? ?? document.id).trim(),
//       email: (data['email'] as String? ?? '').trim().toLowerCase(),
//       name: (data['name'] as String? ?? '').trim(),
//       whatsapp: (data['whatsapp'] as String? ?? '').trim(),
//       role: role,
//       emailVerified: data['emailVerified'] as bool? ?? false,

//       /*
//        * پرانے normal users میں یہ field نہ ہو تو
//        * role user ہونے کی صورت میں true مانا جائے گا۔
//        */
//       profileCompleted: data['profileCompleted'] as bool? ?? role == 'user',
//       createdAt: _dateTimeFromFirestore(
//         data['createdAt'],
//       ),
//       updatedAt: _dateTimeFromFirestore(
//         data['updatedAt'],
//       ),
//     );
//   }

//   AppUser copyWith({
//     String? uid,
//     String? email,
//     String? name,
//     String? whatsapp,
//     String? role,
//     bool? emailVerified,
//     bool? profileCompleted,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return AppUser(
//       uid: uid ?? this.uid,
//       email: email ?? this.email,
//       name: name ?? this.name,
//       whatsapp: whatsapp ?? this.whatsapp,
//       role: role ?? this.role,
//       emailVerified: emailVerified ?? this.emailVerified,
//       profileCompleted: profileCompleted ?? this.profileCompleted,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
// }

// // ===========================================================
// // PROVIDER PROFILE
// // Firestore path: providers/{uid}
// // ===========================================================

// /// Provider کی public profile.
// ///
// /// users/{uid} account routing کے لیے ہے۔
// /// providers/{uid} provider کی public details کے لیے ہے۔
// class ProviderProfile {
//   final String uid;
//   final String name;
//   final String whatsapp;
//   final String idCardNumber;
//   final String service;
//   final String about;

//   /// Provider کا address
//   final String address;

//   /// Firebase Storage میں uploaded CNIC image URL
//   final String cnicImageUrl;

//   final bool verified;
//   final bool isLive;

//   final int totalViews;
//   final int totalContacts;
//   final int totalBookings;

//   final double rating;
//   final int reviewCount;

//   final DateTime? createdAt;
//   final DateTime? updatedAt;

//   const ProviderProfile({
//     required this.uid,
//     required this.name,
//     required this.whatsapp,
//     required this.idCardNumber,
//     required this.service,
//     required this.about,
//     this.address = '',
//     this.cnicImageUrl = '',
//     this.verified = false,
//     this.isLive = false,
//     this.totalViews = 0,
//     this.totalContacts = 0,
//     this.totalBookings = 0,
//     this.rating = 0,
//     this.reviewCount = 0,
//     this.createdAt,
//     this.updatedAt,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid.trim(),
//       'name': name.trim(),
//       'whatsapp': whatsapp.trim(),
//       'idCardNumber': idCardNumber.trim(),

//       /*
//        * FirestoreService provider list میں بھی
//        * یہی field name استعمال کر رہا ہے۔
//        */
//       'service': service.trim(),
//       'about': about.trim(),
//       'address': address.trim(),
//       'cnicImageUrl': cnicImageUrl.trim(),
//       'verified': verified,
//       'isLive': isLive,
//       'totalViews': totalViews,
//       'totalContacts': totalContacts,
//       'totalBookings': totalBookings,
//       'rating': rating,
//       'reviewCount': reviewCount,
//       'createdAt': createdAt != null
//           ? Timestamp.fromDate(createdAt!)
//           : FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     };
//   }

//   factory ProviderProfile.fromDoc(
//     DocumentSnapshot<Map<String, dynamic>> document,
//   ) {
//     final data = document.data() ?? {};

//     return ProviderProfile(
//       uid: (data['uid'] as String? ?? document.id).trim(),
//       name: (data['name'] as String? ?? '').trim(),
//       whatsapp: (data['whatsapp'] as String? ?? '').trim(),
//       idCardNumber: (data['idCardNumber'] as String? ?? '').trim(),
//       service: (data['service'] as String? ?? '').trim(),
//       about: (data['about'] as String? ?? '').trim(),
//       address: (data['address'] as String? ?? '').trim(),
//       cnicImageUrl: (data['cnicImageUrl'] as String? ?? '').trim(),
//       verified: data['verified'] as bool? ?? false,
//       isLive: data['isLive'] as bool? ?? false,
//       totalViews: _intFromFirestore(
//         data['totalViews'],
//       ),
//       totalContacts: _intFromFirestore(
//         data['totalContacts'],
//       ),
//       totalBookings: _intFromFirestore(
//         data['totalBookings'],
//       ),
//       rating: _doubleFromFirestore(
//         data['rating'],
//       ),
//       reviewCount: _intFromFirestore(
//         data['reviewCount'],
//       ),
//       createdAt: _dateTimeFromFirestore(
//         data['createdAt'],
//       ),
//       updatedAt: _dateTimeFromFirestore(
//         data['updatedAt'],
//       ),
//     );
//   }

//   ProviderProfile copyWith({
//     String? uid,
//     String? name,
//     String? whatsapp,
//     String? idCardNumber,
//     String? service,
//     String? about,
//     String? address,
//     String? cnicImageUrl,
//     bool? verified,
//     bool? isLive,
//     int? totalViews,
//     int? totalContacts,
//     int? totalBookings,
//     double? rating,
//     int? reviewCount,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return ProviderProfile(
//       uid: uid ?? this.uid,
//       name: name ?? this.name,
//       whatsapp: whatsapp ?? this.whatsapp,
//       idCardNumber: idCardNumber ?? this.idCardNumber,
//       service: service ?? this.service,
//       about: about ?? this.about,
//       address: address ?? this.address,
//       cnicImageUrl: cnicImageUrl ?? this.cnicImageUrl,
//       verified: verified ?? this.verified,
//       isLive: isLive ?? this.isLive,
//       totalViews: totalViews ?? this.totalViews,
//       totalContacts: totalContacts ?? this.totalContacts,
//       totalBookings: totalBookings ?? this.totalBookings,
//       rating: rating ?? this.rating,
//       reviewCount: reviewCount ?? this.reviewCount,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
// }

// // ===========================================================
// // BOOKING REQUEST
// // Firestore path: bookings/{bookingId}
// // ===========================================================

// class BookingRequest {
//   final String id;
//   final String userId;
//   final String userName;
//   final String providerId;
//   final String providerName;
//   final String service;
//   final DateTime date;
//   final String time;
//   final String note;

//   /// requested
//   /// accepted
//   /// completed
//   /// rejected
//   /// cancelled
//   final String status;

//   final DateTime? createdAt;
//   final DateTime? updatedAt;

//   const BookingRequest({
//     required this.id,
//     required this.userId,
//     required this.userName,
//     required this.providerId,
//     required this.providerName,
//     required this.service,
//     required this.date,
//     required this.time,
//     required this.note,
//     this.status = 'requested',
//     this.createdAt,
//     this.updatedAt,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       if (id.trim().isNotEmpty) 'bookingId': id.trim(),
//       'userId': userId.trim(),
//       'userName': userName.trim(),
//       'providerId': providerId.trim(),
//       'providerName': providerName.trim(),
//       'service': service.trim(),
//       'date': Timestamp.fromDate(date),
//       'time': time.trim(),
//       'note': note.trim(),
//       'status': status.trim().toLowerCase(),
//       'createdAt': createdAt != null
//           ? Timestamp.fromDate(createdAt!)
//           : FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     };
//   }

//   factory BookingRequest.fromDoc(
//     DocumentSnapshot<Map<String, dynamic>> document,
//   ) {
//     final data = document.data() ?? {};

//     /*
//      * پرانے یا incomplete document میں date موجود
//      * نہ ہو تو crash نہیں ہوگا۔
//      */
//     final bookingDate = _dateTimeFromFirestore(data['date']) ?? DateTime.now();

//     return BookingRequest(
//       id: (data['bookingId'] as String? ?? document.id).trim(),
//       userId: (data['userId'] as String? ?? '').trim(),
//       userName: (data['userName'] as String? ?? '').trim(),
//       providerId: (data['providerId'] as String? ?? '').trim(),
//       providerName: (data['providerName'] as String? ?? '').trim(),
//       service: (data['service'] as String? ?? '').trim(),
//       date: bookingDate,
//       time: (data['time'] as String? ?? '').trim(),
//       note: (data['note'] as String? ?? '').trim(),
//       status: (data['status'] as String? ?? 'requested').trim().toLowerCase(),
//       createdAt: _dateTimeFromFirestore(
//         data['createdAt'],
//       ),
//       updatedAt: _dateTimeFromFirestore(
//         data['updatedAt'],
//       ),
//     );
//   }

//   BookingRequest copyWith({
//     String? id,
//     String? userId,
//     String? userName,
//     String? providerId,
//     String? providerName,
//     String? service,
//     DateTime? date,
//     String? time,
//     String? note,
//     String? status,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return BookingRequest(
//       id: id ?? this.id,
//       userId: userId ?? this.userId,
//       userName: userName ?? this.userName,
//       providerId: providerId ?? this.providerId,
//       providerName: providerName ?? this.providerName,
//       service: service ?? this.service,
//       date: date ?? this.date,
//       time: time ?? this.time,
//       note: note ?? this.note,
//       status: status ?? this.status,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
// }
