import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../models/review_model.dart';

class ReviewsRatingsScreen extends StatefulWidget {
  final int kitchenId;

  const ReviewsRatingsScreen({super.key, required this.kitchenId});

  @override
  State<ReviewsRatingsScreen> createState() => _ReviewsRatingsScreenState();
}

class _ReviewsRatingsScreenState extends State<ReviewsRatingsScreen> {
  int selectedFilter = 0;
  final List<String> filters = ['All', 'Most Recent', 'Highest Rated', 'With Photos'];
  late Future<List<ReviewModel>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ApiService.getReviews(kitchenId: widget.kitchenId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F131C).withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Reviews & Ratings',
            style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outlineVariant.withValues(alpha: 0.3), height: 1),
        ),
      ),
      body: FutureBuilder<List<ReviewModel>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading reviews', style: AppTextStyles.bodyMd(color: AppColors.error)));
          }

          final reviews = snapshot.data ?? [];
          
          double avgRating = 0;
          if (reviews.isNotEmpty) {
            avgRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
          }

          // Apply filters
          List<ReviewModel> filteredReviews = List.from(reviews);
          if (selectedFilter == 1) {
            // Most recent - default sort from API
          } else if (selectedFilter == 2) {
            // Highest Rated
            filteredReviews.sort((a, b) => b.rating.compareTo(a.rating));
          } else if (selectedFilter == 3) {
            // With photos - not supported in this model yet
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                // Overall Rating
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      Text(avgRating.toStringAsFixed(1), style: AppTextStyles.displayLgMobile(color: AppColors.onSurface)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < avgRating.round() ? Icons.star : Icons.star_border, 
                            color: const Color(0xFFE42278), 
                            size: 32
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('BASED ON ${reviews.length} REVIEWS', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(letterSpacing: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Filters
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      bool isSelected = selectedFilter == index;
                      return GestureDetector(
                        onTap: () => setState(() => selectedFilter = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Color(0xFFE42278), Color(0xFFdb6c9b)],
                                  )
                                : null,
                            color: isSelected ? null : AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(32),
                            border: isSelected ? null : Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                            boxShadow: isSelected
                                ? [BoxShadow(color: const Color(0xFFE42278).withValues(alpha: 0.2), blurRadius: 10)]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            filters[index],
                            style: AppTextStyles.labelMono(color: isSelected ? Colors.white : AppColors.onSurface),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Reviews List
                if (filteredReviews.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text('No reviews yet.', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                  )
                else
                  ...filteredReviews.map((review) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _buildReviewCard(
                        name: review.userName,
                        time: review.createdAt,
                        avatar: review.userAvatar,
                        rating: review.rating,
                        text: review.comment,
                        helpfulCount: 0,
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String time,
    required String avatar,
    required int rating,
    required String text,
    bool isItalic = false,
    String? orderedItem,
    required int helpfulCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF31353F).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA98890).withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                        image: DecorationImage(image: NetworkImage(avatar), fit: BoxFit.cover,
                        onError: (_, __) => const NetworkImage('https://ui-avatars.com/api/?name=User')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name.isNotEmpty ? name : 'Anonymous', style: AppTextStyles.headlineMd(color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(time, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: index < rating ? const Color(0xFFE42278) : AppColors.onSurfaceVariant,
                    size: 18,
                  );
                }),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: AppTextStyles.bodyLg(color: AppColors.onSurface).copyWith(fontStyle: isItalic ? FontStyle.italic : FontStyle.normal),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.thumb_up_outlined, color: AppColors.onSurfaceVariant, size: 16),
              const SizedBox(width: 4),
              Text('Helpful ($helpfulCount)', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
            ],
          )
        ],
      ),
    );
  }
}
