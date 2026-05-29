import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/market_provider.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
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

    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio')),
      body: portfolioProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: portfolioProvider.fetchPortfolio,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(portfolioProvider, liveStats),
                    const SizedBox(height: 20),
                    const Text('Segment Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildSegmentRow('Equity', portfolioProvider.summary?['equity'], liveStats['equityValue']),
                    _buildSegmentRow('Futures', portfolioProvider.summary?['futures'], null),
                    _buildSegmentRow('Options', portfolioProvider.summary?['options'], null),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(PortfolioProvider provider, Map<String, double> liveStats) {
    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Total Portfolio Value', style: TextStyle(fontSize: 16)),
            Text('₹${liveStats['totalValue']?.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Available Cash:'),
                Text('₹${(provider.summary?['virtual_cash'] ?? 0.0).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentRow(String title, Map<String, dynamic>? data, double? liveValue) {
    if (data == null) return const SizedBox();
    return ListTile(
      title: Text(title),
      subtitle: liveValue != null 
        ? Text('Value: ₹${liveValue.toStringAsFixed(2)}')
        : (data['value'] != null ? Text('Value: ₹${(data['value'] ?? 0.0).toStringAsFixed(2)}') : null),
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
