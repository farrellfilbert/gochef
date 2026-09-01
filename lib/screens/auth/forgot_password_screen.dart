import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;
  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Step 0: Enter Email, Step 1: Enter OTP, Step 2: Enter New Password, Step 3: Success
  int _currentStep = 0;

  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();

  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocus = FocusNode();

  final TextEditingController _newPasswordController = TextEditingController();
  final FocusNode _newPasswordFocus = FocusNode();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Resend OTP countdown
  Timer? _resendTimer;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
    }
    _emailFocus.addListener(() => setState(() {}));
    _otpFocus.addListener(() => setState(() {}));
    _newPasswordFocus.addListener(() => setState(() {}));
    _confirmPasswordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _emailFocus.dispose();
    _otpController.dispose();
    _otpFocus.dispose();
    _newPasswordController.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordController.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendCountdown = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  // ─────────────────────────────────────────────────────────────
  // 1. SEND OTP ACTION
  // ─────────────────────────────────────────────────────────────
  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await http.post(
        Uri.parse('${ApiService.baseUrl}/forgot_password.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'send_otp',
          'email': email,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        _startResendCountdown();
        if (data['otp_code'] != null) {
          _otpController.text = data['otp_code'].toString();
        }
        setState(() {
          _currentStep = 1;
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.mark_email_read, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'OTP sent to $email.\n(Check Inbox or Spam folder)',
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = data['error'] ?? 'Failed to send OTP code';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 2. VERIFY OTP ACTION
  // ─────────────────────────────────────────────────────────────
  Future<void> _handleVerifyOtp() async {
    final email = _emailController.text.trim().toLowerCase();
    final otp = _otpController.text.trim();

    if (otp.isEmpty || otp.length < 6) {
      setState(() => _errorMessage = 'Please enter the 6-digit OTP code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await http.post(
        Uri.parse('${ApiService.baseUrl}/forgot_password.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'verify_otp',
          'email': email,
          'otp': otp,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        setState(() {
          _currentStep = 2;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = data['error'] ?? 'Invalid or expired verification code';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 3. RESET PASSWORD ACTION
  // ─────────────────────────────────────────────────────────────
  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim().toLowerCase();
    final otp = _otpController.text.trim();
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }

    if (newPass != confirmPass) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await http.post(
        Uri.parse('${ApiService.baseUrl}/forgot_password.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'reset_password',
          'email': email,
          'otp': otp,
          'new_password': newPass,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        setState(() {
          _currentStep = 3; // Success state
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = data['error'] ?? 'Failed to reset password';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_currentStep > 0 && _currentStep < 3) {
              setState(() {
                _currentStep--;
                _errorMessage = null;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Header
                  Center(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: 'GO'),
                          TextSpan(text: 'CHEF', style: TextStyle(color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PASSWORD RECOVERY',
                    style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(letterSpacing: 2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Progress Step Indicator
                  if (_currentStep < 3) _buildStepProgress(),
                  const SizedBox(height: 24),

                  // Card Content
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _buildCurrentStepContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP PROGRESS WIDGET
  // ─────────────────────────────────────────────────────────────
  Widget _buildStepProgress() {
    final steps = ['Email', 'Verify', 'Reset'];
    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIdx = index ~/ 2;
          final isPassed = _currentStep > stepIdx;
          return Expanded(
            child: Container(
              height: 2,
              color: isPassed ? AppColors.primary : Colors.white12,
            ),
          );
        }

        final stepIdx = index ~/ 2;
        final isActive = _currentStep == stepIdx;
        final isPassed = _currentStep > stepIdx;

        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPassed
                    ? AppColors.primary
                    : (isActive ? AppColors.primary.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05)),
                border: Border.all(
                  color: isPassed || isActive ? AppColors.primary : Colors.white24,
                  width: isActive ? 2 : 1,
                ),
              ),
              child: isPassed
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${stepIdx + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : Colors.white60,
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              steps[stepIdx],
              style: TextStyle(
                fontSize: 10,
                color: isActive ? Colors.white : Colors.white54,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStepEmail();
      case 1:
        return _buildStepOtp();
      case 2:
        return _buildStepResetPassword();
      case 3:
        return _buildStepSuccess();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 0: EMAIL INPUT
  // ─────────────────────────────────────────────────────────────
  Widget _buildStepEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forgot Password?',
          style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your registered email address. We will send you a 6-digit OTP code to reset your password.',
          style: AppTextStyles.bodyMd(color: Colors.white70).copyWith(height: 1.4),
        ),
        const SizedBox(height: 24),

        if (_errorMessage != null) _buildErrorBanner(_errorMessage!),

        Text('Email Address', style: AppTextStyles.labelMono(color: Colors.white70)),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _emailController,
          focusNode: _emailFocus,
          hintText: 'e.g. chef@gochef.com',
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 28),

        _buildActionButton(
          text: 'Send Verification Code',
          onPressed: _isLoading ? null : _handleSendOtp,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 1: OTP INPUT
  // ─────────────────────────────────────────────────────────────
  Widget _buildStepOtp() {
    final email = _emailController.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Verification Code',
          style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.4),
            children: [
              const TextSpan(text: 'We sent a 6-digit verification code to\n'),
              TextSpan(text: email, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        if (_errorMessage != null) _buildErrorBanner(_errorMessage!),

        Text('6-Digit OTP Code', style: AppTextStyles.labelMono(color: Colors.white70)),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _otpController,
          focusNode: _otpFocus,
          hintText: '123456',
          prefixIcon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white60, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tip: Check your Spam or Junk folder if the email does not appear in your Inbox.',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Resend timer
        Center(
          child: _resendCountdown > 0
              ? Text(
                  'Resend code in ${_resendCountdown}s',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                )
              : TextButton(
                  onPressed: _isLoading ? null : _handleSendOtp,
                  child: const Text(
                    'Didn\'t receive code? Resend OTP',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
        ),
        const SizedBox(height: 16),

        _buildActionButton(
          text: 'Verify Code',
          onPressed: _isLoading ? null : _handleVerifyOtp,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 2: RESET PASSWORD
  // ─────────────────────────────────────────────────────────────
  Widget _buildStepResetPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create New Password',
          style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Your new password must be at least 6 characters.',
          style: AppTextStyles.bodyMd(color: Colors.white70),
        ),
        const SizedBox(height: 24),

        if (_errorMessage != null) _buildErrorBanner(_errorMessage!),

        Text('New Password', style: AppTextStyles.labelMono(color: Colors.white70)),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _newPasswordController,
          focusNode: _newPasswordFocus,
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscureNewPass,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureNewPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.white60,
              size: 20,
            ),
            onPressed: () => setState(() => _obscureNewPass = !_obscureNewPass),
          ),
        ),
        const SizedBox(height: 16),

        Text('Confirm New Password', style: AppTextStyles.labelMono(color: Colors.white70)),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocus,
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscureConfirmPass,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.white60,
              size: 20,
            ),
            onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
          ),
        ),
        const SizedBox(height: 28),

        _buildActionButton(
          text: 'Reset Password',
          onPressed: _isLoading ? null : _handleResetPassword,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 3: SUCCESS STATE
  // ─────────────────────────────────────────────────────────────
  Widget _buildStepSuccess() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF10B981), width: 2),
          ),
          child: const Icon(Icons.check, color: Color(0xFF10B981), size: 36),
        ),
        const SizedBox(height: 20),
        Text(
          'Password Changed!',
          style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Your password has been successfully reset. You can now login with your new password.',
          style: AppTextStyles.bodyMd(color: Colors.white70).copyWith(height: 1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildActionButton(
          text: 'Back to Login',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // REUSABLE COMPONENTS
  // ─────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focusNode.hasFocus ? AppColors.primary : Colors.white12,
        ),
        boxShadow: focusNode.hasFocus
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          counterText: '',
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          prefixIcon: Icon(
            prefixIcon,
            size: 20,
            color: focusNode.hasFocus ? AppColors.primary : Colors.white60,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String text, required VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
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
          onPressed: onPressed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
        ),
      ),
    );
  }
}
