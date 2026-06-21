import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? color;
  final Gradient? gradient;
  final BorderRadius borderRadius;
  final Border? border;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.color,
    this.gradient,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.border,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: AppTheme.fuchsiaPrimary.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color,
              gradient: gradient ?? (color == null ? AppTheme.glassGradient : null),
              border: border ?? Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1.0,
              ),
              borderRadius: borderRadius,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
