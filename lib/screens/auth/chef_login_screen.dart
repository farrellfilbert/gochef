import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../chef_dashboard/chef_main_navigation.dart';
import 'chef_register_screen.dart';
import 'forgot_password_screen.dart';

class ChefLoginScreen extends StatefulWidget {
  const ChefLoginScreen({super.key});

  @override
  State<ChefLoginScreen> createState() => _ChefLoginScreenState();
}

class _ChefLoginScreenState extends State<ChefLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final user = data['user'];
          final isVerified = user['is_verified'] == 1;
          final isChef = user['role'] == 'chef' || (user['kitchen_id'] != null && isVerified);

          if (user['kitchen_id'] != null && !isVerified) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Row(
                  children: [
                    Icon(Icons.hourglass_top_rounded, color: Colors.amber),
                    SizedBox(width: 10),
                    Text('Pending Approval', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                content: const Text(
                  'Your chef application is currently under review by our Admin team. You will be able to access the Chef Dashboard once your kitchen has been verified and approved.',
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('OK', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
            return;
          }

          if (!isChef) {
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('This account is not registered as a chef')),
             );
             return;
          }
          await ApiService.saveUserId(
            user['id'].toString(), 
            role: user['role'], 
            kitchenId: user['kitchen_id']?.toString()
          );
          
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ChefMainNavigation()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? 'Login failed')),
          );
        }
      } else {
        String errMsg = 'Invalid email or password';
        try {
          final errData = jsonDecode(response.body);
          if (errData['error'] != null) {
            errMsg = errData['error'];
          }
        } catch (_) {}

        if (response.statusCode == 403 || errMsg.toLowerCase().contains('suspended')) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.block, color: Colors.redAccent),
                  SizedBox(width: 10),
                  Text('Account Suspended', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Text(
                errMsg,
                style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errMsg), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1556155092-490a1ba16284?q=80&w=2000&auto=format&fit=crop'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black87, BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.glassBackground,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  'Chef Portal',
                                  style: AppTextStyles.headlineLgMobile(color: AppColors.onSurface),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  'Manage your kitchen, track orders, and grow your brand.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'Email or Phone Number',
                                style: AppTextStyles.labelSm(color: Colors.white70),
                              ),
                              const SizedBox(height: 8),
                              _buildTextField(_emailController, 'chef@urbangourmet.com', Icons.person_outline),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Password',
                                    style: AppTextStyles.labelSm(color: Colors.white70),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ForgotPasswordScreen(
                                            initialEmail: _emailController.text.trim(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: AppTextStyles.labelSm(color: Colors.white).copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildTextField(
                                _passwordController, 
                                '••••••••', 
                                Icons.lock_outline, 
                                isPassword: true
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
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
                                    onPressed: _isLoading ? null : _onLogin,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _isLoading ? 'Loading...' : 'Login as Chef',
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
                              ),
                              const SizedBox(height: 32),
                              Center(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    'Back to Customer Login',
                                    style: AppTextStyles.bodyMd(color: Colors.white).copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ChefRegisterScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Don't have a chef account? Register as a Chef",
                                      style: AppTextStyles.bodyMd(color: Colors.white).copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        style: AppTextStyles.bodyMd(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMd(color: Colors.white38),
          prefixIcon: Icon(icon, size: 20, color: Colors.white),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: Colors.white70),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }
}
