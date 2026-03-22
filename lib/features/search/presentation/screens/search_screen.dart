import 'package:flutter/material.dart';
import '../../../../core/constants/albanian_cities.dart';
import '../../../../theme/app_colors.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<String> _filteredCities = albanianCities;
  
  // Mock suggested accounts
  final List<Map<String, String>> _suggestedAccounts = [
    {'name': 'VintaRetro', 'handle': '@vintaretro', 'verified': 'true'},
    {'name': 'Fashionista_AL', 'handle': '@fashion_al', 'verified': 'false'},
    {'name': 'Berti_M', 'handle': '@berti_m', 'verified': 'true'},
  ];

  void _filterCities(String query) {
    setState(() {
      _filteredCities = albanianCities
          .where((city) => city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _navigateToResults(String query, {String? city, bool isUser = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(query: query, city: city, initialTab: isUser ? 1 : 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search for items, brands, or users...',
            border: InputBorder.none,
          ),
          onChanged: _filterCities,
          onSubmitted: (value) => _navigateToResults(value),
        ),
      ),
      body: ListView(
        children: [
          if (_searchController.text.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text('SUGGESTED ACCOUNTS', 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2, color: AppColors.textSecondary)),
            ),
            ..._suggestedAccounts.map((account) => ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.mediumGray,
                child: Text(account['name']![0], style: const TextStyle(color: Colors.white)),
              ),
              title: Row(
                children: [
                  Text(account['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (account['verified'] == 'true')
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.verified, size: 14, color: Colors.blue),
                    ),
                ],
              ),
              subtitle: Text(account['handle']!),
              onTap: () => _navigateToResults(account['name']!, isUser: true),
            )),
          ],
          
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('SEARCH BY CITY', 
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2, color: AppColors.textSecondary)),
          ),
          ..._filteredCities.map((city) => ListTile(
                leading: const Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
                title: Text(city),
                onTap: () => _navigateToResults('', city: city),
              )),
          if (_filteredCities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No cities found', style: TextStyle(color: AppColors.textSecondary)),
            ),
        ],
      ),
    );
  }
}
