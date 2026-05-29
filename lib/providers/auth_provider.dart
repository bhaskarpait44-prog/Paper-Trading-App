import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/auth_service.dart';
import '../core/constants.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  bool _isFyersConnected = false;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isFyersConnected => _isFyersConnected;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final result = await _authService.login(email, password);
    _isLoading = false;
    if (result != null) {
      _user = result['user'];
      _isFyersConnected = _user?['isFyersConnected'] ?? false;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    debugPrint('AuthProvider: Attempting to register user: $email');
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _authService.register(name, email, password);
      _isLoading = false;
      if (result != null) {
        debugPrint('AuthProvider: Registration successful for: $email');
        _user = result['user'];
        _isFyersConnected = _user?['isFyersConnected'] ?? false;
        notifyListeners();
        return true;
      } else {
        debugPrint('AuthProvider: Registration failed (result was null)');
      }
    } catch (e) {
      debugPrint('AuthProvider: Unexpected error during registration: $e');
      _isLoading = false;
    }
    notifyListeners();
    return false;
  }

  Future<String?> getFyersLoginUrl() async {
    final token = await _authService.getToken();
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {'Authorization': 'Bearer $token'},
    ));

    try {
      final response = await dio.get('/auth/fyers/login');
      return response.data['loginUrl'];
    } catch (e) {
      debugPrint('Error getting Fyers login URL: $e');
      return null;
    }
  }

  void setFyersConnected(bool connected) {
    _isFyersConnected = connected;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
