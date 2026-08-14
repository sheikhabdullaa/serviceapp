import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
      createdAt: _readDate(map['createdAt']),
    );
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
}

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
      rating: _readDouble(map['rating']),
      reviewCount: _readInt(map['reviewCount']),
      createdAt: _readDate(map['createdAt']),
    );
  }

  ProviderProfile copyWith({
    String? name,
    String? whatsapp,
    String? mainService,
    String? address,
    String? about,
    bool? isLive,
    bool? verified,
    double? rating,
    int? reviewCount,
  }) {
    return ProviderProfile(
      uid: uid,
      name: name ?? this.name,
      email: email,
      whatsapp: whatsapp ?? this.whatsapp,
      mainService: mainService ?? this.mainService,
      address: address ?? this.address,
      about: about ?? this.about,
      idCardNumber: idCardNumber,
      isLive: isLive ?? this.isLive,
      verified: verified ?? this.verified,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt,
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
}

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
      hourlyCharge: _readDouble(map['hourlyCharge']),
      experienceYears: _readInt(map['experienceYears']),
      serviceArea: map['serviceArea']?.toString() ?? '',
      createdAt: _readDate(map['createdAt']),
    );
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
}

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
      date: _readDate(map['date']),
      time: map['time']?.toString() ?? '',
      note: map['note']?.toString() ?? '',
      status: map['status']?.toString() ?? 'requested',
      createdAt: _readDate(map['createdAt']),
    );
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
}

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
    description: 'AC installation, repair and maintenance',
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

DateTime _readDate(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is DateTime) {
    return value;
  }

  return DateTime.now();
}

double _readDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _readInt(dynamic value) {
  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}
