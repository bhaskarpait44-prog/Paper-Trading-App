import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../providers/market_provider.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';

class FuturesTradeScreen extends StatefulWidget {
  final String symbol;
  const FuturesTradeScreen({super.key, required this.symbol});

  @override
  State<FuturesTradeScreen> createState() => _FuturesTradeScreenState();
}

class _FuturesTradeScreenState extends State<FuturesTradeScreen> {
  final _lotsController = TextEditingController();
  bool _isLoading = false;

  void _executeTrade(String type) async {
    setState(() => _isLoading = true);
    final authService = AuthService();
    final token = await authService.getToken();

    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        headers: {'Authorization': 'Bearer $token'},
      ));

      // Backend expects: symbol, expiryDate, orderType, lots
      final response = await dio.post('/futures/trade', data: {
        'symbol': widget.symbol,
        'expiryDate': '2026-06-25', // Placeholder, real logic would use actual expiry
        'orderType': type,
        'lots': int.parse(_lotsController.text),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message'])),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Futures trade error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Futures trade failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);
    final priceData = marketProvider.futuresPrices[widget.symbol];
    final ltp = priceData?['ltp'] ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: Text('Trade ${widget.symbol}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LTP: ₹$ltp', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _lotsController,
              decoration: const InputDecoration(labelText: 'Number of Lots'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            const Text('Note: Margin will be deducted from your virtual cash.', 
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            const SizedBox(height: 40),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _executeTrade('BUY'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('BUY / LONG'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _executeTrade('SELL'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      child: const Text('SELL / SHORT'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
