import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/repositories/supabase_repository.dart';

class ReviewItem {
  final String id;
  final String reviewerName;
  final int stars;
  final String text;
  final DateTime createdAt;

  ReviewItem({
    required this.id,
    required this.reviewerName,
    required this.stars,
    required this.text,
    required this.createdAt,
  });
}

class ReviewsScreen extends StatefulWidget {
  final String sellerId;
  final String sellerName;
  const ReviewsScreen({super.key, required this.sellerId, required this.sellerName});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final List<ReviewItem> _reviews = [];
  bool _isLoading = true;
  int _selectedStars = 5;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseRepository().fetchReviews(widget.sellerId);
      setState(() {
        _reviews.clear();
        for (var d in data) {
          _reviews.add(ReviewItem(
            id: d['id'],
            reviewerName: d['profiles'] != null ? d['profiles']['username'] : 'User',
            stars: d['rating'],
            text: d['comment'] ?? '',
            createdAt: DateTime.parse(d['created_at']),
          ));
        }
      });
    } catch (e) {
      debugPrint('Error loading reviews: $e');
    }
    setState(() => _isLoading = false);
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.map((r) => r.stars).reduce((a, b) => a + b) / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.sellerName.toUpperCase()} · REVIEWS',
            style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 14)),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.accentColor))
        : Column(
            children: [
              // Rating Summary
              Container(
                padding: const EdgeInsets.all(24),
                color: AppColors.lightGray.withOpacity(0.3),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          _reviews.isEmpty ? '—' : _averageRating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
                        ),
                        Row(
                          children: List.generate(5, (i) => Icon(
                            i < _averageRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: Colors.amber, size: 16,
                          )),
                        ),
                        const SizedBox(height: 4),
                        Text('${_reviews.length} review${_reviews.length == 1 ? '' : 's'}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        children: List.generate(5, (i) {
                          final star = 5 - i;
                          final count = _reviews.where((r) => r.stars == star).length;
                          final pct = _reviews.isEmpty ? 0.0 : count / _reviews.length;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text('$star', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                const SizedBox(width: 4),
                                const Icon(Icons.star_rounded, size: 10, color: Colors.amber),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      backgroundColor: AppColors.lightGray,
                                      valueColor: const AlwaysStoppedAnimation(Colors.amber),
                                      minHeight: 6,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(width: 20, child: Text('$count',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              // Reviews List
              Expanded(
                child: _reviews.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rate_review_outlined, size: 56, color: AppColors.mediumGray),
                            SizedBox(height: 12),
                            Text('No reviews yet', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text('Be the first to leave a review!', style: TextStyle(color: AppColors.mediumGray, fontSize: 12)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadReviews,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _reviews.length,
                          separatorBuilder: (_, __) => const Divider(height: 24),
                          itemBuilder: (ctx, i) {
                            final r = _reviews[i];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.accentColor,
                                      child: Text(r.reviewerName[0],
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(r.reviewerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                    const Spacer(),
                                    ...List.generate(5, (j) => Icon(
                                      j < r.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                                      size: 14, color: Colors.amber,
                                    )),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(r.text, style: const TextStyle(height: 1.4, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(_timeAgo(r.createdAt),
                                    style: const TextStyle(color: AppColors.mediumGray, fontSize: 11)),
                              ],
                            );
                          },
                        ),
                      ),
              ),

              // Write Review
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.5))),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Star selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) => GestureDetector(
                          onTap: () => setState(() => _selectedStars = i + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              i < _selectedStars ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: Colors.amber, size: 28,
                            ),
                          ),
                        )),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              decoration: InputDecoration(
                                hintText: 'Write a review...',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _submitReview,
                            icon: const Icon(Icons.send_rounded, color: AppColors.accentColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _submitReview() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    try {
      await SupabaseRepository().createReview(
        sellerId: widget.sellerId,
        rating: _selectedStars,
        comment: text,
      );
      _textController.clear();
      _selectedStars = 5;
      _loadReviews();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving review: $e')),
      );
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
