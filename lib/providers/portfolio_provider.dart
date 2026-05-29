import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/constants.dart';
import '../services/auth_service.dart';
import 'market_provider.dart';

class PortfolioProvider with ChangeNotifier {
  Map<String, dynamic>? _summary;
  List<dynamic> _equityHoldings = [];
  List<dynamic> _futuresPositions = [];
  bool _isLoading = false;

  Map<String, dynamic>? get summary => _summary;
  bool get isLoading => _isLoading;

  Future<void> fetchPortfolio() async {
    _isLoading = true;
    notifyListeners();
    final authService = AuthService();
    final token = await authService.getToken();

    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        headers: {'Authorization': 'Bearer $token'},
      ));

      // Fetch summary and full positions for local P&L calculation
      final summaryRes = await dio.get('/portfolio/summary');
      final equityRes = await dio.get('/equity/holdings');
      final futuresRes = await dio.get('/futures/positions');

      _summary = summaryRes.data;
      _equityHoldings = equityRes.data;
      _futuresPositions = futuresRes.data;
      
    } catch (e) {
      debugPrint('PortfolioProvider error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate Live P&L using prices from MarketProvider
  Map<String, double> calculateLivePnl(MarketProvider marketProvider) {
    double totalUnrealizedPnl = 0.0;
    double equityValue = 0.0;

    for (var h in _equityHoldings) {
      final symbol = h['symbol'];
      final priceData = marketProvider.indexPrices[symbol];
      final currentPrice = priceData != null ? (priceData['ltp'] ?? 0.0) : (h['averageBuyPrice'] ?? 0.0);
      
      final pnl = (currentPrice - (h['averageBuyPrice'] ?? 0.0)) * (h['quantity'] ?? 0);
      totalUnrealizedPnl += pnl;
      equityValue += currentPrice * (h['quantity'] ?? 0);
    }

    for (var p in _futuresPositions) {
      final symbol = p['symbol'];
      final priceData = marketProvider.futuresPrices[symbol];
      final currentPrice = priceData != null ? (priceData['ltp'] ?? 0.0) : (p['avgEntryPrice'] ?? 0.0);
      
      final pnl = (currentPrice - (p['avgEntryPrice'] ?? 0.0)) * (p['lotSize'] ?? 1) * (p['lots'] ?? 0);
      totalUnrealizedPnl += pnl;
    }

    // Options P&L is harder without live premium stream, but we can add it later
    
    return {
      'unrealizedPnl': totalUnrealizedPnl,
      'equityValue': equityValue,
      'totalValue': (summary?['virtual_cash'] ?? 0.0) + equityValue + totalUnrealizedPnl
    };
  }
}
