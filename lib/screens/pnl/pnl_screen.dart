import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';
import 'package:fl_chart/fl_chart.dart';

class PnlScreen extends StatefulWidget {
  const PnlScreen({super.key});

  @override
  State<PnlScreen> createState() => _PnlScreenState();
}

class _PnlScreenState extends State<PnlScreen> {
  Map<String, dynamic>? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
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
      debugPrint('Fetch pnl summary error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unrealizedPnl = (_summary?['equity']?['unrealizedPnl'] ?? 0.0) +
        (_summary?['futures']?['unrealizedPnl'] ?? 0.0);

    return Scaffold(
      appBar: AppBar(title: const Text('P&L Analytics')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildPnlCard('Unrealized P&L', unrealizedPnl),
                  const SizedBox(height: 20),
                  const Text('Portfolio Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              const FlSpot(0, 2500000),
                              FlSpot(1, _summary?['totalPortfolioValue'] ?? 2500000),
                            ],
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPnlCard(String title, double value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 18)),
            Text(
              '${value >= 0 ? "+" : ""}₹${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: value >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
