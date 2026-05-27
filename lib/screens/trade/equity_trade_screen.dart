import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../providers/market_provider.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';

class EquityTradeScreen extends StatefulWidget {
  final String symbol;
  const EquityTradeScreen({super.key, required this.symbol});

  @override
  State<EquityTradeScreen> createState() => _EquityTradeScreenState();
}

class _EquityTradeScreenState extends State<EquityTradeScreen> {
  final _quantityController = TextEditingController();
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

      final endpoint = type == 'BUY' ? '/equity/buy' : '/equity/sell';
      final response = await dio.post(endpoint, data: {
        'symbol': widget.symbol,
        'quantity': int.parse(_quantityController.text),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message'])),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trade failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);
    final priceData = marketProvider.prices[widget.symbol];
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
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
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
                      child: const Text('BUY'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _executeTrade('SELL'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      child: const Text('SELL'),
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
