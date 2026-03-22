import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vinta/core/services/chat_service.dart';
import '../../../../theme/app_colors.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = ChatService();
  String? get _myId => Supabase.instance.client.auth.currentUser?.id;

  @override
  Widget build(BuildContext context) {
    final myId = _myId;
    if (myId == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view messages.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('MESSAGES', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1, fontSize: 22)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _chatService.getConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accentColor));
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.mediumGray.withOpacity(0.5)),
                   const SizedBox(height: 16),
                   const Text('No conversations yet.', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                   const SizedBox(height: 8),
                   const Text('Find an item and start a chat!', style: TextStyle(color: AppColors.mediumGray, fontSize: 13)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final msg = conversations[index];
              final otherId = msg['sender_id'] == myId ? msg['receiver_id'] : msg['sender_id'];
              final isMeSender = msg['sender_id'] == myId;
              final otherProfile = isMeSender ? msg['receiver'] : msg['sender'];
              
              return _buildConversationTile(otherId, msg, otherProfile);
            },
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(String otherId, Map<String, dynamic> latestMsg, Map<String, dynamic>? otherProfile) {
    final String label = otherProfile?['username'] ?? "Member_${otherId.substring(0, 4)}";
    final String? avatar = otherProfile?['avatar_url'];

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accentColor.withOpacity(0.3), width: 2),
        ),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.background,
          backgroundImage: avatar != null ? NetworkImage(avatar) : null,
          child: avatar == null ? Text(label[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary)) : null,
        ),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      subtitle: Text(
        latestMsg['text'], 
        maxLines: 1, 
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: (latestMsg['sender_id'] != _myId && latestMsg['is_read'] == false) 
              ? AppColors.textPrimary 
              : AppColors.textSecondary, 
          fontSize: 14,
          fontWeight: (latestMsg['sender_id'] != _myId && latestMsg['is_read'] == false) 
              ? FontWeight.bold 
              : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('Just now', style: TextStyle(fontSize: 10, color: AppColors.mediumGray, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          if (latestMsg['sender_id'] != _myId && latestMsg['is_read'] == false)
            const CircleAvatar(radius: 4, backgroundColor: AppColors.accentColor),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              userName: label,
              receiverId: otherId,
            ),
          ),
        ).then((_) => setState(() {})); // Refresh list after returning
      },
    );
  }
}
