import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/clothing_provider.dart';
import '../../../../core/repositories/supabase_repository.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/models/user_model.dart';
import '../../../chat/presentation/screens/chat_detail_screen.dart';

class ProfileDetailScreen extends StatefulWidget {
  final String userId;
  final String username;

  const ProfileDetailScreen(
      {super.key, required this.userId, required this.username});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  bool _isFollowing = false;
  Map<String, int>? _stats;
  UserModel? _fullProfile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final repo = SupabaseRepository();
    
    try {
      final results = await Future.wait([
        repo.getProfile(widget.userId),
        repo.isFollowing(auth.user?.id ?? '', widget.userId),
        repo.getFollowStats(widget.userId),
      ]);

      if (mounted) {
        setState(() {
          _fullProfile = results[0] as UserModel?;
          _isFollowing = results[1] as bool;
          _stats = results[2] as Map<String, int>?;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile detail: $e');
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load full profile. Some details may be missing.')),
        );
      }
    }
  }

  Future<void> _toggleFollow() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to follow members.')),
      );
      return;
    }

    setState(() => _isFollowing = !_isFollowing);
    try {
      await auth.toggleFollow(widget.userId);
      // Refresh stats
      final newStats = await SupabaseRepository().getFollowStats(widget.userId);
      if (mounted) setState(() => _stats = newStats);
    } catch (e) {
      setState(() => _isFollowing = !_isFollowing);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accentColor)),
      );
    }

    final clothingProvider = Provider.of<ClothingProvider>(context);
    final userItems = clothingProvider.items
        .where((item) => item.sellerId == widget.userId)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.username.toUpperCase(),
            style: const TextStyle(
                fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
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
                    backgroundImage: _fullProfile?.profileImageUrl != null 
                        ? NetworkImage(_fullProfile!.profileImageUrl!) 
                        : null,
                    child: _fullProfile?.profileImageUrl == null
                        ? Text(widget.username[0],
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold))
                        : null,
                  ),
                  const SizedBox(width: 32),
                  _buildStat('Posts', userItems.length.toString()),
                  _buildStat('Followers', (_stats?['followers'] ?? 0).toString()),
                  _buildStat('Following', (_stats?['following'] ?? 0).toString()),
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
                    Row(
                      children: [
                        Text(widget.username,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 16)),
                        if (_fullProfile?.isVerified ?? false)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.verified, size: 16, color: Colors.blue),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                        _fullProfile?.bio ?? 'Fashion enthusiast from Albania 🇦🇱',
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4)),
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
                      onPressed: _toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFollowing ? AppColors.lightGray : AppColors.accentColor,
                        foregroundColor: _isFollowing ? AppColors.textPrimary : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_isFollowing ? 'Following' : 'Follow'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            userName: widget.username,
                            receiverId: widget.userId,
                          ),
                        ));
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text('Message', style: TextStyle(color: AppColors.textPrimary)),
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
                return Image.network(userItems[index].imageUrls.first,
                    fit: BoxFit.cover);
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
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
