import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vinta/core/models/clothing_item.dart';
import 'package:vinta/core/providers/clothing_provider.dart';
import 'package:vinta/theme/app_colors.dart';
import 'package:vinta/features/profile/presentation/screens/profile_detail_screen.dart';
import 'package:vinta/features/chat/presentation/screens/chat_detail_screen.dart';
import 'package:vinta/core/providers/auth_provider.dart';
import 'package:vinta/features/post/presentation/screens/checkout_screen.dart';
import 'package:share_plus/share_plus.dart';

class ClothingItemCard extends StatefulWidget {
  final ClothingItem item;

  const ClothingItemCard({super.key, required this.item});

  @override
  State<ClothingItemCard> createState() => _ClothingItemCardState();
}

class _ClothingItemCardState extends State<ClothingItemCard> with SingleTickerProviderStateMixin {
  bool _showHeart = false;
  late AnimationController _heartController;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final provider = Provider.of<ClothingProvider>(context, listen: false);
    if (!widget.item.isLiked) {
      provider.toggleLike(widget.item.id);
    }
    setState(() => _showHeart = true);
    _heartController.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _showHeart = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClothingProvider>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 40, offset: const Offset(0, 15)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Senior Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ProfileDetailScreen(userId: widget.item.sellerId, username: widget.item.sellerName),
                    ));
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.accentColor.withOpacity(0.1),
                        child: Text(widget.item.sellerName[0], 
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.accentColor)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.item.sellerName, 
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: -0.2)),
                          Text(widget.item.city, 
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (widget.item.sellerVerified)
                  const Icon(Icons.verified_rounded, color: Colors.blue, size: 16),
                if (widget.item.sellerVerified)
                  const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _showReportSheet(context),
                  child: const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // High-Fidelity Interaction Layer
          GestureDetector(
            onDoubleTap: _handleDoubleTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24), 
                  child: Hero(
                    tag: 'feed_img_${widget.item.id}',
                    child: Image.network(
                      widget.item.imageUrls.first,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (_showHeart)
                  const Icon(Icons.favorite, color: Colors.white, size: 100)
                    .animate()
                    .scale(duration: 400.ms, curve: Curves.elasticOut)
                    .fadeOut(delay: 200.ms),
                
                // Floating Metadata Tag
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                    child: Text('${widget.item.price.toInt()} Lek', 
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textPrimary)),
                  ),
                ).animate().slideX(begin: -0.5, duration: 400.ms),
              ],
            ),
          ),

          // Action Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _buildActionIcon(
                  icon: widget.item.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: widget.item.isLiked ? Colors.redAccent : AppColors.textPrimary,
                  onTap: () => provider.toggleLike(widget.item.id),
                ),
                _buildActionIcon(
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(
                        userName: widget.item.sellerName,
                        receiverId: widget.item.sellerId,
                      ),
                    ));
                  },
                ),
                _buildActionIcon(
                  icon: Icons.send_rounded,
                  onTap: () {
                    Share.share('Check out ${widget.item.title} on Vinta! ${widget.item.price.toInt()} Lek');
                  },
                ),
                const Spacer(),
                _buildActionIcon(
                  icon: widget.item.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: widget.item.isSaved ? AppColors.accentColor : null,
                  onTap: () {
                    provider.toggleSave(widget.item.id);
                  },
                ),
              ],
            ),
          ),

          // Engagement Details
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(text: widget.item.sellerName, style: const TextStyle(fontWeight: FontWeight.w900)),
                      const TextSpan(text: ' '),
                      TextSpan(text: widget.item.title),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildDiscoveryTag(widget.item.size, Icons.straighten_rounded),
                    _buildDiscoveryTag(widget.item.brand, Icons.label_important_outline_rounded),
                    _buildDiscoveryTag(widget.item.condition == ClothingCondition.brandNew ? 'New' : 'Used', Icons.auto_awesome_rounded),
                  ],
                ),
                if (widget.item.comments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _showComments(context),
                    child: Text('View all ${widget.item.comments.length} comments',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, curve: Curves.easeOut);
  }

  Widget _buildActionIcon({required IconData icon, Color? color, VoidCallback? onTap}) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color ?? AppColors.textPrimary, size: 26),
    );
  }

  Widget _buildDiscoveryTag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  void _showReportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: AppColors.mediumGray, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.flag_rounded, color: Colors.orange),
              title: const Text('Report this listing', style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted. We\'ll review this listing.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_rounded, color: AppColors.error),
              title: const Text('Block this seller', style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${widget.item.sellerName} has been blocked.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag_rounded, color: AppColors.accentColor),
              title: const Text('Buy this item', style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CheckoutScreen(item: widget.item),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: AppColors.textSecondary),
              title: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentSheet(itemId: widget.item.id),
    );
  }
}

class _CommentSheet extends StatefulWidget {
  final String itemId;
  const _CommentSheet({required this.itemId});

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClothingProvider>(context);
    final item = provider.items.firstWhere((i) => i.id == widget.itemId);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(width: 48, height: 5, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10))),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('Comments', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: item.comments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final comment = item.comments[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 18, backgroundColor: AppColors.accentColor.withOpacity(0.1), child: Text(comment.username[0])),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4),
                              children: [
                                TextSpan(text: comment.username, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.2)),
                                const TextSpan(text: ' '),
                                TextSpan(text: comment.text),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text('2m  Reply  Delete', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const Icon(Icons.favorite_border, size: 14, color: AppColors.textSecondary),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 18, backgroundColor: AppColors.lightGray),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_commentController.text.isNotEmpty) {
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      provider.addComment(widget.itemId, Comment(
                        id: DateTime.now().toString(),
                        userId: auth.user?.id ?? 'anon',
                        username: auth.user?.username ?? 'You',
                        text: _commentController.text,
                        createdAt: DateTime.now(),
                      ));
                      _commentController.clear();
                    }
                  },
                  child: const Text('Post', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.accentColor, fontSize: 14)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
