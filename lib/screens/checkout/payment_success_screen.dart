import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'order_complete_screen.dart';
import '../../services/api_service.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String? sessionId;
  final String? paymentIntentId;
  final String? orderId;

  const PaymentSuccessScreen({
    super.key,
    this.sessionId,
    this.paymentIntentId,
    this.orderId,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  bool _isVerifying = true;
  String _message = 'Verifying your payment...';
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _verifyPayment();
  }

  Future<void> _verifyPayment() async {
    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      if (!mounted) return;
      
      if (attempt > 0) {
        setState(() {
          _retryCount = attempt;
          _message = 'Retrying verification (attempt ${attempt + 1}/${_maxRetries + 1})...';
        });
        // Wait before retry
        await Future.delayed(Duration(seconds: attempt * 2));
        if (!mounted) return;
      }

      try {
        final response = await http.post(
          Uri.parse('${ApiService.baseUrl}/verify_payment.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'session_id': widget.sessionId ?? '',
            'payment_intent_id': widget.paymentIntentId ?? '',
            'order_id': widget.orderId ?? '',
          }),
        ).timeout(const Duration(seconds: 20));

        if (!mounted) return;

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OrderCompleteScreen(
                  orderId: data['order_id']?.toString() ?? 'Unknown',
                  kitchenId: data['kitchen_id']?.toString() ?? '',
                  kitchenName: data['kitchen_name']?.toString() ?? 'Unknown Kitchen',
                  totalAmount: double.tryParse(data['total_amount']?.toString() ?? '') ?? 0.0,
                  itemsCount: int.tryParse(data['items_count']?.toString() ?? '') ?? 1,
                  kitchenAvatar: data['kitchen_avatar']?.toString() ?? '',
                ),
              ),
            );
            return; // Success — exit the retry loop
          } else {
            // Payment not successful according to Stripe/server
            if (attempt == _maxRetries) {
              setState(() {
                _message = data['error'] ?? 'Payment verification failed.';
                _isVerifying = false;
              });
              return;
            }
            // Otherwise retry
            continue;
          }
        } else {
          if (attempt == _maxRetries) {
            setState(() {
              _message = 'Server error (${response.statusCode}) during verification.';
              _isVerifying = false;
            });
            return;
          }
          continue;
        }
      } catch (e) {
        if (attempt == _maxRetries) {
          if (!mounted) return;
          setState(() {
            _message = 'Network error: ${e.toString().length > 100 ? e.toString().substring(0, 100) : e.toString()}';
            _isVerifying = false;
          });
          return;
        }
        // Otherwise retry
        continue;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Payment Status'),
        centerTitle: true,
        automaticallyImplyLeading: !_isVerifying,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isVerifying
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 24),
                    Text(
                      _message,
                      style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                      textAlign: TextAlign.center,
                    ),
                    if (_retryCount > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Please wait...',
                        style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 64),
                    const SizedBox(height: 24),
                    Text(
                      'Payment Failed',
                      style: AppTextStyles.headlineMd(color: AppColors.error),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _message,
                      style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isVerifying = true;
                          _retryCount = 0;
                          _message = 'Verifying your payment...';
                        });
                        _verifyPayment();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: AppColors.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Try Again'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Return to Home'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
