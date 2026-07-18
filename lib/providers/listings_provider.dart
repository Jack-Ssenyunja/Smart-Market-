import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/listing.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';

class ListingsProvider extends ChangeNotifier {
  final FirestoreService _firestore;
  final StorageService _storage;
  final Uuid _uuid = const Uuid();

  ListingsProvider(this._firestore, this._storage);

  List<Listing> _listings = [];
  List<Listing> _myListings = [];
  Listing? _selectedListing;
  bool _isLoading = false;
  String _error = '';

  List<Listing> get listings => _listings;
  List<Listing> get myListings => _myListings;
  Listing? get selectedListing => _selectedListing;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadListings({
    String? category, String? district, String? market, String? search,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      _listings = await _firestore.getListings(
        category: category, district: district, market: market, search: search,
      );
    } on Exception catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyListings(String farmerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _myListings = await _firestore.getFarmerListings(farmerId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadListingById(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _selectedListing = await _firestore.getListingById(id);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createListing({
    required String farmerId,
    required String farmerName,
    required String farmerDistrict,
    required String farmerPhone,
    required String productName,
    required String category,
    required double quantity,
    required String unit,
    required double price,
    required String market,
    required String district,
    required String description,
    required String contactNumber,
    required List<File> images,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      final imageUrls = <String>[];
      for (final img in images) {
        final filename = '${farmerId}_${_uuid.v4()}.jpg';
        final url = await _storage.uploadImage(img, AppConstants.listingImagesBucket, filename);
        imageUrls.add(url);
      }
      await _firestore.createListing({
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
        'isActive': true,
        'createdAt': DateTime.now(),
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

  Future<bool> updateListing(String id, Map<String, dynamic> updates) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore.updateListing(id, updates);
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteListing(String id) async {
    await _firestore.deleteListing(id);
    _myListings.removeWhere((l) => l.id == id);
    _listings.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
