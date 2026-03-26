import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/notification_provider.dart' as provider;
import '../../../../theme/app_colors.dart';

class VintaNotificationsScreen extends StatefulWidget {
  const VintaNotificationsScreen({super.key});

  @override
  State<VintaNotificationsScreen> createState() => _VintaNotificationsScreenState();
}

class _VintaNotificationsScreenState extends State<VintaNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<provider.NotificationProvider>(context);
    final notifications = notifProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NOTIFICATIONS',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => notifProvider.markAllRead(),
            child: const Text('Read All',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.mediumGray),
                  SizedBox(height: 16),
                  Text('No notifications',
                      style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Dismissible(
                  key: Key(n.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: AppColors.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(Icons.delete_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    notifProvider.remove(index);
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: n.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(n.icon, size: 22, color: n.color),
                    ),
                    title: Text(n.title,
                        style: TextStyle(
                          fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w900,
                          fontSize: 14,
                        )),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(n.body,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(n.timeAgo,
                            style: const TextStyle(fontSize: 10, color: AppColors.mediumGray)),
                        if (!n.isRead)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: AppColors.accentColor, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    onTap: () {
                      notifProvider.markRead(n.id);
                    },
                  ),
                );
              },
            ),
    );
  }
}
