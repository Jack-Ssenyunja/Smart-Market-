import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService) {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  AppUser? _user;
  bool _isLoading = true;
  String _error = '';
  String _verificationId = '';

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isAuthenticated => _user != null;

  void _clearError() {
    _error = '';
  }

  // FIXED: Safeguarded with try-catch and a timeout 
  Future<void> _onAuthChanged(User? firebaseUser) async {
    try {
      if (firebaseUser != null) {
        // Limit Firestore fetching to 5 seconds so it doesn't freeze the app on network issues
        final appUser = await _authService
            .fetchUser(firebaseUser.uid)
            .timeout(const Duration(seconds: 5));
        _user = appUser;
      } else {
        _user = null;
      }
    } catch (e) {
      debugPrint('Error fetching user profile from Firestore: $e');
      // Set a fallback user profile so the app doesn't break, 
      // or simply leave _user null while keeping authentication active.
      _user = AppUser(
        uid: firebaseUser?.uid ?? '',
        fullName: firebaseUser?.displayName ?? 'User',
        phoneNumber: firebaseUser?.phoneNumber ?? '',
        email: firebaseUser?.email ?? '',
        district: 'Unknown',
        role: UserRole.buyer,
        createdAt: DateTime.now(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String district,
    required UserRole role,
    List<String> preferredProducts = const [],
  }) async {
    _clearError();
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        district: district,
        role: role,
        preferredProducts: preferredProducts,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _clearError();
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signInWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> sendOtp(String phone, {required void Function(String) onCodeSent}) async {
    _clearError();
    notifyListeners();
    await _authService.sendOtp(
      phoneNumber: phone,
      onCodeSent: (vid) {
        _verificationId = vid;
        onCodeSent(vid);
      },
      onError: (e) {
        _error = e;
        notifyListeners();
      },
    );
  }

  Future<bool> verifyOtp(String otp) async {
    _clearError();
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.verifyOtp(_verificationId, otp);
      _isLoading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> sendPasswordReset(String email) async {
    await _authService.sendPasswordReset(email);
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}