import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/clothing_item.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/clothing_provider.dart';
import '../../../../core/repositories/supabase_repository.dart';
import '../../../../theme/app_colors.dart';

class SearchResultsScreen extends StatelessWidget {
  final String query;
  final String? city;
  final int initialTab;

  const SearchResultsScreen(
      {super.key, required this.query, this.city, this.initialTab = 0});

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
    final filteredItems =
        clothingProvider.filterItems(query: query, city: city);

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
    if (query.isEmpty) {
      return const Center(
          child: Text('Type a username or shop name to find people.'));
    }

    return FutureBuilder(
      future: SupabaseRepository().searchProfiles(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.accentColor));
        }

        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return const Center(child: Text('No members found.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (context, index) => const Divider(height: 32),
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.lightGray,
                backgroundImage: user.profileImageUrl != null ? NetworkImage(user.profileImageUrl!) : null,
                child: user.profileImageUrl == null
                    ? Text(user.username[0],
                        style: const TextStyle(fontWeight: FontWeight.bold))
                    : null,
              ),
              title: Row(
                children: [
                  Text(user.username,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (user.isVerified)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.verified, size: 16, color: Colors.blue),
                    ),
                ],
              ),
              subtitle: Text(user.bio ?? 'Vinta Member', 
                maxLines: 1, 
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to Profile Details (Phase 10: Real Profiles)
              },
            );
          },
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
                image: NetworkImage(
                  item.imageUrls.isNotEmpty
                      ? item.imageUrls.first
                      : 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=1600',
                ),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text('${item.price.toInt()} Lek',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        Text(item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textPrimary, height: 1.2)),
        const SizedBox(height: 2),
        Row(
          children: [
            Text('${item.size} • ${item.brand}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 10)),
            const Spacer(),
            const Icon(Icons.location_on_outlined,
                size: 10, color: AppColors.textSecondary),
            Text(item.city,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
