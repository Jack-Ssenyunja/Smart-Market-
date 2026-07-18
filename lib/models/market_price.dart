import 'package:cloud_firestore/cloud_firestore.dart';

class MarketPrice {
  final String id;
  final String productName;
  final String category;
  final String district;
  final String market;
  final double averagePrice;
  final double minPrice;
  final double maxPrice;
  final String unit;
  final DateTime lastUpdated;

  MarketPrice({
    required this.id,
    required this.productName,
    required this.category,
    required this.district,
    required this.market,
    required this.averagePrice,
    required this.minPrice,
    required this.maxPrice,
    required this.unit,
    required this.lastUpdated,
  });

  /// Converts the MarketPrice object into a Map structure for Firestore writes
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'category': category,
      'district': district,
      'market': market,
      'averagePrice': averagePrice,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'unit': unit,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Rebuilds a MarketPrice object from a Firestore Map structure
  factory MarketPrice.fromMap(Map<String, dynamic> map, String documentId) {
    // Helper to safely parse numbers from dynamic inputs
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      return (value is num) ? value.toDouble() : (double.tryParse(value.toString()) ?? 0.0);
    }

    // Helper to safely parse dates from Firebase Timestamps or ISO strings
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return MarketPrice(
      id: documentId,
      productName: map['productName'] ?? '',
      category: map['category'] ?? '',
      district: map['district'] ?? '',
      market: map['market'] ?? '',
      averagePrice: parseDouble(map['averagePrice']),
      minPrice: parseDouble(map['minPrice']),
      maxPrice: parseDouble(map['maxPrice']),
      unit: map['unit'] ?? 'kg',
      lastUpdated: parseDateTime(map['lastUpdated']),
    );
  }

  /// Helper to copy the MarketPrice object with modified values
  MarketPrice copyWith({
    String? id,
    String? productName,
    String? category,
    String? district,
    String? market,
    double? averagePrice,
    double? minPrice,
    double? maxPrice,
    String? unit,
    DateTime? lastUpdated,
  }) {
    return MarketPrice(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      district: district ?? this.district,
      market: market ?? this.market,
      averagePrice: averagePrice ?? this.averagePrice,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      unit: unit ?? this.unit,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}