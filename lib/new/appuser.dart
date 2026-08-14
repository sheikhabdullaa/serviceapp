import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? dateTimeFromFirestore(dynamic value) {
  if (value == null) return null;

  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is DateTime) {
    return value;
  }

  if (value is String) {
    return DateTime.tryParse(value);
  }

  return null;
}

int intFromFirestore(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double doubleFromFirestore(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();

  return double.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

// =========================================================
// APP USER
// Firestore: users/{uid}
// =========================================================

class AppUser {
  final String uid;
  final String email;
  final String name;
  final String whatsapp;

  /// user یا provider
  final String role;

  final bool emailVerified;

  /// Normal user کے لیے signup پر true۔
  /// Provider کے لیے profile save ہونے کے بعد true۔
  final bool profileCompleted;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.whatsapp,
    required this.role,
    this.emailVerified = false,
    this.profileCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  bool get isProvider => role.trim().toLowerCase() == 'provider';

  bool get isUser => role.trim().toLowerCase() == 'user';

  factory AppUser.newAccount({
    required String uid,
    required String email,
    required String role,
  }) {
    final normalizedRole = role.trim().toLowerCase();

    return AppUser(
      uid: uid.trim(),
      email: email.trim().toLowerCase(),
      name: '',
      whatsapp: '',
      role: normalizedRole,
      emailVerified: false,
      profileCompleted: normalizedRole == 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid.trim(),
      'email': email.trim().toLowerCase(),
      'name': name.trim(),
      'whatsapp': whatsapp.trim(),
      'role': role.trim().toLowerCase(),
      'emailVerified': emailVerified,
      'profileCompleted': profileCompleted,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory AppUser.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final role = (data['role'] as String? ?? 'user').trim().toLowerCase();

    return AppUser(
      uid: (data['uid'] as String? ?? doc.id).trim(),
      email: (data['email'] as String? ?? '').trim().toLowerCase(),
      name: (data['name'] as String? ?? '').trim(),
      whatsapp: (data['whatsapp'] as String? ?? '').trim(),
      role: role,
      emailVerified: data['emailVerified'] as bool? ?? false,
      profileCompleted: data['profileCompleted'] as bool? ?? role == 'user',
      createdAt: dateTimeFromFirestore(
        data['createdAt'],
      ),
      updatedAt: dateTimeFromFirestore(
        data['updatedAt'],
      ),
    );
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? name,
    String? whatsapp,
    String? role,
    bool? emailVerified,
    bool? profileCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      whatsapp: whatsapp ?? this.whatsapp,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// =========================================================
// PROVIDER PROFILE
// Firestore: providers/{providerId}
// =========================================================

class ProviderProfile {
  final String uid;
  final String email;
  final String name;
  final String whatsapp;
  final String idCardNumber;

  /// Uploaded CNIC/ID image URL۔
  final String idCardImageUrl;

  /// Provider کی primary category۔
  final String mainService;

  final String about;
  final String address;

  /// Admin verification status۔
  final bool verified;

  /// User lists میں دکھائی دینے کا status۔
  final bool isLive;

  final int totalViews;
  final int totalContacts;
  final int totalBookings;

  final double rating;
  final int reviewCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProviderProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.whatsapp,
    required this.idCardNumber,
    required this.idCardImageUrl,
    required this.mainService,
    required this.about,
    required this.address,
    this.verified = false,
    this.isLive = false,
    this.totalViews = 0,
    this.totalContacts = 0,
    this.totalBookings = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid.trim(),
      'email': email.trim().toLowerCase(),
      'name': name.trim(),
      'whatsapp': whatsapp.trim(),
      'idCardNumber': idCardNumber.trim(),
      'idCardImageUrl': idCardImageUrl.trim(),
      'mainService': mainService.trim(),
      'about': about.trim(),
      'address': address.trim(),
      'verified': verified,
      'isLive': isLive,
      'totalViews': totalViews,
      'totalContacts': totalContacts,
      'totalBookings': totalBookings,
      'rating': rating,
      'reviewCount': reviewCount,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory ProviderProfile.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    /*
     * پرانے data میں service field ہو تو
     * اسے بھی mainService کے طور پر load کرے گا۔
     */
    final mainService =
        (data['mainService'] ?? data['service'] ?? '').toString().trim();

    return ProviderProfile(
      uid: (data['uid'] as String? ?? doc.id).trim(),
      email: (data['email'] as String? ?? '').trim().toLowerCase(),
      name: (data['name'] as String? ?? '').trim(),
      whatsapp: (data['whatsapp'] as String? ?? '').trim(),
      idCardNumber: (data['idCardNumber'] as String? ?? '').trim(),
      idCardImageUrl: (data['idCardImageUrl'] as String? ?? '').trim(),
      mainService: mainService,
      about: (data['about'] as String? ?? '').trim(),
      address: (data['address'] as String? ?? '').trim(),
      verified: data['verified'] as bool? ?? false,
      isLive: data['isLive'] as bool? ?? false,
      totalViews: intFromFirestore(
        data['totalViews'],
      ),
      totalContacts: intFromFirestore(
        data['totalContacts'],
      ),
      totalBookings: intFromFirestore(
        data['totalBookings'],
      ),
      rating: doubleFromFirestore(
        data['rating'],
      ),
      reviewCount: intFromFirestore(
        data['reviewCount'],
      ),
      createdAt: dateTimeFromFirestore(
        data['createdAt'],
      ),
      updatedAt: dateTimeFromFirestore(
        data['updatedAt'],
      ),
    );
  }

  ProviderProfile copyWith({
    String? uid,
    String? email,
    String? name,
    String? whatsapp,
    String? idCardNumber,
    String? idCardImageUrl,
    String? mainService,
    String? about,
    String? address,
    bool? verified,
    bool? isLive,
    int? totalViews,
    int? totalContacts,
    int? totalBookings,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProviderProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      whatsapp: whatsapp ?? this.whatsapp,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      idCardImageUrl: idCardImageUrl ?? this.idCardImageUrl,
      mainService: mainService ?? this.mainService,
      about: about ?? this.about,
      address: address ?? this.address,
      verified: verified ?? this.verified,
      isLive: isLive ?? this.isLive,
      totalViews: totalViews ?? this.totalViews,
      totalContacts: totalContacts ?? this.totalContacts,
      totalBookings: totalBookings ?? this.totalBookings,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static ProviderProfile? fromMap(Map<String, dynamic> map, String id) {}
}

// =========================================================
// PROVIDER SERVICE
// Firestore:
// providers/{providerId}/services/{serviceId}
// =========================================================

class ProviderService {
  final String id;
  final String providerId;
  final String providerName;

  /// Plumber, Electrician وغیرہ۔
  final String category;

  /// مثال: Home Wiring یا Fan Installation۔
  final String title;

  final String description;
  final int experienceYears;
  final double hourlyCharge;
  final String serviceArea;
  final bool isActive;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProviderService({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.category,
    required this.title,
    required this.description,
    required this.experienceYears,
    required this.hourlyCharge,
    required this.serviceArea,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id.trim().isNotEmpty) 'serviceId': id.trim(),
      'providerId': providerId.trim(),
      'providerName': providerName.trim(),
      'category': category.trim(),
      'title': title.trim(),
      'description': description.trim(),
      'experienceYears': experienceYears,
      'hourlyCharge': hourlyCharge,
      'serviceArea': serviceArea.trim(),
      'isActive': isActive,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory ProviderService.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return ProviderService(
      id: (data['serviceId'] as String? ?? doc.id).trim(),
      providerId: (data['providerId'] as String? ?? '').trim(),
      providerName: (data['providerName'] as String? ?? '').trim(),
      category: (data['category'] as String? ?? '').trim(),
      title: (data['title'] as String? ?? '').trim(),
      description: (data['description'] as String? ?? '').trim(),
      experienceYears: intFromFirestore(
        data['experienceYears'],
      ),
      hourlyCharge: doubleFromFirestore(
        data['hourlyCharge'],
      ),
      serviceArea: (data['serviceArea'] as String? ?? '').trim(),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: dateTimeFromFirestore(
        data['createdAt'],
      ),
      updatedAt: dateTimeFromFirestore(
        data['updatedAt'],
      ),
    );
  }

  ProviderService copyWith({
    String? id,
    String? providerId,
    String? providerName,
    String? category,
    String? title,
    String? description,
    int? experienceYears,
    double? hourlyCharge,
    String? serviceArea,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProviderService(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      experienceYears: experienceYears ?? this.experienceYears,
      hourlyCharge: hourlyCharge ?? this.hourlyCharge,
      serviceArea: serviceArea ?? this.serviceArea,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// =========================================================
// BOOKING REQUEST
// Firestore: bookings/{bookingId}
// =========================================================

class BookingRequest {
  final String id;

  final String userId;
  final String userName;
  final String userWhatsapp;

  final String providerId;
  final String providerName;

  final String serviceId;
  final String serviceTitle;
  final String serviceCategory;

  final DateTime date;
  final String time;
  final String note;

  /// requested, accepted, completed,
  /// rejected یا cancelled
  final String status;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookingRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userWhatsapp,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.serviceTitle,
    required this.serviceCategory,
    required this.date,
    required this.time,
    required this.note,
    this.status = 'requested',
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id.trim().isNotEmpty) 'bookingId': id.trim(),
      'userId': userId.trim(),
      'userName': userName.trim(),
      'userWhatsapp': userWhatsapp.trim(),
      'providerId': providerId.trim(),
      'providerName': providerName.trim(),
      'serviceId': serviceId.trim(),
      'serviceTitle': serviceTitle.trim(),
      'serviceCategory': serviceCategory.trim(),
      'date': Timestamp.fromDate(date),
      'time': time.trim(),
      'note': note.trim(),
      'status': status.trim().toLowerCase(),
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory BookingRequest.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return BookingRequest(
      id: (data['bookingId'] as String? ?? doc.id).trim(),
      userId: (data['userId'] as String? ?? '').trim(),
      userName: (data['userName'] as String? ?? '').trim(),
      userWhatsapp: (data['userWhatsapp'] as String? ?? '').trim(),
      providerId: (data['providerId'] as String? ?? '').trim(),
      providerName: (data['providerName'] as String? ?? '').trim(),
      serviceId: (data['serviceId'] as String? ?? '').trim(),
      serviceTitle:
          (data['serviceTitle'] ?? data['service'] ?? '').toString().trim(),
      serviceCategory: (data['serviceCategory'] as String? ?? '').trim(),
      date: dateTimeFromFirestore(data['date']) ?? DateTime.now(),
      time: (data['time'] as String? ?? '').trim(),
      note: (data['note'] as String? ?? '').trim(),
      status: (data['status'] as String? ?? 'requested').trim().toLowerCase(),
      createdAt: dateTimeFromFirestore(
        data['createdAt'],
      ),
      updatedAt: dateTimeFromFirestore(
        data['updatedAt'],
      ),
    );
  }

  BookingRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userWhatsapp,
    String? providerId,
    String? providerName,
    String? serviceId,
    String? serviceTitle,
    String? serviceCategory,
    DateTime? date,
    String? time,
    String? note,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userWhatsapp: userWhatsapp ?? this.userWhatsapp,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      serviceId: serviceId ?? this.serviceId,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      date: date ?? this.date,
      time: time ?? this.time,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
