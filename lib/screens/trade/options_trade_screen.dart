import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';

class OptionsTradeScreen extends StatefulWidget {
  final dynamic item;
  final String optionType;
  const OptionsTradeScreen({super.key, required this.item, required this.optionType});

  @override
  State<OptionsTradeScreen> createState() => _OptionsTradeScreenState();
}

class _OptionsTradeScreenState extends State<OptionsTradeScreen> {
  final _lotsController = TextEditingController();
  bool _isLoading = false;

  void _executeTrade() async {
    setState(() => _isLoading = true);
    final authService = AuthService();
    final token = await authService.getToken();

    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        headers: {'Authorization': 'Bearer $token'},
      ));

      // Backend expects: symbol, expiryDate, strikePrice, optionType, lots
      // Fyers item contains strike_price, expiry, etc.
      final response = await dio.post('/options/buy', data: {
        'symbol': widget.item['underlying_symbol'] ?? 'NIFTY',
        'expiryDate': widget.item['expiry'] ?? '2026-06-25',
        'strikePrice': widget.item['strike_price'],
        'optionType': widget.optionType,
        'lots': int.parse(_lotsController.text),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message'])),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Options trade error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Options trade failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ltp = widget.optionType == 'CE' ? widget.item['ce_ltp'] : widget.item['pe_ltp'];
    final strike = widget.item['strike_price'];

    return Scaffold(
      appBar: AppBar(title: Text('${widget.optionType} Trade - $strike')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Strike: $strike', style: const TextStyle(fontSize: 18)),
            Text('Type: ${widget.optionType}', style: const TextStyle(fontSize: 18)),
            Text('Current Premium: ₹$ltp', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 30),
            TextField(
              controller: _lotsController,
              decoration: const InputDecoration(labelText: 'Number of Lots'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 40),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _executeTrade,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.optionType == 'CE' ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('BUY ${widget.optionType}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
