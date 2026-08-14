import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'screens/orders/order_history_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/profile/user_profile_screen.dart';
import 'services/api_service.dart';
import 'screens/chef_dashboard/chef_main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Disable runtime font fetching on web — prevents hang if Google Fonts CDN is slow
  if (kIsWeb) {
    GoogleFonts.config.allowRuntimeFetching = false;
  }
  
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }
  runApp(const GoChefApp());
}

class GoChefApp extends StatelessWidget {
  const GoChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoChef Premium',
      theme: AppTheme.darkTheme,
      home: const AuthCheckScreen(),
    );
  }
}

// ==========================================
// AUTH CHECK SCREEN
// ==========================================

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String _userRole = 'user';

  @override
  void initState() {
    super.initState();
    _checkAuth();
    // Absolute fallback: if still loading after 5 seconds, force to login
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _isLoggedIn = false;
        });
      }
    });
  }

  Future<void> _checkAuth() async {
    try {
      final userId = await ApiService.getUserId().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      
      String role = 'user';
      if (userId != null && userId.isNotEmpty) {
        try {
          final profile = await ApiService.getProfile().timeout(const Duration(seconds: 3));
          final localRole = await ApiService.getUserRole();
          
          if (localRole != null && localRole.isNotEmpty) {
            role = localRole;
          } else {
            role = (profile.role == 'chef') ? 'chef' : 'user';
          }
          await ApiService.saveUserId(profile.id, role: role, kitchenId: profile.kitchenId);
        } catch (_) {
          final localRole = await ApiService.getUserRole();
          role = localRole ?? 'user';
        }
      }
      
      if (!mounted) return;
      setState(() {
        _isLoggedIn = userId != null && userId.isNotEmpty;
        _userRole = role;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.midnight,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (_isLoggedIn) {
      if (_userRole == 'chef') {
        return const ChefMainNavigation();
      }
      return const MainNavigation();
    }
    return const LoginScreen();
  }
}

// ==========================================
// MAIN NAVIGATION (BOTTOM TABS)
// ==========================================

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const OrderHistoryScreen(),
    const FavoritesScreen(),
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.8),
          border: Border(
            top: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: AppColors.surface.withValues(alpha: 0.95),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            selectedLabelStyle: AppTextStyles.labelSm(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTextStyles.labelSm(color: Colors.white70),
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/home_nav.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  color: Colors.white70,
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.4),
                        blurRadius: 8,
                      )
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/home_nav.png',
                    width: 26,
                    height: 26,
                    fit: BoxFit.contain,
                    color: Colors.white,
                  ),
                ),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.local_offer_outlined, color: Colors.white70),
                activeIcon: Icon(Icons.local_offer, color: Colors.white),
                label: 'Promo',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined, color: Colors.white70),
                activeIcon: Icon(Icons.receipt_long, color: Colors.white),
                label: 'Orders',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline, color: Colors.white70),
                activeIcon: Icon(Icons.favorite, color: Colors.white),
                label: 'Favorites',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, color: Colors.white70),
                activeIcon: Icon(Icons.person, color: Colors.white),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
