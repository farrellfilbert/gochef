import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ClosedKitchenDialog {
  static void show(
    BuildContext context, {
    required String kitchenName,
    required String businessHours,
    bool isMessaging = false,
    VoidCallback? onProceedAnyway,
  }) {
    final cleanHours = businessHours.trim().isNotEmpty ? businessHours : '09:00 AM - 10:00 PM PST';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E232E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white24, width: 1),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.access_time_filled, color: Colors.redAccent, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Kitchen Closed',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          "You are contacting '$kitchenName' outside of their business hours, please try between $cleanHours.",
          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.45),
        ),
        actions: [
          if (isMessaging && onProceedAnyway != null)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                onProceedAnyway();
              },
              child: const Text('Send Message Anyway', style: TextStyle(color: Colors.white60)),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Understood', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

