import 'package:flutter/material.dart';
import '../repositories/supabase_repository.dart';

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

class OrderItem {
  final String id;
  final String itemTitle;
  final String imageUrl;
  final double totalPrice;
  final OrderStatus status;
  final DateTime createdAt;

  OrderItem({
    required this.id,
    required this.itemTitle,
    required this.imageUrl,
    required this.totalPrice,
    this.status = OrderStatus.pending,
    required this.createdAt,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class OrderProvider extends ChangeNotifier {
  final List<OrderItem> _orders = [];
  bool _isLoading = false;

  List<OrderItem> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await SupabaseRepository().fetchOrders();
      _orders.clear();
      for (var d in data) {
        final item = d['clothing_items'];
        _orders.add(OrderItem(
          id: d['id'].toString(),
          itemTitle: item != null ? item['title'] : 'Unknown Item',
          imageUrl: (item != null && (item['image_urls'] as List).isNotEmpty)
              ? item['image_urls'][0]
              : '',
          totalPrice: (d['amount'] as num).toDouble(),
          status: _mapStatus(d['status']),
          createdAt: DateTime.parse(d['created_at']),
        ));
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addOrder({
    required String sellerId,
    required String itemId,
    required String itemTitle,
    required String imageUrl,
    required double totalPrice,
  }) async {
    // Optimistic UI update
    final tempOrder = OrderItem(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      itemTitle: itemTitle,
      imageUrl: imageUrl,
      totalPrice: totalPrice,
      createdAt: DateTime.now(),
    );
    _orders.insert(0, tempOrder);
    notifyListeners();

    try {
      await SupabaseRepository().createOrder(
        sellerId: sellerId,
        itemId: itemId,
        amount: totalPrice,
      );
    } catch (e) {
      debugPrint('Error saving order: $e');
      _orders.remove(tempOrder);
      notifyListeners();
    }
  }

  OrderStatus _mapStatus(String? status) {
    switch (status) {
      case 'confirmed': return OrderStatus.confirmed;
      case 'shipped': return OrderStatus.shipped;
      case 'delivered': return OrderStatus.delivered;
      case 'cancelled': return OrderStatus.cancelled;
      default: return OrderStatus.pending;
    }
  }
}
