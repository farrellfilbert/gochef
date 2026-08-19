import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../screens/chat/chat_screen.dart';

class SupportHelper {
  /// Opens real-time Live Chat directly with GoChef Support Admin
  static Future<void> openLiveSupportChat(BuildContext context, {String? orderId}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    final admin = await ApiService.getSupportAdmin();
    
    if (context.mounted) {
      Navigator.pop(context); // dismiss loading dialog

      final adminId = admin?['id']?.toString() ?? '1';
      final adminName = admin?['name']?.toString() ?? 'GoChef Live Support 🎧';
      final adminAvatar = admin?['avatar']?.toString() ?? 'https://ui-avatars.com/api/?name=GoChef+Support&background=E53935&color=fff';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            otherParticipantId: adminId,
            otherParticipantName: adminName,
            otherParticipantAvatar: ApiService.formatImageUrl(adminAvatar),
            orderId: orderId,
            isOnline: true,
          ),
        ),
      );
    }
  }
}
