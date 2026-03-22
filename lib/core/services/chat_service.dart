import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vinta/features/chat/presentation/screens/chat_screen.dart'; // For MessageModel if defined there, or create a common model

class ChatService {
  final _client = Supabase.instance.client;

  // --- Real-time Message Stream ---
  Stream<List<Map<String, dynamic>>> getMessageStream(String receiverId) {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);
    
    // Listen for messages involving THESE two users
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) {
          return data.where((m) => 
            (m['sender_id'] == userId && m['receiver_id'] == receiverId) ||
            (m['sender_id'] == receiverId && m['receiver_id'] == userId)
          ).toList();
        });
  }

  // --- Send Message ---
  Future<void> sendMessage(String receiverId, String text) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('messages').insert({
      'sender_id': userId,
      'receiver_id': receiverId,
      'text': text,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // --- Unread Message Count Stream ---
  Stream<int> getUnreadCountStream() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value(0);

    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .map((data) {
          return data.where((m) => 
            m['receiver_id'] == userId && m['is_read'] == false
          ).length;
        });
  }

  // --- Mark Messages as Read ---
  Future<void> markAsRead(String otherId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client
        .from('messages')
        .update({'is_read': true})
        .match({'receiver_id': userId, 'sender_id': otherId, 'is_read': false});
  }

  // --- Fetch Active Conversations ---
  Future<List<Map<String, dynamic>>> getConversations() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    
    // Grouped select to get latest message per user
    final response = await _client
        .from('messages')
        .select('''
          *,
          sender:sender_id (username, avatar_url),
          receiver:receiver_id (username, avatar_url)
        ''')
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('created_at', ascending: false);
    
    // Group by other user ID on client side for reliability 
    final Map<String, Map<String, dynamic>> conversations = {};
    for (var msg in response as List) {
      final otherId = msg['sender_id'] == userId ? msg['receiver_id'] : msg['sender_id'];
      if (!conversations.containsKey(otherId)) {
        conversations[otherId] = msg;
      }
    }
    
    return conversations.values.toList();
  }
}
