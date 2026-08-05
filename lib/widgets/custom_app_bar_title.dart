import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class CustomAppBarTitle extends StatefulWidget {
  final String subtitle;

  const CustomAppBarTitle({
    super.key,
    this.subtitle = 'University District',
  });

  @override
  State<CustomAppBarTitle> createState() => _CustomAppBarTitleState();
}

class _CustomAppBarTitleState extends State<CustomAppBarTitle> {
  late Future<UserModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FutureBuilder<UserModel>(
          future: _profileFuture,
          builder: (context, profileSnapshot) {
            String avatarUrl = 'https://via.placeholder.com/150';
            if (profileSnapshot.hasData && profileSnapshot.data!.avatar.isNotEmpty) {
              avatarUrl = profileSnapshot.data!.avatar;
            }
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                image: DecorationImage(
                  image: NetworkImage(avatarUrl),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('GoChef', style: AppTextStyles.headlineLgMobile(color: AppColors.primary).copyWith(fontSize: 20)),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  widget.subtitle,
                  style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
