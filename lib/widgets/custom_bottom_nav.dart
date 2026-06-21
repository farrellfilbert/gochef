import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../core/theme.dart';
import 'premium/bouncing_tap.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNavItem(LucideIcons.home, 0),
                  const SizedBox(width: 4),
                  _buildNavItem(LucideIcons.compass, 1),
                  const SizedBox(width: 4),
                  _buildNavItem(LucideIcons.receipt, 2),
                  const SizedBox(width: 4),
                  _buildNavItem(LucideIcons.user, 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = index == currentIndex;
    
    return BouncingTap(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: isSelected 
            ? const EdgeInsets.symmetric(horizontal: 18, vertical: 8) 
            : const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppTheme.backgroundDark : AppTheme.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}
