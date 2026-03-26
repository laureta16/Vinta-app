import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final DateTime createdAt;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.createdAt,
    this.isRead = false,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class NotificationProvider extends ChangeNotifier {
  final List<NotificationItem> _items = [
    NotificationItem(
      id: 'welcome',
      title: 'Welcome to Vinta! 🎉',
      body: 'Start exploring premium fashion from Albanian sellers.',
      icon: Icons.celebration_rounded,
      color: Colors.deepPurple,
      createdAt: DateTime.now(),
    ),
  ];

  List<NotificationItem> get items => _items;
  int get unreadCount => _items.where((n) => !n.isRead).length;

  void addNotification({
    required String title,
    required String body,
    required IconData icon,
    required Color color,
  }) {
    _items.insert(0, NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      icon: icon,
      color: color,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  void markRead(String id) {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _items[idx].isRead = true;
      notifyListeners();
    }
  }

  void markAllRead() {
    for (var n in _items) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void remove(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  // Convenience methods for common events
  void notifyNewFollower(String username) {
    addNotification(
      title: '$username followed you',
      body: 'You have a new follower! Check their profile.',
      icon: Icons.person_add_rounded,
      color: Colors.blue,
    );
  }

  void notifyItemLiked(String username, String itemTitle) {
    addNotification(
      title: '$username liked your listing',
      body: '"$itemTitle" is getting attention!',
      icon: Icons.favorite_rounded,
      color: Colors.red,
    );
  }

  void notifyNewMessage(String username) {
    addNotification(
      title: 'New message from $username',
      body: 'You have a new message. Tap to read.',
      icon: Icons.chat_bubble_rounded,
      color: Colors.green,
    );
  }

  void notifyOrderPlaced(String itemTitle) {
    addNotification(
      title: 'Order Confirmed! 🛍️',
      body: 'Your order for "$itemTitle" has been placed.',
      icon: Icons.shopping_bag_rounded,
      color: Colors.deepPurple,
    );
  }

  void notifyReviewReceived(String username, int stars) {
    addNotification(
      title: '$username left a $stars★ review',
      body: 'See what they said about your service.',
      icon: Icons.star_rounded,
      color: Colors.amber,
    );
  }
}
