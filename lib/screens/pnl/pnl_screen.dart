import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/market_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class PnlScreen extends StatefulWidget {
  const PnlScreen({super.key});

  @override
  State<PnlScreen> createState() => _PnlScreenState();
}

class _PnlScreenState extends State<PnlScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PortfolioProvider>(context, listen: false).fetchPortfolio();
    });
  }

  @override
  Widget build(BuildContext context) {
    final portfolioProvider = Provider.of<PortfolioProvider>(context);
    final marketProvider = Provider.of<MarketProvider>(context);
    final liveStats = portfolioProvider.calculateLivePnl(marketProvider);

    final unrealizedPnl = liveStats['unrealizedPnl'] ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('P&L Analytics')),
      body: portfolioProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: portfolioProvider.fetchPortfolio,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildPnlCard('Live Unrealized P&L', unrealizedPnl),
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
                                FlSpot(1, liveStats['totalValue'] ?? 2500000),
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
