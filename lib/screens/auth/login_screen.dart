import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../main.dart';
import 'login_phone_otp_screen.dart';
import 'sign_up_screen.dart';

/// Login Main Screen — replicates Login Main.html exactly
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  bool _isLoading = false;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _emailFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _floatController.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _onContinue() async {
    if (_emailController.text.isEmpty) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isLoading = false);
    // Navigate to home or next step
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigation(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: Stack(
        children: [
          // ─── Atmospheric Background Glows ───
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.1,
            left: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -MediaQuery.of(context).size.height * 0.1,
            right: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tertiaryContainer.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Blur the background glows
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: const SizedBox(),
            ),
          ),

          // ─── Main Content ───
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      // ─── Logo Area ───
                      _buildLogoArea(),
                      const SizedBox(height: 48),

                      // ─── Glassmorphism Card ───
                      _buildGlassCard(),

                      // ─── Footer ───
                      const SizedBox(height: 48),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoArea() {
    return Column(
      children: [
        // Logo icon with gradient
        AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, _floatAnimation.value * 0.3),
            child: child,
          ),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: AppColors.magentaGloss,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Title
        Text(
          'GoChef',
          style: AppTextStyles.displayLgMobile(color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        // Subtitle
        Opacity(
          opacity: 0.8,
          child: Text(
            'Urban Gourmet Marketplace',
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 32,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Welcome Text ───
              Text(
                'Welcome Back',
                style: AppTextStyles.headlineLgMobile(color: AppColors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue your culinary journey.',
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),

              // ─── Social Login Buttons ───
              Row(
                children: [
                  Expanded(child: _buildSocialButton('Google', _buildGoogleIcon())),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSocialButton('Apple', _buildAppleIcon())),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Separator ───
              _buildSeparator(),
              const SizedBox(height: 24),

              // ─── Email Input ───
              _buildEmailLabel(),
              const SizedBox(height: 4),
              _buildEmailInput(),
              const SizedBox(height: 24),

              // ─── Continue Button ───
              _buildContinueButton(),
              const SizedBox(height: 48),

              // ─── Bottom Links ───
              _buildBottomLinks(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, Widget icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 12),
              Text(
                label,
                style: AppTextStyles.labelMono(color: AppColors.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }

  Widget _buildAppleIcon() {
    return const Icon(Icons.apple, color: Colors.white, size: 20);
  }

  Widget _buildSeparator() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Opacity(
            opacity: 0.6,
            child: Text(
              'OR CONTINUE WITH EMAIL',
              style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailLabel() {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        'Email Address',
        style: AppTextStyles.labelMono(color: AppColors.onSurfaceVariant),
      ),
    );
  }

  Widget _buildEmailInput() {
    return AnimatedScale(
      scale: _emailFocusNode.hasFocus ? 1.01 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _emailFocusNode.hasFocus
                ? AppColors.primary
                : AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: _emailFocusNode.hasFocus
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          style: AppTextStyles.bodyMd(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: 'chef@gochef.com',
            hintStyle: AppTextStyles.bodyMd(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            prefixIcon: Icon(
              Icons.mail_outlined,
              size: 20,
              color: _emailFocusNode.hasFocus
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.magentaGloss,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: MaterialButton(
          onPressed: _isLoading ? null : _onContinue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLoading ? 'Loading...' : 'Continue',
                style: AppTextStyles.headlineMd(color: Colors.white),
              ),
              if (!_isLoading) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomLinks() {
    return Column(
      children: [
        // Login with Phone
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPhoneOtpScreen(),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.smartphone,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Login with Phone',
                style: AppTextStyles.labelMono(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Sign Up link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpScreen(),
                  ),
                );
              },
              child: Text(
                'Sign Up',
                style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Opacity(
      opacity: 0.5,
      child: Text(
        'TRUSTED BY 50,000+ URBAN CHEFS',
        style: AppTextStyles.labelSm(color: AppColors.onSecondaryContainer).copyWith(
          letterSpacing: 2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}




/// Custom painter for the Google "G" logo
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Simplified Google G logo with 4 color arcs
    final paint = Paint()..style = PaintingStyle.fill;

    // Blue part
    paint.color = const Color(0xFF4285F4);
    final path1 = Path()
      ..moveTo(w * 0.94, h * 0.51)
      ..cubicTo(w * 0.94, h * 0.44, w * 0.93, h * 0.38, w * 0.92, h * 0.32)
      ..lineTo(w * 0.5, h * 0.32)
      ..lineTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.75, h * 0.5)
      ..cubicTo(w * 0.74, h * 0.56, w * 0.71, h * 0.61, w * 0.66, h * 0.64)
      ..lineTo(w * 0.81, h * 0.75)
      ..cubicTo(w * 0.9, h * 0.67, w * 0.94, h * 0.55, w * 0.94, h * 0.51);
    canvas.drawPath(path1, paint);

    // Green part
    paint.color = const Color(0xFF34A853);
    final path2 = Path()
      ..moveTo(w * 0.5, h * 0.96)
      ..cubicTo(w * 0.62, h * 0.96, w * 0.73, h * 0.92, w * 0.81, h * 0.85)
      ..lineTo(w * 0.66, h * 0.73)
      ..cubicTo(w * 0.62, h * 0.76, w * 0.56, h * 0.77, w * 0.5, h * 0.77)
      ..cubicTo(w * 0.38, h * 0.77, w * 0.28, h * 0.69, w * 0.24, h * 0.58)
      ..lineTo(w * 0.09, h * 0.7)
      ..cubicTo(w * 0.17, h * 0.85, w * 0.32, h * 0.96, w * 0.5, h * 0.96);
    canvas.drawPath(path2, paint);

    // Yellow part
    paint.color = const Color(0xFFFBBC05);
    final path3 = Path()
      ..moveTo(w * 0.24, h * 0.59)
      ..cubicTo(w * 0.23, h * 0.56, w * 0.22, h * 0.53, w * 0.22, h * 0.5)
      ..cubicTo(w * 0.22, h * 0.47, w * 0.23, h * 0.44, w * 0.24, h * 0.41)
      ..lineTo(w * 0.09, h * 0.29)
      ..cubicTo(w * 0.06, h * 0.36, w * 0.04, h * 0.43, w * 0.04, h * 0.5)
      ..cubicTo(w * 0.04, h * 0.57, w * 0.06, h * 0.64, w * 0.09, h * 0.71)
      ..lineTo(w * 0.24, h * 0.59);
    canvas.drawPath(path3, paint);

    // Red part
    paint.color = const Color(0xFFEA4335);
    final path4 = Path()
      ..moveTo(w * 0.5, h * 0.22)
      ..cubicTo(w * 0.57, h * 0.22, w * 0.63, h * 0.25, w * 0.68, h * 0.29)
      ..lineTo(w * 0.81, h * 0.16)
      ..cubicTo(w * 0.73, h * 0.09, w * 0.62, h * 0.04, w * 0.5, h * 0.04)
      ..cubicTo(w * 0.32, h * 0.04, w * 0.17, h * 0.14, w * 0.09, h * 0.29)
      ..lineTo(w * 0.24, h * 0.41)
      ..cubicTo(w * 0.28, h * 0.31, w * 0.38, h * 0.22, w * 0.5, h * 0.22);
    canvas.drawPath(path4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
