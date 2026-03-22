import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vinta/core/models/clothing_item.dart';
import 'package:vinta/core/models/user_model.dart';

class SupabaseRepository {
  final _client = Supabase.instance.client;

  // --- Profile Operations ---
  Future<UserModel?> getProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    
    if (response == null) return null;
    return UserModel(
      id: response['id'],
      username: response['username'] ?? 'VintaMember',
      email: '', 
      phoneNumber: response['phone_number'] ?? '',
      isVerified: response['is_verified'] ?? false,
    );
  }

  // --- Marketplace Operations ---
  Future<List<ClothingItem>> fetchItems() async {
    final response = await _client
        .from('clothing_items')
        .select('''
          *,
          profiles:seller_id (username, avatar_url, is_verified, location)
        ''')
        .order('created_at', ascending: false);

    return (response as List).map((data) {
      final profile = data['profiles'];
      return ClothingItem(
        id: data['id'].toString(),
        sellerId: data['seller_id'],
        sellerName: profile != null ? profile['username'] : 'Vinta Member',
        title: data['title'],
        description: data['description'] ?? '',
        price: (data['price'] as num).toDouble(),
        imageUrls: List<String>.from(data['image_urls'] ?? []),
        category: data['category'] ?? 'Other',
        size: data['size'] ?? 'Universal',
        brand: data['brand'] ?? 'Vinta',
        condition: _mapCondition(data['condition']),
        city: profile != null ? (profile['location'] ?? 'Vlorë') : 'Vlorë',
        comments: [], // Comments to be fetched separately or via join
      );
    }).toList();
  }

  Future<void> createItem(ClothingItem item) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User must be logged in to create items');
    
    await _client.from('clothing_items').insert({
      'seller_id': user.id,
      'title': item.title,
      'description': item.description,
      'price': item.price,
      'category': item.category,
      'size': item.size,
      'brand': item.brand,
      'condition': item.condition.name,
      'image_urls': item.imageUrls,
    });
  }

  // --- Interaction Operations ---
  Future<void> toggleLike(String itemId, bool isLiked) async {
    final userId = _client.auth.currentUser!.id;
    if (isLiked) {
      await _client.from('likes').delete().match({'user_id': userId, 'item_id': itemId});
    } else {
      await _client.from('likes').insert({'user_id': userId, 'item_id': itemId});
    }
  }

  ClothingCondition _mapCondition(String? condition) {
    switch (condition) {
      case 'brandNew': return ClothingCondition.brandNew;
      case 'likeNew': return ClothingCondition.likeNew;
      case 'good': return ClothingCondition.good;
      case 'fair': return ClothingCondition.fair;
      default: return ClothingCondition.used;
    }
  }
}
