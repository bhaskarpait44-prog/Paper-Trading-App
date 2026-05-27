import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/market_provider.dart';
import '../../core/constants.dart';
import '../trade/equity_trade_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<MarketProvider>(context, listen: false).init();
  }

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text('Market'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: marketProvider.isMarketOpen ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  marketProvider.isMarketOpen ? 'OPEN' : 'CLOSED',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Equity'),
              Tab(text: 'Futures'),
              Tab(text: 'Options'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEquityList(marketProvider),
            const Center(child: Text('Futures - Coming Soon')),
            const Center(child: Text('Options - Coming Soon')),
          ],
        ),
      ),
    );
  }

  Widget _buildEquityList(MarketProvider provider) {
    return ListView.builder(
      itemCount: AppConstants.indexSymbols.length,
      itemBuilder: (context, index) {
        final symbol = AppConstants.indexSymbols[index];
        final data = provider.prices[symbol];

        return ListTile(
          title: Text(symbol),
          subtitle: data != null
              ? Text('LTP: ${data['ltp']} (${data['changePercent']}%)')
              : const Text('Loading...'),
          trailing: data != null
              ? Icon(
                  (data['change'] ?? 0) >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: (data['change'] ?? 0) >= 0 ? Colors.green : Colors.red,
                )
              : null,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EquityTradeScreen(symbol: symbol),
              ),
            );
          },
        );
      },
    );
  }
}
