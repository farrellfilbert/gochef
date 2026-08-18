import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/api_service.dart';

class RateOrderDialog extends StatefulWidget {
  final String orderId;
  final int? kitchenId;
  final String kitchenName;
  final String kitchenAvatar;
  final VoidCallback? onSubmitted;

  const RateOrderDialog({
    super.key,
    required this.orderId,
    this.kitchenId,
    required this.kitchenName,
    this.kitchenAvatar = '',
    this.onSubmitted,
  });

  static Future<void> show(
    BuildContext context, {
    required String orderId,
    int? kitchenId,
    required String kitchenName,
    String kitchenAvatar = '',
    VoidCallback? onSubmitted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RateOrderDialog(
        orderId: orderId,
        kitchenId: kitchenId,
        kitchenName: kitchenName,
        kitchenAvatar: kitchenAvatar,
        onSubmitted: onSubmitted,
      ),
    );
  }

  @override
  State<RateOrderDialog> createState() => _RateOrderDialogState();
}

class _RateOrderDialogState extends State<RateOrderDialog> {
  int _selectedRating = 5;
  final TextEditingController _commentController = TextEditingController();
  final List<String> _quickTags = [
    'Super Tasty 😋',
    'Hot & Fresh ♨️',
    'Fast Delivery ⚡',
    'Great Packaging 📦',
    'Friendly Chef 👨‍🍳',
    'Generous Portion 🍲',
  ];
  final Set<String> _selectedTags = {};
  bool _isSubmitting = false;

  final Map<int, String> _ratingLabels = {
    1: '😞 Disappointing',
    2: '😕 Could Be Better',
    3: '😐 Average / Okay',
    4: '😋 Delicious & Fresh!',
    5: '🌟 Outstanding Experience!',
  };

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);

    String finalComment = _commentController.text.trim();
    if (_selectedTags.isNotEmpty) {
      final tagsString = _selectedTags.join(', ');
      finalComment = finalComment.isEmpty ? tagsString : '$finalComment ($tagsString)';
    }

    try {
      final success = await ApiService.submitReview(
        rating: _selectedRating,
        comment: finalComment,
        kitchenId: widget.kitchenId,
        orderId: widget.orderId,
      );

      if (mounted) {
        Navigator.pop(context);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Text('Thank you! Your review has been published ⭐'),
                ],
              ),
              backgroundColor: AppColors.surfaceContainerHighest,
              behavior: SnackBarBehavior.floating,
            ),
          );
          widget.onSubmitted?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit review. Please try again.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Avatar & Title
            CircleAvatar(
              radius: 32,
              backgroundImage: widget.kitchenAvatar.isNotEmpty
                  ? NetworkImage(widget.kitchenAvatar)
                  : null,
              backgroundColor: AppColors.surfaceContainerHigh,
              child: widget.kitchenAvatar.isEmpty
                  ? const Icon(Icons.restaurant, color: Colors.white, size: 30)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              'How was your meal?',
              style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'from ${widget.kitchenName} • ${widget.orderId}',
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Rating Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                final isSelected = starValue <= _selectedRating;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = starValue;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: AnimatedScale(
                      scale: isSelected ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: isSelected ? Colors.amber : Colors.white24,
                        size: 42,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),

            // Star label
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey<int>(_selectedRating),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _ratingLabels[_selectedRating] ?? 'Great!',
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Tag Chips
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Quick feedback tags:', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickTags.map((tag) {
                final isTagSelected = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isTagSelected) {
                        _selectedTags.remove(tag);
                      } else {
                        _selectedTags.add(tag);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isTagSelected ? Colors.white : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isTagSelected ? Colors.white : Colors.white12,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: isTagSelected ? Colors.black : Colors.white70,
                        fontSize: 12,
                        fontWeight: isTagSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Comment text area
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: _commentController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Tell the chef what made this dish special...',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _isSubmitting ? null : _submitReview,
                child: _isSubmitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Submit Review ⭐',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
