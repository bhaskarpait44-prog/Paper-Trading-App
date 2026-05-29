import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

class MarketProvider with ChangeNotifier {
  final WebSocketService _wsService = WebSocketService();
  final Map<String, dynamic> _indexPrices = {};
  final Map<String, dynamic> _futuresPrices = {};
  bool _isMarketOpen = false;

  Map<String, dynamic> get indexPrices => _indexPrices;
  Map<String, dynamic> get futuresPrices => _futuresPrices;
  bool get isMarketOpen => _isMarketOpen;

  void init() {
    _wsService.onData = (data) {
      if (data['type'] == 'MARKET_DATA') {
        final payload = data['data'];
        
        if (payload['indexPrices'] != null) {
          for (var item in payload['indexPrices']) {
            _indexPrices[item['symbol']] = item;
          }
        }
        
        if (payload['futuresPrices'] != null) {
          for (var item in payload['futuresPrices']) {
            _futuresPrices[item['symbol']] = item;
          }
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
