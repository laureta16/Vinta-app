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
}
