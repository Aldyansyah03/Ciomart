import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/login', {
        'username': username,
        'password': password,
      });

      if (response['success'] == true) {
        _currentUser = User.fromJson(response['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login gagal';
      }
    } catch (e) {
      _error = 'Koneksi ke server gagal. Pastikan server aktif.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String fullName, String username, String password, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/register', {
        'full_name': fullName,
        'username': username,
        'password': password,
        'role': role,
      });

      if (response['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Gagal mendaftar';
      }
    } catch (e) {
      _error = 'Koneksi ke server gagal.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
