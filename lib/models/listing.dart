import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerDistrict;
  final String farmerPhone;
  final String productName;
  final String category;
  final double quantity;
  final String unit;
  final double price;
  final String market;
  final String district;
  final String description;
  final String contactNumber;
  final List<String> imageUrls;
  final bool isActive;
  final DateTime createdAt;

  const Listing({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerDistrict,
    required this.farmerPhone,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.market,
    required this.district,
    required this.description,
    required this.contactNumber,
    required this.imageUrls,
    required this.isActive,
    required this.createdAt,
  });

  factory Listing.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Listing(
      id: doc.id,
      farmerId: data['farmerId'] as String? ?? '',
      farmerName: data['farmerName'] as String? ?? '',
      farmerDistrict: data['farmerDistrict'] as String? ?? '',
      farmerPhone: data['farmerPhone'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      category: data['category'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toDouble() ?? 0,
      unit: data['unit'] as String? ?? 'kg',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      market: data['market'] as String? ?? '',
      district: data['district'] as String? ?? '',
      description: data['description'] as String? ?? '',
      contactNumber: data['contactNumber'] as String? ?? '',
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'farmerId': farmerId,
        'farmerName': farmerName,
        'farmerDistrict': farmerDistrict,
        'farmerPhone': farmerPhone,
        'productName': productName,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'price': price,
        'market': market,
        'district': district,
        'description': description,
        'contactNumber': contactNumber,
        'imageUrls': imageUrls,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
