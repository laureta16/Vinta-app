import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/clothing_item.dart';
import '../../../../core/providers/clothing_provider.dart';
import '../../../../theme/app_colors.dart';

class SearchResultsScreen extends StatelessWidget {
  final String query;
  final String? city;
  final int initialTab;

  const SearchResultsScreen({super.key, required this.query, this.city, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialTab,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(city ?? query),
          bottom: const TabBar(
            indicatorColor: AppColors.accentColor,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Items'),
              Tab(text: 'People'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildItemsGrid(context),
            _buildPeopleList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsGrid(BuildContext context) {
    final clothingProvider = Provider.of<ClothingProvider>(context);
    final allItems = clothingProvider.items;
    
    final filteredItems = allItems.where((item) {
      final matchesQuery = item.title.toLowerCase().contains(query.toLowerCase()) || 
                           item.brand.toLowerCase().contains(query.toLowerCase());
      final matchesCity = city == null || item.city == city;
      return matchesQuery && matchesCity;
    }).toList();

    if (filteredItems.isEmpty) {
      return const Center(child: Text('No items found'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildSearchItemCard(context, item);
      },
    );
  }

  Widget _buildPeopleList(BuildContext context) {
    // Mock user search results
    final mockUsers = [
      {'name': query.isEmpty ? 'VintaRetro' : '$query Shop', 'verified': true, 'rating': 4.9, 'count': 120},
      {'name': 'TopSeller_AL', 'verified': false, 'rating': 4.5, 'count': 45},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: mockUsers.length,
      separatorBuilder: (context, index) => const Divider(height: 32),
      itemBuilder: (context, index) {
        final user = mockUsers[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.lightGray,
            child: Text(user['name'].toString()[0], style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          title: Row(
            children: [
              Text(user['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (user['verified'] as bool)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.verified, size: 16, color: Colors.blue),
                ),
            ],
          ),
          subtitle: Row(
            children: [
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              Text('${user['rating']} (${user['count']} reviews)'),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        );
      },
    );
  }

  Widget _buildSearchItemCard(BuildContext context, ClothingItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(item.imageUrls.first),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text('${item.price.toInt()} Lek', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, 
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.2)),
        const SizedBox(height: 2),
        Row(
          children: [
            Text('${item.size} • ${item.brand}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
            const Spacer(),
            const Icon(Icons.location_on_outlined, size: 10, color: AppColors.textSecondary),
            Text(item.city, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
