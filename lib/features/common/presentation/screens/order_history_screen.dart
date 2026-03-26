import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/order_provider.dart';
import '../../../../theme/app_colors.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<OrderProvider>(context, listen: false).loadOrders());
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ORDER HISTORY',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 16)),
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentColor))
          : orders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.mediumGray),
                      SizedBox(height: 16),
                      Text('No orders yet', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('Your purchases will appear here.', style: TextStyle(color: AppColors.mediumGray, fontSize: 12)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => orderProvider.loadOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: order.imageUrl.isNotEmpty 
                                    ? Image.network(order.imageUrl,
                                        width: 60, height: 60, fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _buildPlaceholder())
                                    : _buildPlaceholder(),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(order.itemTitle,
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Text('${order.totalPrice.toInt()} Lek',
                                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.accentColor)),
                                    ],
                                  ),
                                ),
                                _buildStatusBadge(order.status),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.receipt_rounded, size: 14, color: AppColors.mediumGray),
                                const SizedBox(width: 6),
                                Text('Order #${order.id}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                const Spacer(),
                                Text(order.timeAgo,
                                    style: const TextStyle(fontSize: 11, color: AppColors.mediumGray)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60, height: 60,
      color: AppColors.lightGray,
      child: const Icon(Icons.image_not_supported),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    String label;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case OrderStatus.confirmed:
        color = Colors.blue;
        label = 'Confirmed';
        break;
      case OrderStatus.shipped:
        color = Colors.deepPurple;
        label = 'Shipped';
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        label = 'Delivered';
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        label = 'Cancelled';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

