// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:service_hub/new/appuser.dart';
// import 'package:service_hub/new/user_model.dart' hide BookingRequest, ProviderProfile, ProviderService;

// import '../model/model.dart';

// class FirestoreService {
//   FirestoreService._();

//   static final FirestoreService instance = FirestoreService._();

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   CollectionReference<Map<String, dynamic>> get _usersCollection =>
//       _firestore.collection('users');

//   CollectionReference<Map<String, dynamic>> get _providersCollection =>
//       _firestore.collection('providers');

//   CollectionReference<Map<String, dynamic>> get _servicesCollection =>
//       _firestore.collection('providerServices');

//   CollectionReference<Map<String, dynamic>> get _bookingsCollection =>
//       _firestore.collection('bookings');

//   // ---------------- USERS ----------------

//   Future<void> createOrUpdateUser(
//     UserModel user,
//   ) async {
//     await _usersCollection.doc(user.uid).set(
//           user.toMap(),
//           SetOptions(merge: true),
//         );
//   }

//   Stream<UserModel?> watchUser(String uid) {
//     return _usersCollection.doc(uid).snapshots().map(
//       (document) {
//         if (!document.exists || document.data() == null) {
//           return null;
//         }

//         return UserModel.fromMap(
//           document.data()!,
//           document.id,
//         );
//       },
//     );
//   }

//   Future<UserModel?> getUser(String uid) async {
//     final document = await _usersCollection.doc(uid).get();

//     if (!document.exists || document.data() == null) {
//       return null;
//     }

//     return UserModel.fromMap(
//       document.data()!,
//       document.id,
//     );
//   }

//   Future<void> updateUserFields({
//     required String uid,
//     required Map<String, dynamic> data,
//   }) async {
//     await _usersCollection.doc(uid).set(
//           data,
//           SetOptions(merge: true),
//         );
//   }

//   // ---------------- PROVIDERS ----------------

//   Future<void> createOrUpdateProvider(
//     ProviderProfile provider,
//   ) async {
//     await _providersCollection.doc(provider.uid).set(
//           provider.toMap(),
//           SetOptions(merge: true),
//         );
//   }

//   Stream<ProviderProfile?> watchProvider(
//     String providerId,
//   ) {
//     return _providersCollection.doc(providerId).snapshots().map(
//       (document) {
//         if (!document.exists || document.data() == null) {
//           return null;
//         }

//         return ProviderProfile.fromMap(
//           document.data()!,
//           document.id,
//         );
//       },
//     );
//   }

//   Future<ProviderProfile?> getProvider(
//     String providerId,
//   ) async {
//     final document = await _providersCollection.doc(providerId).get();

//     if (!document.exists || document.data() == null) {
//       return null;
//     }

//     return ProviderProfile.fromMap(
//       document.data()!,
//       document.id,
//     );
//   }

//   Future<void> updateProviderFields({
//     required String uid,
//     required Map<String, dynamic> data,
//   }) async {
//     await _providersCollection.doc(uid).set(
//           data,
//           SetOptions(merge: true),
//         );
//   }

//   Stream<List<ProviderProfile>> watchLiveProvidersForCategory(
//     String category,
//   ) {
//     return _providersCollection
//         .where('mainService', isEqualTo: category)
//         .where('isLive', isEqualTo: true)
//         .snapshots()
//         .map(
//       (snapshot) {
//         final providers = snapshot.docs
//             .map(
//               (document) => ProviderProfile.fromMap(
//                 document.data(),
//                 document.id,
//               ),
//             )
//             .toList();

//         providers.sort(
//           (a, b) => b.rating.compareTo(a.rating),
//         );

//         return providers;
//       },
//     );
//   }

//   // ---------------- PROVIDER SERVICES ----------------

//   Future<void> createProviderService(
//     ProviderService service,
//   ) async {
//     final document = _servicesCollection.doc();

//     final data = service.toMap();

//     data['providerId'] = service.providerId;
//     data['createdAt'] = FieldValue.serverTimestamp();

//     await document.set(data);
//   }

//   Future<void> updateProviderService(
//     ProviderService service,
//   ) async {
//     final data = service.toMap();

//     data['providerId'] = service.providerId;

//     await _servicesCollection.doc(service.id).set(
//           data,
//           SetOptions(merge: true),
//         );
//   }

//   Future<void> deleteProviderService({
//     required String serviceId,
//   }) async {
//     await _servicesCollection.doc(serviceId).delete();
//   }

//   Stream<List<ProviderService>> watchProviderServices(
//     String providerId,
//   ) {
//     return _servicesCollection
//         .where('providerId', isEqualTo: providerId)
//         .snapshots()
//         .map(
//       (snapshot) {
//         final services = snapshot.docs
//             .map(
//               (document) => ProviderService.fromMap(
//                 document.data(),
//                 document.id,
//               ),
//             )
//             .toList();

