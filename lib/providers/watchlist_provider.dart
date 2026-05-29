import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/constants.dart';
import '../services/auth_service.dart';

class WatchlistProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _watchlist = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get watchlist => _watchlist;
  bool get isLoading => _isLoading;

  Future<void> fetchWatchlist() async {
    _isLoading = true;
    notifyListeners();
    
    final authService = AuthService();
    final token = await authService.getToken();

    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        headers: {'Authorization': 'Bearer $token'},
      ));

      final response = await dio.get('/watchlist');
      _watchlist.clear();
      _watchlist.addAll(List<Map<String, dynamic>>.from(response.data));
    } catch (e) {
      debugPrint('Fetch watchlist error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToWatchlist(Map<String, dynamic> item) async {
    final authService = AuthService();
    final token = await authService.getToken();

    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        headers: {'Authorization': 'Bearer $token'},
      ));

      final response = await dio.post('/watchlist/add', data: item);
      if (response.statusCode == 201) {
        _watchlist.add(response.data);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Add to watchlist error: $e');
    }
    return false;
  }

  Future<bool> removeFromWatchlist(int id) async {
    final authService = AuthService();
    final token = await authService.getToken();

    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        headers: {'Authorization': 'Bearer $token'},
      ));

      final response = await dio.delete('/watchlist/$id');
      if (response.statusCode == 200) {
        _watchlist.removeWhere((item) => item['id'] == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Remove from watchlist error: $e');
    }
    return false;
  }

  bool isInWatchlist(String symbol) {
    return _watchlist.any((item) => item['symbol'] == symbol);
  }

  int? getWatchlistItemId(String symbol) {
    try {
      return _watchlist.firstWhere((item) => item['symbol'] == symbol)['id'];
    } catch (_) {
      return null;
    }
  }
}
