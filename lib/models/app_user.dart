import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { farmer, buyer }

class AppUser {
  final String uid;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String district;
  final UserRole role;
  final List<String> preferredProducts;
  final String? avatarUrl;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.district,
    required this.role,
    this.preferredProducts = const [],
    this.avatarUrl,
    required this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        uid: map['uid'] as String,
        fullName: map['fullName'] as String? ?? '',
        phoneNumber: map['phoneNumber'] as String? ?? '',
        email: map['email'] as String? ?? '',
        district: map['district'] as String? ?? '',
        role: (map['role'] as String?) == 'Farmer' ? UserRole.farmer : UserRole.buyer,
        preferredProducts: (map['preferredProducts'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        avatarUrl: map['avatarUrl'] as String?,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'email': email,
        'district': district,
        'role': role == UserRole.farmer ? 'Farmer' : 'Buyer',
        'preferredProducts': preferredProducts,
        'avatarUrl': avatarUrl,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  bool get isFarmer => role == UserRole.farmer;
}
