import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/providers/clothing_provider.dart';
import '../../../../core/models/clothing_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final clothingProvider = Provider.of<ClothingProvider>(context);
    
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accentColor)),
      );
    }

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off_rounded, size: 64, color: AppColors.mediumGray),
              const SizedBox(height: 16),
              const Text('Please sign in to view your profile.', 
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
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

    final myItems = clothingProvider.items.where((i) => i.sellerId == user.id).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('MY PROFILE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
        actions: [
          IconButton(
            onPressed: () => authProvider.logout(),
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
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
                        child: Text(user.username[0], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.accentColor,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.add_a_photo_rounded, size: 14, color: Colors.white),
                            onPressed: () {}, // Add PFP logic
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 32),
                  _buildStat('Posts', myItems.length.toString()),
                  _buildStat('Trust', '4.8'),
                  _buildStat('Sales', '12'),
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
                      Text(user.username, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      if (user.isVerified)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.verified, size: 16, color: Colors.blue),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('No bio yet. Tap to add one!', 
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Edit Profile Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: AppColors.border),
                ),
                child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
                        const Center(child: Text('No saved items yet')),
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
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
            Text('No posts yet', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return GridView.builder(
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemBuilder: (context, index) {
        return Image.network(items[index].imageUrls.first, fit: BoxFit.cover);
      },
    );
  }
}
