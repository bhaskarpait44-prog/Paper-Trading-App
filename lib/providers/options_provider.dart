import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/constants.dart';
import '../services/auth_service.dart';

class OptionsProvider with ChangeNotifier {
  Map<String, dynamic>? _chainData;
  bool _isLoading = false;

  Map<String, dynamic>? get chainData => _chainData;
  bool get isLoading => _isLoading;

  Future<void> fetchOptionChain(String symbol) async {
    _isLoading = true;
    notifyListeners();

    final authService = AuthService();
    final token = await authService.getToken();

    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        headers: {'Authorization': 'Bearer $token'},
      ));

      final response = await dio.get('/options/chain', queryParameters: {'symbol': symbol});
      if (response.statusCode == 200) {
        _chainData = response.data;
      }
    } catch (e) {
      debugPrint('Fetch option chain error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
