import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'login_screen.dart';

/// Sign Up Screen — replicates Sign Up.html exactly
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(() => setState(() {}));
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://astroboomin.co/api/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! Please login.')),
          );
          Navigator.pop(context);
        } else {
          _showError(data['error'] ?? 'Registration failed');
        }
      } else if (response.statusCode == 409) {
        _showError('Email is already registered');
      } else {
        _showError('Server error during registration');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Connection error. Please try again.');
    }
  }

  Future<void> _onGoogleSignUp() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '1055253793767-as9i19kkmka2ootv8rublt7qvo31ovrb.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      
      if (account != null) {
        final response = await http.post(
          Uri.parse('https://astroboomin.co/api/login_google.php'), // Using same API as it handles upsert
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': account.email,
            'name': account.displayName ?? 'Google User',
            'google_id': account.id,
          }),
        );
        
        if (!mounted) return;
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()), // Redirect to login or home
            );
          } else {
            _showError(data['message'] ?? 'Failed to sign up via Google');
          }
        } else {
          _showError('Server error during Google Sign Up');
        }
      }
    } catch (e) {
      _showError('Google sign in failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // ─── Atmospheric Background Glows ───
          Positioned(
            bottom: -128,
            left: -128,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            top: -128,
            right: -128,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: const SizedBox(),
            ),
          ),

          // ─── Main Content ───
          Column(
            children: [
              // ─── Fixed Header ───
              _buildHeader(),

              // ─── Scrollable Content ───
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 512),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // ─── Hero Section ───
                        Text(
                          'Create Account',
                          style: AppTextStyles.headlineLgMobile(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Opacity(
                          opacity: 0.8,
                          child: Text(
                            'Join the community of neighborhood chefs and foodies.',
                            style: AppTextStyles.bodyMd(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // ─── Social Sign Up ───
                        _buildSocialSignUpButton(
                          'Continue with Google',
                          _buildGoogleIcon(),
                          onTap: _isLoading ? null : _onGoogleSignUp,
                        ),
                        const SizedBox(height: 12),
                        _buildSocialSignUpButton(
                          'Continue with Apple',
                          const Icon(Icons.apple, color: AppColors.onSurface, size: 20),
                          onTap: () {
                            _showError('Apple Sign-In coming soon!');
                          },
                        ),
                        const SizedBox(height: 48),

                        // ─── Separator ───
                        _buildSeparator(),
                        const SizedBox(height: 48),

                        // ─── Form Fields ───
                        _buildFormField(
                          label: 'Full Name',
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          placeholder: 'E.g. Elena Rossi',
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 12),
                        _buildFormField(
                          label: 'Email Address',
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          placeholder: 'chef@example.com',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _buildPasswordField(),
                        const SizedBox(height: 24),

                        // ─── Sign Up Button ───
                        _buildSignUpButton(),
                        const SizedBox(height: 48),

                        // ─── Footer Links ───
                        _buildFooterLinks(),
                        const SizedBox(height: 64),

                        // ─── Privacy Policy ───
                        _buildPrivacyPolicy(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    // Title
                    Image.asset(
                      'assets/images/GoCheflogo.png',
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                    // Spacer
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialSignUpButton(String label, Widget icon, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.ghostBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(
                    label.toUpperCase(),
                    style: AppTextStyles.labelSm(color: AppColors.onSurface).copyWith(
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
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
          child: Text(
            'OR',
            style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(
              letterSpacing: 2,
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

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isFocused = focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isFocused
                  ? AppColors.primaryContainer.withValues(alpha: 0.4)
                  : AppColors.ghostBorder,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.15),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            style: AppTextStyles.bodyMd(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTextStyles.bodyMd(
                color: AppColors.outlineVariant.withValues(alpha: 0.6),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    final isFocused = _passwordFocusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Password',
            style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isFocused
                  ? AppColors.primaryContainer.withValues(alpha: 0.4)
                  : AppColors.ghostBorder,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.15),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: _obscurePassword,
                  style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'At least 8 characters',
                    hintStyle: AppTextStyles.bodyMd(
                      color: AppColors.outlineVariant.withValues(alpha: 0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: isFocused
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.signUpGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: MaterialButton(
          onPressed: _isLoading ? null : _onSignUp,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _isLoading ? 'Creating Account...' : 'Sign Up',
            style: AppTextStyles.headlineMd(color: Colors.white)
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Log In',
              style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicy() {
    return Center(
      child: Opacity(
        opacity: 0.6,
        child: Column(
          children: [
            Text(
              'By signing up, you agree to our',
              style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Terms of Service',
                  style: AppTextStyles.labelSm(
                    color: AppColors.onSurfaceVariant,
                  ).copyWith(decoration: TextDecoration.underline),
                ),
                Text(
                  ' and ',
                  style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                ),
                Text(
                  'Privacy Policy',
                  style: AppTextStyles.labelSm(
                    color: AppColors.onSurfaceVariant,
                  ).copyWith(decoration: TextDecoration.underline),
                ),
                Text(
                  '.',
                  style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the Google logo (with official colors)
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    // Blue
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

    // Green
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

    // Yellow
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

    // Red
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
