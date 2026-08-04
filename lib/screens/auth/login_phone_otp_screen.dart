import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Login Phone OTP Screen — replicates Login Phone Otp.html exactly
class LoginPhoneOtpScreen extends StatefulWidget {
  const LoginPhoneOtpScreen({super.key});

  @override
  State<LoginPhoneOtpScreen> createState() => _LoginPhoneOtpScreenState();
}

class _LoginPhoneOtpScreenState extends State<LoginPhoneOtpScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  int _timerSeconds = 45;
  Timer? _timer;
  bool _isVerified = false;
  bool _isVerifying = false;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Auto-focus first OTP input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glowController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _timerText {
    final mins = _timerSeconds ~/ 60;
    final secs = _timerSeconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  void _addDigit(int digit) {
    for (int i = 0; i < 4; i++) {
      if (_otpControllers[i].text.isEmpty) {
        _otpControllers[i].text = digit.toString();
        if (i < 3) {
          _otpFocusNodes[i + 1].requestFocus();
        }
        setState(() {});
        return;
      }
    }
  }

  void _removeDigit() {
    for (int i = 3; i >= 0; i--) {
      if (_otpControllers[i].text.isNotEmpty) {
        _otpControllers[i].text = '';
        _otpFocusNodes[i].requestFocus();
        setState(() {});
        return;
      }
    }
  }

  void _onVerify() async {
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _isVerifying = false;
      _isVerified = true;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          // ─── Atmospheric Background Glows ───
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) => Stack(
                children: [
                  Positioned(
                    top: -96,
                    left: -96,
                    child: Opacity(
                      opacity: _glowAnimation.value,
                      child: Container(
                        width: 256,
                        height: 256,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.5,
                    right: -128,
                    child: Opacity(
                      opacity: _glowAnimation.value,
                      child: Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.tertiary.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: const SizedBox(),
            ),
          ),

          // ─── Main Content ───
          SafeArea(
            child: Column(
              children: [
                // ─── Header ───
                _buildHeader(),

                // ─── Content ───
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 48),

                        // ─── Typography ───
                        Text(
                          'Verify Phone',
                          style: AppTextStyles.headlineLgMobile(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodyMd(
                              color: AppColors.onSurfaceVariant,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Enter the 4-digit code sent to ',
                              ),
                              TextSpan(
                                text: '+1 (555) 000-0000',
                                style: AppTextStyles.bodyMd(
                                  color: AppColors.onSurface,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),

                        // ─── OTP Inputs ───
                        _buildOtpInputs(),
                        const SizedBox(height: 48),

                        // ─── Resend Timer ───
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.labelSm(
                                color: AppColors.onSurfaceVariant,
                              ),
                              children: [
                                const TextSpan(text: 'Resend code in '),
                                TextSpan(
                                  text: _timerText,
                                  style: AppTextStyles.labelSm(
                                    color: AppColors.primary,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ─── Verify Button ───
                        _buildVerifyButton(),

                        // ─── Keypad ───
                        const Spacer(),
                        _buildKeypad(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button (glass panel)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Title
            Text(
              'GoChef',
              style: AppTextStyles.headlineMd(color: AppColors.primary)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            // Spacer
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        final hasFocus = _otpFocusNodes[index].hasFocus;
        final hasValue = _otpControllers[index].text.isNotEmpty;

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasFocus || hasValue
                      ? AppColors.primaryContainer
                      : AppColors.outlineVariant.withValues(alpha: 0.3),
                  width: hasFocus ? 2 : 1,
                ),
                boxShadow: hasFocus
                    ? [
                        BoxShadow(
                          color: AppColors.primaryContainer.withValues(alpha: 0.3),
                          blurRadius: 15,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: TextField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.headlineLg(color: AppColors.onSurface)
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 28),
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    if (value.length == 1 && index < 3) {
                      _otpFocusNodes[index + 1].requestFocus();
                    }
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _isVerified
              ? const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                )
              : AppColors.ctaGradient,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: _isVerified
                  ? const Color(0xFF10B981).withValues(alpha: 0.4)
                  : AppColors.primaryContainer.withValues(alpha: 0.4),
              blurRadius: 20,
            ),
          ],
        ),
        child: MaterialButton(
          onPressed: _isVerifying || _isVerified ? null : _onVerify,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          child: _isVerifying
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : _isVerified
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Verified',
                          style: AppTextStyles.headlineMd(color: Colors.white)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : Text(
                      'Verify & Continue',
                      style: AppTextStyles.headlineMd(
                        color: AppColors.onPrimaryContainer,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'backspace'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key.isEmpty) {
                return const SizedBox(width: 80, height: 56);
              }
              if (key == 'backspace') {
                return _buildKeypadButton(
                  onTap: _removeDigit,
                  child: const Icon(
                    Icons.backspace_outlined,
                    color: AppColors.onSurface,
                    size: 28,
                  ),
                );
              }
              return _buildKeypadButton(
                onTap: () => _addDigit(int.parse(key)),
                child: Text(
                  key,
                  style: AppTextStyles.headlineLgMobile(
                    color: AppColors.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeypadButton({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 80,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}
