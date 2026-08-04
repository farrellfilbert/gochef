import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final userId = await ApiService.getUserId().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      if (!mounted) return;
      setState(() {
        _isLoggedIn = userId != null && userId.isNotEmpty;
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
    return _isLoggedIn ? const MainNavigation() : const LoginScreen();
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
            backgroundColor: AppColors.surface.withValues(alpha: 0.8),
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.onSurfaceVariant,
            selectedLabelStyle: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline),
                activeIcon: Icon(Icons.favorite),
                label: 'Favorites',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
