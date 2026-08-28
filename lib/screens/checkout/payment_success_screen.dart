import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'order_complete_screen.dart';
import '../../services/api_service.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String sessionId;

  const PaymentSuccessScreen({super.key, required this.sessionId});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  bool _isVerifying = true;
  String _message = 'Verifying your payment...';

  @override
  void initState() {
    super.initState();
    _verifyPayment();
  }

  Future<void> _verifyPayment() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/verify_payment.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'session_id': widget.sessionId}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OrderCompleteScreen(
                  orderId: data['order_id'] ?? 'Unknown',
                  kitchenId: data['kitchen_id']?.toString() ?? '',
                  kitchenName: data['kitchen_name'] ?? 'Unknown Kitchen',
                  totalAmount: (data['total_amount'] as num?)?.toDouble() ?? 0.0,
                  itemsCount: data['items_count'] ?? 1,
                  kitchenAvatar: data['kitchen_avatar'] ?? '',
                ),
              ),
            );
          }
          return;
        } else {
          setState(() {
            _message = data['error'] ?? 'Payment verification failed.';
            _isVerifying = false;
          });
        }
      } else {
        setState(() {
          _message = 'Server error during verification.';
          _isVerifying = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Network error during verification.';
        _isVerifying = false;
      });
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
        child: _isVerifying
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 24),
                  Text(
                    _message,
                    style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                  ),
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
    );
  }
}