//         services.sort(
//           (a, b) => b.createdAt.compareTo(a.createdAt),
//         );

//         return services;
//       },
//     );
//   }

//   // ---------------- BOOKINGS ----------------

//   Future<void> createBooking(
//     BookingRequest booking,
//   ) async {
//     final document = _bookingsCollection.doc();

//     final data = booking.toMap();

//     data['providerId'] = booking.providerId;
//     data['userId'] = booking.userId;
//     data['status'] = 'requested';
//     data['createdAt'] = FieldValue.serverTimestamp();

//     await document.set(data);
//   }

//   Future<void> updateBookingStatus({
//     required String bookingId,
//     required String status,
//   }) async {
//     await _bookingsCollection.doc(bookingId).update({
//       'status': status,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Stream<List<BookingRequest>> watchProviderBookings(
//     String providerId,
//   ) {
//     return _bookingsCollection
//         .where('providerId', isEqualTo: providerId)
//         .snapshots()
//         .map(
//       (snapshot) {
//         final bookings = snapshot.docs
//             .map(
//               (document) => BookingRequest.fromMap(
//                 document.data(),
//                 document.id,
//               ),
//             )
//             .toList();

//         bookings.sort(
//           (a, b) => b.createdAt.compareTo(a.createdAt),
//         );

//         return bookings;
//       },
//     );
//   }

//   Stream<List<BookingRequest>> watchUserBookings(
//     String userId,
//   ) {
//     return _bookingsCollection
//         .where('userId', isEqualTo: userId)
//         .snapshots()
//         .map(
//       (snapshot) {
//         final bookings = snapshot.docs
//             .map(
//               (document) => BookingRequest.fromMap(
//                 document.data(),
//                 document.id,
//               ),
//             )
//             .toList();

//         bookings.sort(
//           (a, b) => b.createdAt.compareTo(a.createdAt),
//         );

//         return bookings;
//       },
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// =====================================================
// USER MODEL
// =====================================================

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String whatsapp;
  final String role;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.whatsapp,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return UserModel(
      uid: id,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      whatsapp: map['whatsapp']?.toString() ?? '',
      role: map['role']?.toString() ?? 'user',
      createdAt: _dateFromValue(map['createdAt']),
    );
  }

  factory UserModel.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    return UserModel.fromMap(json, id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'whatsapp': whatsapp,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toJson() => toMap();
}

// =====================================================
// PROVIDER PROFILE MODEL
// =====================================================

class ProviderProfile {
  final String uid;
  final String name;
  final String email;
  final String whatsapp;
  final String mainService;
  final String address;
  final String about;
  final String idCardNumber;
  final bool isLive;
  final bool verified;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;

  const ProviderProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.whatsapp,
    required this.mainService,
    required this.address,
    required this.about,
    required this.idCardNumber,
    required this.isLive,
    required this.verified,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
  });

  factory ProviderProfile.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return ProviderProfile(
      uid: id,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      whatsapp: map['whatsapp']?.toString() ?? '',
      mainService: map['mainService']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      about: map['about']?.toString() ?? '',
      idCardNumber: map['idCardNumber']?.toString() ?? '',
      isLive: map['isLive'] == true,
      verified: map['verified'] == true,
      rating: _doubleFromValue(map['rating']),
      reviewCount: _intFromValue(map['reviewCount']),
      createdAt: _dateFromValue(map['createdAt']),
    );
  }

  factory ProviderProfile.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    return ProviderProfile.fromMap(json, id);
  }

  ProviderProfile copyWith({
    String? name,
    String? email,
    String? whatsapp,
    String? mainService,
    String? address,
    String? about,
    String? idCardNumber,
    bool? isLive,
    bool? verified,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
  }) {
    return ProviderProfile(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      whatsapp: whatsapp ?? this.whatsapp,
      mainService: mainService ?? this.mainService,
      address: address ?? this.address,
      about: about ?? this.about,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      isLive: isLive ?? this.isLive,
      verified: verified ?? this.verified,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'whatsapp': whatsapp,
      'mainService': mainService,
      'address': address,
      'about': about,
      'idCardNumber': idCardNumber,
      'isLive': isLive,
      'verified': verified,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toJson() => toMap();
}

// =====================================================
// PROVIDER SERVICE MODEL
// =====================================================

class ProviderService {
  final String id;
  final String providerId;
  final String title;
  final String category;
  final String description;
  final double hourlyCharge;
  final int experienceYears;
  final String serviceArea;
  final DateTime createdAt;

  const ProviderService({
    required this.id,
    required this.providerId,
    required this.title,
    required this.category,
    required this.description,
    required this.hourlyCharge,
    required this.experienceYears,
    required this.serviceArea,
    required this.createdAt,
  });

  factory ProviderService.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return ProviderService(
      id: id,
      providerId: map['providerId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      hourlyCharge: _doubleFromValue(
        map['hourlyCharge'],
      ),
      experienceYears: _intFromValue(
        map['experienceYears'],
      ),
      serviceArea: map['serviceArea']?.toString() ?? '',
      createdAt: _dateFromValue(map['createdAt']),
    );
  }

  factory ProviderService.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    return ProviderService.fromMap(json, id);
  }

  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'title': title,
      'category': category,
      'description': description,
      'hourlyCharge': hourlyCharge,
      'experienceYears': experienceYears,
      'serviceArea': serviceArea,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toJson() => toMap();
}

