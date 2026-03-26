import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vinta/core/models/clothing_item.dart';
import 'package:vinta/core/models/user_model.dart';
import 'package:vinta/core/services/supabase_service.dart';

class SupabaseRepository {
  SupabaseClient get _client => SupabaseService.client;

  // --- Profile Operations ---
  Future<UserModel?> getProfile(String userId) async {
    try {
      final response =
          await _client.from('profiles').select().eq('id', userId).maybeSingle();

      if (response == null) {
        debugPrint('No profile found for userId: $userId');
        return null;
      }
      
      return UserModel(
        id: response['id'] ?? userId,
        username: response['username'] ?? 'Vinta Member',
        email: response['email'] ?? '',
        phoneNumber: response['phone_number'] ?? '',
        profileImageUrl: response['avatar_url'],
        bio: response['bio'],
        isVerified: response['is_verified'] ?? false,
      );
    } catch (e) {
      debugPrint('Supabase getProfile error: $e');
      return null;
    }
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    await _client.from('profiles').update(data).eq('id', userId);
  }

  Future<List<UserModel>> searchProfiles(String query) async {
    final response = await _client
        .from('profiles')
        .select()
        .or('username.ilike.%$query%,display_name.ilike.%$query%')
        .limit(20);

    return (response as List).map((data) => UserModel(
      id: data['id'],
      username: data['username'] ?? 'User',
      email: data['email'] ?? '',
      profileImageUrl: data['avatar_url'],
      bio: data['bio'],
      isVerified: data['is_verified'] ?? false,
    )).toList();
  }

  // --- Social Cycle Operations ---
  Future<void> toggleFollow(String followerId, String followedId, bool isFollowing) async {
    if (isFollowing) {
      await _client.from('followers').delete().match({
        'follower_id': followerId,
        'followed_id': followedId,
      });
    } else {
      await _client.from('followers').insert({
        'follower_id': followerId,
        'followed_id': followedId,
      });
    }
  }

  Future<bool> isFollowing(String followerId, String followedId) async {
    final response = await _client
        .from('followers')
        .select()
        .match({
          'follower_id': followerId,
          'followed_id': followedId,
        })
        .maybeSingle();
    return response != null;
  }

  Future<Map<String, int>> getFollowStats(String userId) async {
    final followers = await _client.from('followers').select().eq('followed_id', userId);
    final following = await _client.from('followers').select().eq('follower_id', userId);
    
    return {
      'followers': (followers as List).length,
      'following': (following as List).length,
    };
  }

  // --- Marketplace Operations ---
  Future<List<ClothingItem>> fetchItems() async {
    if (!SupabaseService.isInitialized) {
      return [];
    }

    final response = await _client.from('clothing_items').select('''
          *,
          profiles:seller_id (username, avatar_url, is_verified, location)
        ''').order('created_at', ascending: false);

    return (response as List).map((data) {
      final profile = data['profiles'];
      return ClothingItem(
        id: data['id'].toString(),
        sellerId: data['seller_id'],
        sellerName: profile != null ? profile['username'] : 'Vinta Member',
        sellerVerified: profile != null ? (profile['is_verified'] ?? false) : false,
        title: data['title'],
        description: data['description'] ?? '',
        price: (data['price'] as num).toDouble(),
        imageUrls: List<String>.from(data['image_urls'] ?? []),
        category: data['category'] ?? 'Other',
        size: data['size'] ?? 'Universal',
        brand: data['brand'] ?? 'Vinta',
        condition: _mapCondition(data['condition']),
        city: profile != null ? (profile['location'] ?? 'Vlorë') : 'Vlorë',
        comments: [],
      );
    }).toList();
  }

  Future<void> createItem(ClothingItem item) async {
    if (!SupabaseService.isInitialized) {
      throw Exception('Backend is temporarily unavailable.');
    }

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

  Future<void> updateItem(ClothingItem item) async {
    if (!SupabaseService.isInitialized) return;
    await _client.from('clothing_items').update({
      'title': item.title,
      'description': item.description,
      'price': item.price,
      'category': item.category,
      'size': item.size,
      'brand': item.brand,
      'condition': item.condition.name,
      'image_urls': item.imageUrls,
    }).eq('id', item.id);
  }

  Future<void> deleteItem(String itemId) async {
    if (!SupabaseService.isInitialized) return;
    await _client.from('clothing_items').delete().eq('id', itemId);
  }

  // --- Interaction Operations ---
  Future<void> toggleLike(String itemId, bool isLiked) async {
    if (!SupabaseService.isInitialized) {
      throw Exception('Backend is temporarily unavailable.');
    }

    final userId = _client.auth.currentUser!.id;
    if (isLiked) {
      await _client
          .from('likes')
          .delete()
          .match({'user_id': userId, 'item_id': itemId});
    } else {
      await _client
          .from('likes')
          .insert({'user_id': userId, 'item_id': itemId});
    }
  }

  // --- Order Operations ---
  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('orders')
        .select('*, clothing_items(title, image_urls)')
        .or('buyer_id.eq.${user.id},seller_id.eq.${user.id}')
        .order('created_at', ascending: false);

    return response as List<Map<String, dynamic>>;
  }

  Future<void> createOrder({
    required String sellerId,
    required String itemId,
    required double amount,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from('orders').insert({
      'buyer_id': user.id,
      'seller_id': sellerId,
      'item_id': itemId,
      'amount': amount,
      'status': 'confirmed',
    });
  }

  // --- Review Operations ---
  Future<List<Map<String, dynamic>>> fetchReviews(String sellerId) async {
    final response = await _client
        .from('reviews')
        .select('*, profiles:buyer_id(username)')
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false);
    
    return response as List<Map<String, dynamic>>;
  }

  Future<void> createReview({
    required String sellerId,
    required int rating,
    required String comment,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from('reviews').insert({
      'seller_id': sellerId,
      'buyer_id': user.id,
      'rating': rating,
      'comment': comment,
    });
  }

  ClothingCondition _mapCondition(String? condition) {
    switch (condition) {
      case 'brandNew':
        return ClothingCondition.brandNew;
      case 'likeNew':
        return ClothingCondition.likeNew;
      case 'good':
        return ClothingCondition.good;
      case 'fair':
        return ClothingCondition.fair;
      default:
        return ClothingCondition.used;
    }
  }
}
