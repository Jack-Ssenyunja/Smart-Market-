import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../constants/app_constants.dart';
import '../models/listing.dart';
import '../models/models.dart';
import 'market_data_service.dart';

class FirestoreService {
  FirebaseFirestore? _db;
  final MarketDataService _marketData = MarketDataService();

  FirebaseFirestore get _firestore {
    if (_db != null) {
      return _db!;
    }

    try {
      _db = FirebaseFirestore.instance;
      return _db!;
    } catch (_) {
      throw Exception('Firebase unavailable');
    }
  }

  // ── Listings ──────────────────────────────────────────────
  Future<List<Listing>> getListings({
    String? category,
    String? district,
    String? market,
    String? search,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.listingsCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      if (district != null && district.isNotEmpty) {
        query = query.where('district', isEqualTo: district);
      }
      if (market != null && market.isNotEmpty) {
        query = query.where('market', isEqualTo: market);
      }

      final snap = await query.get();
      final listings = snap.docs.map(Listing.fromDocument).toList();

      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        return listings
            .where((l) => l.productName.toLowerCase().contains(q))
            .toList();
      }
      return listings;
    } catch (_) {
      return [];
    }
  }

  Future<List<Listing>> getFarmerListings(String farmerId) async {
    try {
      final snap = await _firestore
          .collection(AppConstants.listingsCollection)
          .where('farmerId', isEqualTo: farmerId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snap.docs.map(Listing.fromDocument).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Listing?> getListingById(String id) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.listingsCollection)
          .doc(id)
          .get();
      if (!doc.exists) return null;
      return Listing.fromDocument(doc);
    } catch (_) {
      return null;
    }
  }

  Future<void> createListing(Map<String, dynamic> data) async {
    try {
      await _firestore.collection(AppConstants.listingsCollection).add(data);
    } catch (_) {}
  }

  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(AppConstants.listingsCollection).doc(id).update(data);
    } catch (_) {}
  }

  Future<void> deleteListing(String id) async {
    try {
      await _firestore.collection(AppConstants.listingsCollection).doc(id).delete();
    } catch (_) {}
  }

  // ── Market Prices (benchmark data + optional Firestore overrides) ──
  Future<List<MarketPrice>> getMarketPrices({
    String? market,
    String? district,
    String? category,
    String? search,
  }) async {
    try {
      if (Firebase.apps.isEmpty) {
        throw Exception('Firebase app not initialized');
      }

      Query query = _firestore
          .collection(AppConstants.marketPricesCollection)
          .orderBy('lastUpdated', descending: true)
          .limit(200);

      if (market != null && market.isNotEmpty) {
        query = query.where('marketName', isEqualTo: market);
      }
      if (district != null && district.isNotEmpty) {
        query = query.where('district', isEqualTo: district);
      }
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snap = await query.get().timeout(const Duration(seconds: 2));
      if (snap.docs.isNotEmpty) {
        var prices = snap.docs.map(MarketPrice.fromDocument).toList();
        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
          prices = prices
              .where((p) => p.product.toLowerCase().contains(q))
              .toList();
        }
        return prices;
      }
    } catch (_) {
      // Fall through to local benchmark data.
    }

    return _marketData.getCurrentPrices(
      market: market,
      district: district,
      category: category,
      search: search,
    );
  }

  Future<List<PriceHistory>> getPriceHistory(
    String product, {
    String? market,
    String? district,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.priceHistoryCollection)
          .where('product', isEqualTo: product)
          .orderBy('recordedAt')
          .limit(50);
      if (market != null && market.isNotEmpty) {
        query = query.where('marketName', isEqualTo: market);
      }
      if (district != null && district.isNotEmpty) {
        query = query.where('district', isEqualTo: district);
      }
      final snap = await query.get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map(PriceHistory.fromDocument).toList();
      }
    } catch (_) {
      // Fall through to local benchmark history.
    }

    return _marketData.getPriceHistory(
      product,
      market: market,
      district: district,
    );
  }

  Future<List<String>> getDistinctProducts({
    String? market,
    String? district,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.priceHistoryCollection)
          .orderBy('product')
          .limit(200);
      if (market != null && market.isNotEmpty) {
        query = query.where('marketName', isEqualTo: market);
      }
      if (district != null && district.isNotEmpty) {
        query = query.where('district', isEqualTo: district);
      }
      final snap = await query.get();
      if (snap.docs.isNotEmpty) {
        return snap.docs
            .map((d) {
              final data = d.data() as Map<String, dynamic>?;
              return (data?['product'] as String?) ?? '';
            })
            .where((p) => p.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      }
    } catch (_) {
      // Fall through to local benchmark products.
    }

    return _marketData.getProducts(market: market, district: district);
  }

  // ── Advertisements ────────────────────────────────────────
  Future<List<Advertisement>> getAdvertisements() async {
    try {
      final snap = await _firestore
          .collection(AppConstants.advertisementsCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();
      return snap.docs.map(Advertisement.fromDocument).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> createAdvertisement(Map<String, dynamic> data) async {
    try {
      await _firestore.collection(AppConstants.advertisementsCollection).add(data);
    } catch (_) {}
  }
}