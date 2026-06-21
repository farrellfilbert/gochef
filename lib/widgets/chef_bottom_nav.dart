import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../core/theme.dart';
import 'premium/bouncing_tap.dart';

class ChefBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ChefBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            height: 90,
            padding: const EdgeInsets.only(bottom: 16, top: 8, left: 16, right: 16),
            decoration: BoxDecoration(
              color: AppTheme.chefBackground.withValues(alpha: 0.9),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard', 0),
                _buildNavItem(Icons.countertops_outlined, Icons.countertops, 'Kitchen', 1),
                _buildNavItem(Icons.receipt_long_outlined, Icons.receipt_long, 'Orders', 2, showBadge: true),
                _buildNavItem(Icons.payments_outlined, Icons.payments, 'Earnings', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData iconOutlined, IconData iconFilled, String label, int index, {bool showBadge = false}) {
    final isSelected = index == currentIndex;
    
    return BouncingTap(
      onTap: () => onTap(index),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.chefSurfaceVariant.withValues(alpha: 0.4) : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? iconFilled : iconOutlined,
                  color: isSelected ? AppTheme.chefPrimaryContainer : AppTheme.chefTextSecondary.withValues(alpha: 0.7),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppTheme.chefPrimaryContainer : AppTheme.chefTextSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (showBadge)
            Positioned(
              top: 4,
              right: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.chefPrimaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.chefBackground, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