// =====================================================
// BOOKING REQUEST MODEL
// =====================================================

class BookingRequest {
  final String id;
  final String providerId;
  final String providerName;
  final String providerWhatsapp;
  final String userId;
  final String userName;
  final String userWhatsapp;
  final String serviceId;
  final String serviceTitle;
  final String serviceCategory;
  final DateTime date;
  final String time;
  final String note;
  final String status;
  final DateTime createdAt;

  const BookingRequest({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.providerWhatsapp,
    required this.userId,
    required this.userName,
    required this.userWhatsapp,
    required this.serviceId,
    required this.serviceTitle,
    required this.serviceCategory,
    required this.date,
    required this.time,
    required this.note,
    required this.status,
    required this.createdAt,
  });

  factory BookingRequest.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return BookingRequest(
      id: id,
      providerId: map['providerId']?.toString() ?? '',
      providerName: map['providerName']?.toString() ?? '',
      providerWhatsapp: map['providerWhatsapp']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      userWhatsapp: map['userWhatsapp']?.toString() ?? '',
      serviceId: map['serviceId']?.toString() ?? '',
      serviceTitle: map['serviceTitle']?.toString() ?? '',
      serviceCategory: map['serviceCategory']?.toString() ?? '',
      date: _dateFromValue(map['date']),
      time: map['time']?.toString() ?? '',
      note: map['note']?.toString() ?? '',
      status: map['status']?.toString() ?? 'requested',
      createdAt: _dateFromValue(map['createdAt']),
    );
  }

  factory BookingRequest.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    return BookingRequest.fromMap(json, id);
  }

  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'providerName': providerName,
      'providerWhatsapp': providerWhatsapp,
      'userId': userId,
      'userName': userName,
      'userWhatsapp': userWhatsapp,
      'serviceId': serviceId,
      'serviceTitle': serviceTitle,
      'serviceCategory': serviceCategory,
      'date': Timestamp.fromDate(date),
      'time': time,
      'note': note,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toJson() => toMap();
}

// =====================================================
// SERVICE CATEGORIES
// =====================================================

class ServiceCategory {
  final String name;
  final String description;
  final IconData icon;

  const ServiceCategory({
    required this.name,
    required this.description,
    required this.icon,
  });
}

const List<ServiceCategory> kServiceCategories = [
  ServiceCategory(
    name: 'Plumber',
    description: 'Pipes, leakage and bathroom repairs',
    icon: Icons.plumbing_outlined,
  ),
  ServiceCategory(
    name: 'Electrician',
    description: 'Wiring, switches and electrical repairs',
    icon: Icons.electrical_services_outlined,
  ),
  ServiceCategory(
    name: 'Carpenter',
    description: 'Furniture, doors and woodwork',
    icon: Icons.carpenter_outlined,
  ),
  ServiceCategory(
    name: 'Painter',
    description: 'Home, office and wall painting',
    icon: Icons.format_paint_outlined,
  ),
  ServiceCategory(
    name: 'Driver',
    description: 'Personal, family and travel driving',
    icon: Icons.drive_eta_outlined,
  ),
  ServiceCategory(
    name: 'AC Technician',
    description: 'AC repair and maintenance',
    icon: Icons.ac_unit_outlined,
  ),
  ServiceCategory(
    name: 'Other',
    description: 'Other local professional services',
    icon: Icons.miscellaneous_services_outlined,
  ),
];

ServiceCategory serviceCategoryByName(String name) {
  return kServiceCategories.firstWhere(
    (category) => category.name.toLowerCase() == name.trim().toLowerCase(),
    orElse: () => kServiceCategories.last,
  );
}

// =====================================================
// FIRESTORE DATA CONVERTERS
// =====================================================

DateTime _dateFromValue(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is DateTime) {
    return value;
  }

  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }

  return DateTime.now();
}

double _doubleFromValue(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

int _intFromValue(dynamic value) {
  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}
