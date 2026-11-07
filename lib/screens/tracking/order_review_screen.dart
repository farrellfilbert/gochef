import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';

class OrderReviewScreen extends StatefulWidget {
  final String orderId;
  final String kitchenId;
  final String kitchenName;

  const OrderReviewScreen({
    super.key,
    required this.orderId,
    required this.kitchenId,
    required this.kitchenName,
  });

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _customTipController = TextEditingController();
  double _tipAmount = 0.0;
  bool _isCustomTip = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _customTipController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);
    final success = await ApiService.submitReview(
      kitchenId: int.tryParse(widget.kitchenId),
      orderId: widget.orderId,
      rating: _rating,
      comment: _commentController.text,
      tipAmount: _tipAmount,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _tipAmount > 0
                  ? 'Thank you! Review and \$${_tipAmount.toStringAsFixed(2)} tip submitted 🎉'
                  : 'Review submitted! Thank you.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit review.')),
        );
      }
    }
  }

  Widget _buildTipChip({required double amount, required String label}) {
    final isSelected = !_isCustomTip && _tipAmount == amount;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isCustomTip = false;
            _tipAmount = amount;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE42278) : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFE42278) : Colors.white12,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTipChip() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isCustomTip = true;
            final parsed = double.tryParse(_customTipController.text) ?? 0.0;
            _tipAmount = parsed;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isCustomTip ? const Color(0xFFE42278) : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isCustomTip ? const Color(0xFFE42278) : Colors.white12,
              width: 1.5,
            ),
          ),
          child: Text(
            'Custom',
            style: TextStyle(
              color: Colors.white,
              fontWeight: _isCustomTip ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            Text('Order Delivered!', style: AppTextStyles.displayLgMobile(color: Colors.white)),
            const SizedBox(height: 8),
            Text('How was your experience with ${widget.kitchenName}?', 
              style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            
            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              _rating == 5 ? 'Excellent!' : _rating >= 4 ? 'Good' : _rating >= 3 ? 'Okay' : 'Poor',
              style: AppTextStyles.headlineMd(color: const Color(0xFFE42278)),
            ),
            const SizedBox(height: 24),
            
            // Comment Field
            TextField(
              controller: _commentController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Leave a comment (optional)...',
                hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                filled: true,
                fillColor: AppColors.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tip Chef & Courier Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _tipAmount > 0 ? const Color(0xFFE42278).withOpacity(0.5) : Colors.white12,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE42278).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.volunteer_activism_rounded,
                          color: Color(0xFFE42278),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Tip Your Chef & Courier',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (_tipAmount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE42278),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+\$${_tipAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '100% of your tip goes directly to your home chef & delivery courier.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildTipChip(amount: 0.0, label: 'No Tip'),
                      const SizedBox(width: 6),
                      _buildTipChip(amount: 2.0, label: '\$2'),
                      const SizedBox(width: 6),
                      _buildTipChip(amount: 3.0, label: '\$3'),
                      const SizedBox(width: 6),
                      _buildTipChip(amount: 5.0, label: '\$5'),
                      const SizedBox(width: 6),
                      _buildCustomTipChip(),
                    ],
                  ),
                  if (_isCustomTip) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _customTipController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.attach_money, color: Color(0xFFE42278), size: 16),
                        hintText: 'Enter custom tip (e.g. 7.50)',
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                        filled: true,
                        fillColor: AppColors.surfaceContainerHigh,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0.0;
                        setState(() {
                          _tipAmount = parsed;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _tipAmount > 0
                            ? 'SUBMIT REVIEW & TIP (\$${_tipAmount.toStringAsFixed(2)})'
                            : 'SUBMIT REVIEW',
                        style: AppTextStyles.labelMono(color: Colors.white).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('Skip for now', style: TextStyle(color: AppColors.onSurfaceVariant)),
            )
          ],
        ),
      ),
    );
  }
}
