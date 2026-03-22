import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vinta/core/models/clothing_item.dart';
import 'package:vinta/core/repositories/supabase_repository.dart';
import 'package:vinta/core/services/storage_service.dart';

class ClothingProvider extends ChangeNotifier {
  final _repository = SupabaseRepository();
  final _storage = StorageService();
  List<ClothingItem> _items = [];
  bool _isLoading = false;

  List<ClothingItem> get items => _items;
  bool get isLoading => _isLoading;

  ClothingProvider() {
    refreshItems();
  }

  Future<void> refreshItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _repository.fetchItems();
    } catch (e) {
      debugPrint('Error fetching items: $e');
      _items = []; // No mock fallback in production
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final isLiked = _items[index].isLiked;
      _items[index] = _items[index].copyWith(isLiked: !isLiked);
      notifyListeners();

      try {
        await _repository.toggleLike(itemId, isLiked);
      } catch (e) {
        debugPrint('Error toggling like: $e');
        // Rollback on error
        _items[index] = _items[index].copyWith(isLiked: isLiked);
        notifyListeners();
      }
    }
  }

  void addComment(String itemId, Comment comment) {
    // In Phase 8, this will also be a repository call
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _items[index].comments.add(comment);
      notifyListeners();
    }
  }

  Future<void> addPost(ClothingItem item, {List<XFile>? images, XFile? video}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Upload Cloud Assets if provided
      List<String> uploadedUrls = item.imageUrls;
      String? uploadedVideoUrl = item.videoUrl;

      if (images != null && images.isNotEmpty) {
        uploadedUrls = await _storage.uploadImages(images);
      }
      
      if (video != null) {
        uploadedVideoUrl = await _storage.uploadFile(video);
      }

      // 2. Create Database Record with Cloud URLs
      final finalItem = item.copyWith(
        imageUrls: uploadedUrls,
        videoUrl: uploadedVideoUrl,
      );

      await _repository.createItem(finalItem);
      await refreshItems();
    } catch (e) {
      debugPrint('Error creating item: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ClothingItem> _getMockItems() {
    return [
      ClothingItem(
        id: '1',
        sellerId: 's1',
        sellerName: 'Vinta Designer',
        title: 'Premium Denim Jacket',
        description: 'Elite quality denim with modern stitching.',
        price: 4500,
        imageUrls: ['https://images.unsplash.com/photo-1576905355162-723d97bd358d?q=80&w=2000'],
        category: 'Outwear',
        size: 'M',
        brand: 'Vinta Elite',
        condition: ClothingCondition.likeNew,
        city: 'Tirana',
      ),
      ClothingItem(
        id: '2',
        sellerId: 's2',
        sellerName: 'Retro Vibe',
        title: 'Vintage Leather Bag',
        description: 'Handcrafted leather bag from 1990.',
        price: 8900,
        imageUrls: ['https://images.unsplash.com/photo-1548036328-c9fa89d128fa?q=80&w=2000'],
        category: 'Accessories',
        size: 'One Size',
        brand: 'Classic',
        condition: ClothingCondition.good,
        city: 'Durres',
      ),
    ];
  }
}
