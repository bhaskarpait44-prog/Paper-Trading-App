import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    final authService = AuthService();
    final token = await authService.getToken();

    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        headers: {'Authorization': 'Bearer $token'},
      ));

      final response = await dio.get('/orders');
      if (mounted) {
        setState(() {
          _orders = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Fetch orders error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchOrders,
              child: ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final date = DateTime.parse(order['createdAt']);
                  final formattedDate = DateFormat('dd MMM, hh:mm a').format(date);

                  return ListTile(
                    title: Text('${order['symbol']} (${order['segment']?.toString().toUpperCase() ?? 'EQUITY'})'),
                    subtitle: Text('Qty: ${order['quantity'] ?? order['lots']} @ ₹${order['price'] ?? order['premiumPaid']}\n$formattedDate'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: order['orderType'] == 'BUY' ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order['orderType'] ?? 'BUY',
                        style: TextStyle(
                          color: order['orderType'] == 'BUY' ? Colors.green.shade800 : Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
