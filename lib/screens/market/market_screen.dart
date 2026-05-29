import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/market_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../providers/options_provider.dart';
import '../../core/constants.dart';
import '../trade/equity_trade_screen.dart';
import '../trade/futures_trade_screen.dart';
import '../trade/options_trade_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _selectedOptionIndex = '^NSEI';

  @override
  void initState() {
    super.initState();
    Provider.of<MarketProvider>(context, listen: false).init();
    Provider.of<WatchlistProvider>(context, listen: false).fetchWatchlist();
  }

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);

    return DefaultTabController(
      length: 4,
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
            isScrollable: true,
            tabs: [
              Tab(text: 'Watchlist'),
              Tab(text: 'Equity'),
              Tab(text: 'Futures'),
              Tab(text: 'Options'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildWatchlist(marketProvider),
            _buildEquityList(marketProvider),
            _buildFuturesList(marketProvider),
            _buildOptionsChain(),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlist(MarketProvider marketProvider) {
    final watchlistProvider = Provider.of<WatchlistProvider>(context);
    final watchlist = watchlistProvider.watchlist;

    if (watchlist.isEmpty) {
      return const Center(child: Text('Your watchlist is empty'));
    }

    return ListView.builder(
      itemCount: watchlist.length,
      itemBuilder: (context, index) {
        final item = watchlist[index];
        final symbol = item['symbol'];
        final segment = item['segment'];
        
        dynamic data;
        if (segment == 'equity') {
          data = marketProvider.indexPrices[symbol];
        } else if (segment == 'futures') {
          data = marketProvider.futuresPrices[symbol];
        }

        return ListTile(
          title: Text(symbol),
          subtitle: data != null
              ? Text('LTP: ${data['ltp']?.toStringAsFixed(2)}')
              : const Text('Loading...'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => watchlistProvider.removeFromWatchlist(item['id']),
          ),
          onTap: () {
            if (segment == 'equity') {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EquityTradeScreen(symbol: symbol)),
              );
            } else if (segment == 'futures') {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => FuturesTradeScreen(symbol: symbol)),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildEquityList(MarketProvider provider) {
    final watchlistProvider = Provider.of<WatchlistProvider>(context);
    
    return ListView.builder(
      itemCount: AppConstants.indexSymbols.length,
      itemBuilder: (context, index) {
        final symbol = AppConstants.indexSymbols[index];
        final data = provider.indexPrices[symbol];
        final isAdded = watchlistProvider.isInWatchlist(symbol);

        return ListTile(
          title: Text(symbol),
          subtitle: data != null
              ? Text('LTP: ${data['ltp']?.toStringAsFixed(2)} (${data['changePercent']?.toStringAsFixed(2)}%)')
              : const Text('Loading...'),
          leading: IconButton(
            icon: Icon(isAdded ? Icons.favorite : Icons.favorite_border, 
                      color: isAdded ? Colors.red : null),
            onPressed: () {
              if (isAdded) {
                final id = watchlistProvider.getWatchlistItemId(symbol);
                if (id != null) watchlistProvider.removeFromWatchlist(id);
              } else {
                watchlistProvider.addToWatchlist({
                  'symbol': symbol,
                  'segment': 'equity',
                });
              }
            },
          ),
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

  Widget _buildFuturesList(MarketProvider provider) {
    final watchlistProvider = Provider.of<WatchlistProvider>(context);
    final futures = provider.futuresPrices.values.toList();
    
    if (futures.isEmpty) {
      return const Center(child: Text('No Futures Data Available (Connect Fyers for live data)'));
    }

    return ListView.builder(
      itemCount: futures.length,
      itemBuilder: (context, index) {
        final data = futures[index];
        final symbol = data['symbol'];
        final isAdded = watchlistProvider.isInWatchlist(symbol);

        return ListTile(
          title: Text(symbol),
          subtitle: Text('LTP: ${data['ltp']?.toStringAsFixed(2)}'),
          leading: IconButton(
            icon: Icon(isAdded ? Icons.favorite : Icons.favorite_border, 
                      color: isAdded ? Colors.red : null),
            onPressed: () {
              if (isAdded) {
                final id = watchlistProvider.getWatchlistItemId(symbol);
                if (id != null) watchlistProvider.removeFromWatchlist(id);
              } else {
                watchlistProvider.addToWatchlist({
                  'symbol': symbol,
                  'segment': 'futures',
                });
              }
            },
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FuturesTradeScreen(symbol: symbol),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOptionsChain() {
    final optionsProvider = Provider.of<OptionsProvider>(context);
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FilterChip(
                label: const Text('NIFTY'),
                selected: _selectedOptionIndex == '^NSEI',
                onSelected: (val) {
                  setState(() => _selectedOptionIndex = '^NSEI');
                  optionsProvider.fetchOptionChain('^NSEI');
                },
              ),
              FilterChip(
                label: const Text('BANKNIFTY'),
                selected: _selectedOptionIndex == '^NSEBANK',
                onSelected: (val) {
                  setState(() => _selectedOptionIndex = '^NSEBANK');
                  optionsProvider.fetchOptionChain('^NSEBANK');
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: optionsProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : optionsProvider.chainData == null
                  ? const Center(child: Text('Click on an index to load chain'))
                  : _buildChainTable(optionsProvider.chainData!),
        ),
      ],
    );
  }

  Widget _buildChainTable(Map<String, dynamic> data) {
    if (data['s'] != 'ok') return const Center(child: Text('Error loading chain'));
    final options = data['d']['optionsChain'] as List;

    return Column(
      children: [
        Container(
          color: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Row(
            children: [
              Expanded(child: Center(child: Text('CALLS', style: TextStyle(fontWeight: FontWeight.bold)))),
              Expanded(child: Center(child: Text('STRIKE', style: TextStyle(fontWeight: FontWeight.bold)))),
              Expanded(child: Center(child: Text('PUTS', style: TextStyle(fontWeight: FontWeight.bold)))),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final item = options[index];
              return Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _openOptionsTrade(item, 'CE'),
                        child: Center(child: Text('${item['ce_ltp'] ?? "-"}', style: const TextStyle(color: Colors.green))),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: Colors.grey.shade100,
                        child: Center(child: Text('${item['strike_price']}', style: const TextStyle(fontWeight: FontWeight.bold))),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => _openOptionsTrade(item, 'PE'),
                        child: Center(child: Text('${item['pe_ltp'] ?? "-"}', style: const TextStyle(color: Colors.red))),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openOptionsTrade(dynamic item, String type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OptionsTradeScreen(
          item: item,
          optionType: type,
        ),
      ),
    );
  }
}
