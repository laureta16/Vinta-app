import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/providers/clothing_provider.dart';
import '../../../../core/models/clothing_item.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/repositories/supabase_repository.dart';
import '../../../common/presentation/screens/settings_screen.dart';
import '../../../common/presentation/screens/order_history_screen.dart';
import '../../../post/presentation/screens/edit_post_screen.dart';
import './reviews_screen.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _bioController = TextEditingController();
  String _bio = 'No bio yet. Tap to add one!';

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _editBio(AuthProvider auth) async {
    final currentBio = auth.user?.bio ?? '';
    _bioController.text = currentBio;

    final nextBio = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit bio',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 12),
              TextField(
                controller: _bioController,
                maxLines: 3,
                maxLength: 160,
                decoration: const InputDecoration(
                    hintText: 'Tell people what you sell and your style.'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_bioController.text.trim()),
                  child: const Text('Save Bio'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || nextBio == null) return;
    await auth.updateBio(nextBio);
    if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage!), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateAvatar(AuthProvider auth) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading image...'), duration: Duration(seconds: 1)),
        );
      }

      final url = await StorageService().uploadFile(image);
      if (url != null) {
        await auth.updateAvatar(url);
        if (mounted) {
          if (auth.errorMessage != null) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(auth.errorMessage!), backgroundColor: Colors.red),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile picture updated!'), backgroundColor: Colors.green),
            );
          }
        }
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final clothingProvider = Provider.of<ClothingProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppColors.accentColor)),
      );
    }

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off_rounded,
                  size: 64, color: AppColors.mediumGray),
              const SizedBox(height: 16),
              const Text('Please sign in to view your profile.',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => authProvider.logout(), // Or navigate to Login
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      );
    }

    final myItems =
        clothingProvider.items.where((i) => i.sellerId == user.id).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('MY PROFILE',
            style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_rounded, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.lightGray,
                          backgroundImage: user.profileImageUrl != null
                              ? NetworkImage(user.profileImageUrl!)
                              : null,
                          child: user.profileImageUrl == null
                              ? Text(user.username[0],
                                  style: const TextStyle(
                                      fontSize: 28, fontWeight: FontWeight.bold))
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.accentColor,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.add_a_photo_rounded,
                                  size: 14, color: Colors.white),
                              onPressed: () => _updateAvatar(authProvider),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 32),
                    _buildStat('Posts', myItems.length.toString()),
                    FutureBuilder<Map<String, int>>(
                      future: SupabaseRepository().getFollowStats(user.id),
                      builder: (context, snapshot) {
                        return _buildStat('Followers', (snapshot.data?['followers'] ?? 0).toString());
                      },
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ReviewsScreen(sellerId: user.id, sellerName: user.username),
                      )),
                      child: _buildStat('Reviews', '4.9 ★'),
                    ),
                    FutureBuilder<Map<String, int>>(
                      future: SupabaseRepository().getFollowStats(user.id),
                      builder: (context, snapshot) {
                        return _buildStat('Following', (snapshot.data?['following'] ?? 0).toString());
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Bio & Verification
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(user.username,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 16)),
                      if (user.isVerified)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.verified,
                              size: 16, color: Colors.blue),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _editBio(authProvider),
                    child: Text(
                      user.bio ?? 'No bio yet. Tap to add one!',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Edit Profile Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _editBio(authProvider),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text('Edit Profile',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text('My Orders',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Personal Listings Grid
            const Divider(height: 1),
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    indicatorColor: AppColors.accentColor,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textSecondary,
                    tabs: [
                      Tab(icon: Icon(Icons.grid_on_rounded)),
                      Tab(icon: Icon(Icons.bookmark_border_rounded)),
                    ],
                  ),
                  SizedBox(
                    height: 400, // Fixed height for grid in scrollview
                    child: TabBarView(
                      children: [
                        _buildItemsGrid(myItems),
                        _buildItemsGrid(clothingProvider.savedItems),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildItemsGrid(List<ClothingItem> items) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 48, color: AppColors.border),
            SizedBox(height: 12),
            Text('No posts yet',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    final clothingProvider = Provider.of<ClothingProvider>(context, listen: false);

    return GridView.builder(
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => EditPostScreen(item: item),
            ));
          },
          onLongPress: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Listing?'),
                content: const Text('This action cannot be undone.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true), 
                    child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await clothingProvider.deletePost(item.id);
            }
          },
          child: Image.network(item.imageUrls.first, fit: BoxFit.cover),
        );
      },
    );
  }
}
