import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../models/review_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewsScreen extends StatefulWidget {
  final int kitchenId;

  const ReviewsScreen({super.key, required this.kitchenId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  bool _isLoading = true;
  List<ReviewModel> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    try {
      final reviews = await ApiService.getKitchenReviews(widget.kitchenId);
      setState(() {
        _reviews = reviews;
      });
    } catch (e) {
      debugPrint('Error loading reviews: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Customer Reviews', style: AppTextStyles.headlineMd(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _reviews.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_border, size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text('No reviews yet.', style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadReviews,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(review.userAvatar.isNotEmpty 
                                    ? review.userAvatar 
                                    : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(review.userName)}'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(review.userName, style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                                      Text(timeago.format(DateTime.parse(review.createdAt)), style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, color: AppColors.primary, size: 14),
                                      const SizedBox(width: 4),
                                      Text(review.rating.toStringAsFixed(1), style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (review.comment.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(review.comment, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                            ]
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
