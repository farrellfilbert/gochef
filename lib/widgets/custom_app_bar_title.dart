import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';

class CustomAppBarTitle extends StatefulWidget {
  final String subtitle;

  const CustomAppBarTitle({
    super.key,
    this.subtitle = '',
  });

  @override
  State<CustomAppBarTitle> createState() => _CustomAppBarTitleState();
}

class _CustomAppBarTitleState extends State<CustomAppBarTitle> {
  late Future<UserModel> _profileFuture;
  late Future<List<AddressModel>> _addressesFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.getProfile();
    _addressesFuture = ApiService.getAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_profileFuture, _addressesFuture]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        String avatarUrl = 'https://ui-avatars.com/api/?name=User';
        String name = 'GoChef';
        String location = 'University District';

        if (snapshot.hasData) {
          final UserModel profile = snapshot.data![0];
          final List<AddressModel> addresses = snapshot.data![1];

          if (profile.avatar.isNotEmpty) avatarUrl = profile.avatar;
          if (profile.name.isNotEmpty) name = profile.name;

          if (addresses.isNotEmpty) {
            final defaultAddress = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
            location = defaultAddress.address;
            if (location.length > 25) {
              location = '${location.substring(0, 25)}...';
            }
          }
        }

        return Row(
          children: [
            Container(
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
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: AppTextStyles.headlineLgMobile(color: AppColors.primary).copyWith(fontSize: 20)),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      widget.subtitle.isNotEmpty ? widget.subtitle : location,
                      style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
