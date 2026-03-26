class Comment {
  final String id;
  final String userId;
  final String username;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.text,
    required this.createdAt,
  });
}

enum ClothingCondition { brandNew, likeNew, good, fair, used }

class ClothingItem {
  final String id;
  final String title;
  final String description;
  final String brand;
  final double price;
  final String category;
  final String size;
  final ClothingCondition condition;
  final String city;
  final List<String> imageUrls;
  final String? videoUrl;
  final String sellerId;
  final String sellerName;
  final bool sellerVerified;
  final List<Comment> comments;
  bool isLiked;
  bool isSaved;

  ClothingItem({
    required this.id,
    required this.title,
    this.description = '',
    required this.brand,
    required this.price,
    this.category = 'Other',
    required this.size,
    required this.condition,
    required this.city,
    required this.imageUrls,
    this.videoUrl,
    required this.sellerId,
    required this.sellerName,
    this.sellerVerified = false,
    this.comments = const [],
    this.isLiked = false,
    this.isSaved = false,
  });

  ClothingItem copyWith({
    String? id,
    String? title,
    String? description,
    String? brand,
    double? price,
    String? category,
    String? size,
    ClothingCondition? condition,
    String? city,
    List<String>? imageUrls,
    String? videoUrl,
    String? sellerId,
    String? sellerName,
    bool? sellerVerified,
    List<Comment>? comments,
    bool? isLiked,
    bool? isSaved,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      category: category ?? this.category,
      size: size ?? this.size,
      condition: condition ?? this.condition,
      city: city ?? this.city,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerVerified: sellerVerified ?? this.sellerVerified,
      comments: comments ?? List.from(this.comments),
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
