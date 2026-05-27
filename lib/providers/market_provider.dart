import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

class MarketProvider with ChangeNotifier {
  final WebSocketService _wsService = WebSocketService();
  Map<String, dynamic> _prices = {};
  bool _isMarketOpen = false;

  Map<String, dynamic> get prices => _prices;
  bool get isMarketOpen => _isMarketOpen;

  void init() {
    _wsService.onData = (data) {
      if (data['type'] == 'MARKET_DATA') {
        final payload = data['data'];
        for (var item in payload['prices']) {
          _prices[item['symbol']] = item;
        }
        _isMarketOpen = payload['isMarketOpen'] ?? false;
        notifyListeners();
      }
    };
    _wsService.connect();
  }

  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }
}
