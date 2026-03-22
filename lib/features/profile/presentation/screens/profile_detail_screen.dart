import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/clothing_item.dart';
import '../../../../core/providers/clothing_provider.dart';
import '../../../../theme/app_colors.dart';

class ProfileDetailScreen extends StatelessWidget {
  final String userId;
  final String username;

  const ProfileDetailScreen({super.key, required this.userId, required this.username});

  @override
  Widget build(BuildContext context) {
    final clothingProvider = Provider.of<ClothingProvider>(context);
    final userItems = clothingProvider.items.where((item) => item.sellerId == userId).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(username.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz_rounded)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // User Info Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.lightGray,
                    child: Text(username[0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 32),
                  _buildStat('Posts', userItems.length.toString()),
                  _buildStat('Followers', '1.2k'),
                  _buildStat('Following', '450'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Bio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    const SizedBox(height: 4),
                    const Text('Fashion enthusiast & vintage curator in Albania. 🇦🇱\nDM for bundles and worldwide shipping.', 
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Follow'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: AppColors.border),
                      ),
                      child: const Text('Message'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Grid of items
            const Divider(height: 1),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemBuilder: (context, index) {
                return Image.network(userItems[index].imageUrls.first, fit: BoxFit.cover);
              },
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
