import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vinta/core/providers/clothing_provider.dart';
import 'package:vinta/core/models/clothing_item.dart';
import 'package:vinta/theme/app_colors.dart';
import 'package:vinta/features/home/presentation/screens/clothing_item_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Discovery';
  final List<String> _categories = ['Discovery', 'New In', 'Trending', 'Local', 'Bundles'];

  @override
  Widget build(BuildContext context) {
    final clothingProvider = Provider.of<ClothingProvider>(context);
    
    final sortedItems = List<ClothingItem>.from(clothingProvider.items);
    sortedItems.sort((a, b) {
      final scoreA = (a.isLiked ? 1 : 0) + (a.comments.length * 2);
      final scoreB = (b.isLiked ? 1 : 0) + (b.comments.length * 2);
      return scoreB.compareTo(scoreA);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elite Senior Header
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 140,
            backgroundColor: AppColors.background.withOpacity(0.8),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.accentColor.withOpacity(0.08), AppColors.background],
                  ),
                ),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Column(
                     mainAxisSize: MainAxisSize.min,
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text('VINTA', 
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: AppColors.textPrimary, letterSpacing: -2)),
                       Text('EXPLORE THE LOOK', 
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 8, color: AppColors.accentColor, letterSpacing: 2)),
                     ],
                   ),
                   const Spacer(),
                   _buildHeaderAction(Icons.search_rounded),
                   const SizedBox(width: 8),
                   _buildHeaderAction(Icons.notifications_none_rounded),
                ],
              ),
            ),
          ),

          // Elite Category Nav
          SliverToBoxAdapter(
            child: SizedBox(
              height: 70,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategory == _categories[index];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = _categories[index]),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.textPrimary : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: isSelected ? [BoxShadow(color: AppColors.textPrimary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6))] : [],
                        border: isSelected ? null : Border.all(color: AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ).animate().scale(delay: (50 * index).ms, duration: 400.ms, curve: Curves.easeOutBack);
                },
              ),
            ),
          ),

          // Elite Staggered Grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
            sliver: clothingProvider.items.isEmpty 
              ? _buildSkeletonGrid()
              : SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  itemBuilder: (context, index) {
                    final item = sortedItems[index];
                    return _EliteDiscoveryCard(item: item, index: index);
                  },
                  childCount: sortedItems.length,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
      child: Icon(icon, size: 20, color: AppColors.textPrimary),
    );
  }

  Widget _buildSkeletonGrid() {
    return SliverMasonryGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.white,
        child: Container(height: 250, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32))),
      ),
      childCount: 4,
    );
  }
}

class _EliteDiscoveryCard extends StatelessWidget {
  final ClothingItem item;
  final int index;
  const _EliteDiscoveryCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text(item.title.toUpperCase())),
            body: SingleChildScrollView(child: ClothingItemCard(item: item)),
          ),
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'elite_img_${item.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    child: Image.network(
                      item.imageUrls.first, 
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) => progress == null ? child : _buildShimmerPlaceholder(),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(30)),
                    child: Text(item.condition == ClothingCondition.brandNew ? 'NEW' : 'USED', 
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1, color: AppColors.accentColor)),
                  ),
                ),
                Positioned(
                  bottom: 14,
                  right: 14,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: Icon(Icons.favorite_rounded, size: 18, color: item.isLiked ? AppColors.secondaryColor : AppColors.mediumGray),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      Text('${item.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 16, letterSpacing: -0.5)),
                      const Text(' Lek', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textSecondary, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: (40 * index).ms).slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOutQuad),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.white,
      child: Container(color: Colors.white, height: 250),
    );
  }
}
