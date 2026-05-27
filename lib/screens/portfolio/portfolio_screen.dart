import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  Map<String, dynamic>? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPortfolio();
  }

  Future<void> _fetchPortfolio() async {
    setState(() => _isLoading = true);
    final authService = AuthService();
    final token = await authService.getToken();

    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        headers: {'Authorization': 'Bearer $token'},
      ));

      final response = await dio.get('/portfolio/summary');
      if (mounted) {
        setState(() {
          _summary = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Fetch portfolio error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPortfolio,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 20),
                    const Text('Segment Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildSegmentRow('Equity', _summary?['equity']),
                    _buildSegmentRow('Futures', _summary?['futures']),
                    _buildSegmentRow('Options', _summary?['options']),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Total Portfolio Value', style: TextStyle(fontSize: 16)),
            Text('₹${(_summary?['totalPortfolioValue'] ?? 0.0).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Available Cash:'),
                Text('₹${(_summary?['virtual_cash'] ?? 0.0).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentRow(String title, Map<String, dynamic>? data) {
    if (data == null) return const SizedBox();
    return ListTile(
      title: Text(title),
      subtitle: title == 'Equity' 
        ? Text('Value: ₹${(data['value'] ?? 0.0).toStringAsFixed(2)}')
        : null,
      trailing: Text(
        '${(data['unrealizedPnl'] ?? 0.0) >= 0 ? "+" : ""}₹${(data['unrealizedPnl'] ?? 0.0).toStringAsFixed(2)}',
        style: TextStyle(
          color: (data['unrealizedPnl'] ?? 0.0) >= 0 ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}
