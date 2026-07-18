import 'package:cloud_firestore/cloud_firestore.dart';

class MarketPrice {
  final String id;
  final String product;
  final String marketName;
  final String district;
  final double price;
  final String unit;
  final String category;
  final DateTime lastUpdated;

  const MarketPrice({
    required this.id,
    required this.product,
    required this.marketName,
    required this.district,
    required this.price,
    required this.unit,
    required this.category,
    required this.lastUpdated,
  });

  factory MarketPrice.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MarketPrice(
      id: doc.id,
      product: data['product'] as String? ?? '',
      marketName: data['marketName'] as String? ?? '',
      district: data['district'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      unit: data['unit'] as String? ?? 'kg',
      category: data['category'] as String? ?? '',
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class PriceHistory {
  final String id;
  final String product;
  final String marketName;
  final String district;
  final double price;
  final String unit;
  final DateTime recordedAt;

  const PriceHistory({
    required this.id,
    required this.product,
    required this.marketName,
    required this.district,
    required this.price,
    required this.unit,
    required this.recordedAt,
  });

  factory PriceHistory.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PriceHistory(
      id: doc.id,
      product: data['product'] as String? ?? '',
      marketName: data['marketName'] as String? ?? '',
      district: data['district'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      unit: data['unit'] as String? ?? 'kg',
      recordedAt: (data['recordedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class Advertisement {
  final String id;
  final String farmerId;
  final String? listingId;
  final String title;
  final String description;
  final String? bannerUrl;
  final bool isActive;
  final DateTime createdAt;

  const Advertisement({
    required this.id,
    required this.farmerId,
    this.listingId,
    required this.title,
    required this.description,
    this.bannerUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory Advertisement.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Advertisement(
      id: doc.id,
      farmerId: data['farmerId'] as String? ?? '',
      listingId: data['listingId'] as String?,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      bannerUrl: data['bannerUrl'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'farmerId': farmerId,
        'listingId': listingId,
        'title': title,
        'description': description,
        'bannerUrl': bannerUrl,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
