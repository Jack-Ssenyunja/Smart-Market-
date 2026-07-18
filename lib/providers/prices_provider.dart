import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class PricesProvider extends ChangeNotifier {
  final FirestoreService _firestore;
  final StorageService _storage;
  final Uuid _uuid = const Uuid();

  PricesProvider(this._firestore, this._storage);

  List<MarketPrice> _prices = [];
  List<PriceHistory> _history = [];
  List<String> _products = [];
  String _selectedProduct = '';
  bool _isLoading = false;
  String _error = '';

  List<MarketPrice> get prices => _prices;
  List<PriceHistory> get history => _history;
  List<String> get products => _products;
  String get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String get error => _error;

  Map<String, List<MarketPrice>> get pricesByMarket {
    final grouped = <String, List<MarketPrice>>{};
    for (final p in _prices) {
      grouped.putIfAbsent(p.marketName, () => []).add(p);
    }
    return grouped;
  }

  /// Adds a market price benchmark routing cleanly through [FirestoreService]
  Future<bool> addMarketPrice({
    required String product,
    required String category,
    required String marketName,
    required double price,
    required String unit,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      // Directs the database write through your clean FirestoreService instance
      await _firestore.createListing({
        'productName': product,
        'category': category,
        'market': marketName,
        'price': price,
        'unit': unit,
        'isActive': true,
        'createdAt': Timestamp.now(),
      });
      
      // Reload the local listings/prices instantly
      await loadPrices(); 
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPrices({String? market, String? category, String? search}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      _prices = await _firestore.getMarketPrices(
          market: market, category: category, search: search);
    } on Exception catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts() async {
    _products = await _firestore.getDistinctProducts();
    if (_products.isNotEmpty && _selectedProduct.isEmpty) {
      _selectedProduct = _products.first;
    }
    notifyListeners();
  }

  Future<void> loadHistory(String product) async {
    _selectedProduct = product;
    _isLoading = true;
    notifyListeners();
    try {
      _history = await _firestore.getPriceHistory(product);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double get maxPrice =>
      _history.isEmpty ? 0 : _history.map((h) => h.price).reduce((a, b) => a > b ? a : b);
  double get minPrice =>
      _history.isEmpty ? 0 : _history.map((h) => h.price).reduce((a, b) => a < b ? a : b);
  double get avgPrice => _history.isEmpty
      ? 0
      : _history.map((h) => h.price).reduce((a, b) => a + b) / _history.length;

  Future<bool> createAd({
    required String farmerId,
    required String? listingId,
    required String title,
    required String description,
    required File? bannerFile,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      String? bannerUrl;
      if (bannerFile != null) {
        final filename = '${farmerId}_${_uuid.v4()}.jpg';
        bannerUrl = await _storage.uploadImage(
            bannerFile, AppConstants.advertisementsBucket, filename);
      }
      await _firestore.createAdvertisement({
        'farmerId': farmerId,
        'listingId': listingId,
        'title': title,
        'description': description,
        'bannerUrl': bannerUrl,
        'isActive': true,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}