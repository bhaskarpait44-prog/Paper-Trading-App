import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../market/market_screen.dart';
import '../portfolio/portfolio_screen.dart';
import '../orders/orders_screen.dart';
import '../pnl/pnl_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    MarketScreen(),
    PortfolioScreen(),
    OrdersScreen(),
    PnlScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _connectFyers() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final loginUrl = await authProvider.getFyersLoginUrl();
    
    if (loginUrl != null) {
      final uri = Uri.parse(loginUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        // After launching, we assume the user will login and the callback will handle the rest.
        // We can optionally show a dialog or snackbar.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening Fyers login... Refresh after successful login.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch Fyers login URL')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Indian Paper Trader'),
        actions: [
          if (!authProvider.isFyersConnected)
            TextButton.icon(
              onPressed: _connectFyers,
              icon: const Icon(Icons.link, color: Colors.white),
              label: const Text('Connect Fyers', style: TextStyle(color: Colors.white)),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.check_circle, color: Colors.lightGreenAccent),
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Market'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Portfolio'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'P&L'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
