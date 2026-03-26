class UserModel {
  final String id;
  final String email;
  final String username;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? bio;
  final double rating;
  final int reviewCount;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.phoneNumber,
    this.profileImageUrl,
    this.bio,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isVerified = false,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? phoneNumber,
    String? profileImageUrl,
    String? bio,
    double? rating,
    int? reviewCount,
    bool? isVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
