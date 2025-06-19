import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get userRole => _user?['role'];

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    _isLoggedIn = await AuthService.isLoggedIn();
    if (_isLoggedIn) {
      _user = await AuthService.getCurrentUser();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await AuthService.login(email, password);
      if (result != null) {
        _user = result['user'];
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String role,
    String? namaPengguna,
    String? telepon,
    String? alamat,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await AuthService.register(
        email: email,
        password: password,
        role: role,
        namaPengguna: namaPengguna,
        telepon: telepon,
        alamat: alamat,
      );

      if (result != null) {
        _user = result['user'];
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  // Check if restaurant owner has a restaurant
  Future<bool> hasRestaurant() async {
    return await AuthService.hasRestaurant();
  }

  // Check if driver has a profile
  Future<bool> hasDriverProfile() async {
    return await AuthService.hasDriverProfile();
  }
}
