import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const GoChefApp());
}

// --- CONSTANTS & COLORS ---
// Using AppColors from theme/app_colors.dart for new screens.
// Legacy constants below are kept for existing screens (Home, Chef, etc.)
const Color bgColor = Color(0xFF0F131C);
const Color cardBg = Color(0xFF1C2029);
const Color primaryColor = Color(0xFFFF4A90);
const Color textMain = Color(0xFFDFE2EF);
const Color textDim = Color(0xFFE2BDC5);
const Color inputBg = Color(0xFF181B25);

class GoChefApp extends StatelessWidget {
  const GoChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoChef Premium',
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}

// LoginScreen is now in screens/auth/login_screen.dart

// ==========================================
// 2. MAIN NAVIGATION (BOTTOM TABS)
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
    const Center(child: Text("Halaman Pesanan")), // Placeholder
    const Center(child: Text("Halaman Tersimpan")), // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF121212),
          selectedItemColor: primaryColor,
          unselectedItemColor: textDim,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'EKSPLOR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'PESANAN',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline),
              activeIcon: Icon(Icons.bookmark),
              label: 'TERSIMPAN',
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. HOME SCREEN
// ==========================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor, width: 2),
                          color: cardBg,
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://ui-avatars.com/api/?name=Farrell&background=E91E63&color=fff',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Selamat datang,',
                            style: TextStyle(fontSize: 11, color: textDim),
                          ),
                          Text(
                            'Farrell',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.location_on, size: 14, color: primaryColor),
                        SizedBox(width: 4),
                        Text(
                          'Depok, ID',
                          style: TextStyle(fontSize: 12, color: textDim),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 14,
                          color: textDim,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar (Opens Map)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MapSearchScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.search, color: Colors.grey, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Mau makan apa hari ini?',
                        style: TextStyle(color: textDim, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Promo Banner Carousel (3 Gambar Geser)
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics:
                    const BouncingScrollPhysics(), // Efek memantul saat digeser
                children: const [
                  _PromoCard(
                    image:
                        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600',
                    title: 'Diskon 50% Fine Dining',
                    subtitle: 'Khusus pengguna baru GoChef',
                    color: primaryColor,
                  ),
                  SizedBox(width: 15),
                  _PromoCard(
                    image:
                        'https://images.unsplash.com/photo-1544025162-811114b3a4a1?w=600',
                    title: 'Chef of the Week',
                    subtitle: 'Cicipi menu spesial Chef Renata',
                    color: Colors.amber,
                  ),
                  SizedBox(width: 15),
                  _PromoCard(
                    image:
                        'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=600',
                    title: 'Malam Minggu Romantis',
                    subtitle: 'Pesan Chef ke rumah sekarang',
                    color: Colors.purpleAccent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Food Categories
            _buildSectionTitle('Jenis Makanan'),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _CategoryItem(
                    icon: '🥪',
                    title: 'Sandwich',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategoryChefListScreen(
                          category: 'Sandwich',
                          icon: '🥪',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  _CategoryItem(
                    icon: '🍣',
                    title: 'Sushi',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategoryChefListScreen(
                          category: 'Sushi',
                          icon: '🍣',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  _CategoryItem(
                    icon: '🍔',
                    title: 'Burger',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategoryChefListScreen(
                          category: 'Burger',
                          icon: '🍔',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  _CategoryItem(
                    icon: '☕',
                    title: 'Kopi',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategoryChefListScreen(
                          category: 'Kopi',
                          icon: '☕',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  _CategoryItem(
                    icon: '🍦',
                    title: 'Dessert',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategoryChefListScreen(
                          category: 'Dessert',
                          icon: '🍦',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Popular Chefs
            _buildSectionTitle('Koki di Sekitarmu', actionText: 'Lihat Semua'),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _ChefCircleItem(
                    img:
                        'https://images.unsplash.com/photo-1577219491135-ce391730fbaf?w=200',
                    name: 'Chef Mike',
                    rating: '4.8',
                    specialty: 'Spesialis Sandwich & Grill',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChefProfileScreen(
                          name: 'Chef Mike',
                          img:
                              'https://images.unsplash.com/photo-1577219491135-ce391730fbaf?w=200',
                          rating: '4.8',
                          specialty: 'Spesialis Sandwich & Grill',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  _ChefCircleItem(
                    img:
                        'https://images.unsplash.com/photo-1583394293214-28ded15ee548?w=200',
                    name: 'Chef Santi',
                    rating: '4.9',
                    specialty: 'Burger & Western Food',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChefProfileScreen(
                          name: 'Chef Santi',
                          img:
                              'https://images.unsplash.com/photo-1583394293214-28ded15ee548?w=200',
                          rating: '4.9',
                          specialty: 'Burger & Western Food',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  _ChefCircleItem(
                    img:
                        'https://images.unsplash.com/photo-1581299894007-aaa50297cf16?w=200',
                    name: 'Chef Juna',
                    rating: '4.7',
                    specialty: 'Asian Cuisine & Ramen',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChefProfileScreen(
                          name: 'Chef Juna',
                          img:
                              'https://images.unsplash.com/photo-1581299894007-aaa50297cf16?w=200',
                          rating: '4.7',
                          specialty: 'Asian Cuisine & Ramen',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Popular Today
            _buildSectionTitle('Populer Hari Ini'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: const [
                  _FoodCardMini(
                    img:
                        'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=200',
                    title: 'Grilled Cheese Sandwich',
                    subtitle: 'Oleh Chef Mike • 1.2 km',
                    price: 'Rp 35.000',
                    badgeText: 'Diskon 20%',
                  ),
                  _FoodCardMini(
                    img:
                        'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=200',
                    title: 'Sushi Platter Combo',
                    subtitle: 'Oleh Chef Akira • 2.5 km',
                    price: 'Rp 65.000',
                    badgeText: 'Terlaris',
                  ),
                  _FoodCardMini(
                    img:
                        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200',
                    title: 'Classic Smash Burger',
                    subtitle: 'Oleh Chef Santi • 3.0 km',
                    price: 'Rp 45.000',
                  ),
                  _FoodCardMini(
                    img:
                        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200',
                    title: 'Spicy Ramen Bowl',
                    subtitle: 'Oleh Chef Juna • 4.1 km',
                    price: 'Rp 55.000',
                    badgeText: 'Baru',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? actionText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          if (actionText != null)
            Text(
              actionText,
              style: const TextStyle(
                fontSize: 12,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

// --- Custom Widgets for Home ---

class _CategoryItem extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback? onTap;

  const _CategoryItem({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 28)),
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ChefCircleItem extends StatelessWidget {
  final String img;
  final String name;
  final String rating;
  final String specialty;
  final VoidCallback? onTap;

  const _ChefCircleItem({
    required this.img,
    required this.name,
    required this.rating,
    required this.specialty,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 75,
            height: 75,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardBg,
              image: DecorationImage(
                image: NetworkImage(img),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            '⭐ $rating',
            style: const TextStyle(fontSize: 11, color: textDim),
          ),
        ],
      ),
    );
  }
}

class _FoodCardMini extends StatelessWidget {
  final String img;
  final String title;
  final String subtitle;
  final String price;
  final bool highlightDistance;
  final String? badgeText; // Tambahan parameter badge

  const _FoodCardMini({
    required this.img,
    required this.title,
    required this.subtitle,
    required this.price,
    this.highlightDistance = false,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  img,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              if (badgeText != null)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      badgeText!,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // Custom render for map view highlights
                highlightDistance
                    ? RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: textDim,
                            fontFamily: 'Inter',
                          ),
                          children: [
                            TextSpan(text: '${subtitle.split('•')[0]}• '),
                            TextSpan(
                              text: subtitle.split('•')[1],
                              style: const TextStyle(color: primaryColor),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12, color: textDim),
                      ),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: highlightDistance ? Colors.amber : primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. MAP SEARCH SCREEN
// ==========================================
class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto focus search field saat masuk halaman ini
    Future.delayed(
      const Duration(milliseconds: 300),
      () => _searchFocus.requestFocus(),
    );
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Fake Map Background
          Positioned.fill(
            child: Image.network(
              'https://api.mapbox.com/styles/v1/mapbox/dark-v10/static/106.8272,-6.3533,14,0/600x1200?access_token=YOUR_TOKEN_HERE',
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.4),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // 2. Header Gradient & Search Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: cardBg,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        focusNode: _searchFocus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 18,
                          ),
                          hintText: 'Cari Sandwich, Sushi, dll...',
                          hintStyle: TextStyle(color: textDim),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Center Pin
          Align(
            alignment: const Alignment(0, -0.1), // Slightly above center
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Koki terdekat',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 5),
                const Icon(Icons.location_on, size: 40, color: primaryColor),
              ],
            ),
          ),

          // 4. Bottom Sheet Results
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: const BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Hasil Pencarian (Peta)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  const _FoodCardMini(
                    img:
                        'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=200',
                    title: "Mike's Kitchen",
                    subtitle: 'Spesialis Sandwich • Berjarak 1.2 km',
                    price: '⭐ 4.8 (Tersedia Makan di Tempat)',
                    highlightDistance: true,
                  ),
                  const _FoodCardMini(
                    img:
                        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200',
                    title: 'Burger Bros Depok',
                    subtitle: 'Burger & Western • Berjarak 2.0 km',
                    price: '⭐ 4.6 (Hanya Pesan Antar)',
                    highlightDistance: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. CHEF PROFILE SCREEN
// ==========================================
class ChefProfileScreen extends StatelessWidget {
  final String name;
  final String img;
  final String rating;
  final String specialty;

  const ChefProfileScreen({
    super.key,
    required this.name,
    required this.img,
    required this.rating,
    required this.specialty,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cardBg,
        title: const Text(
          'Profil Koki',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chef Header Info
            Container(
              padding: const EdgeInsets.all(20),
              color: cardBg,
              child: Row(
                children: [
                  CircleAvatar(radius: 40, backgroundImage: NetworkImage(img)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          specialty,
                          style: const TextStyle(fontSize: 14, color: textDim),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$rating (120+ Ulasan)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Menu List
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Text(
                'Menu Andalan Koki',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Mock Menu Data
                  _FoodCardMini(
                    img:
                        img, // Menggunakan foto profil koki sebagai placeholder makanan
                    title: 'Specialty $specialty Dish 1',
                    subtitle: 'Resep rahasia keluarga • Porsi 1 orang',
                    price: 'Rp 45.000',
                  ),
                  _FoodCardMini(
                    img:
                        'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=200',
                    title: 'Signature Dish 2',
                    subtitle: 'Bahan premium pilihan • Porsi 2 orang',
                    price: 'Rp 85.000',
                  ),
                  _FoodCardMini(
                    img:
                        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200',
                    title: 'Favorite Combo',
                    subtitle: 'Lengkap dengan minuman • Porsi 1 orang',
                    price: 'Rp 60.000',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 6. CATEGORY CHEF LIST SCREEN
// ==========================================
class CategoryChefListScreen extends StatelessWidget {
  final String category;
  final String icon;

  const CategoryChefListScreen({
    super.key,
    required this.category,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cardBg,
        title: Text(
          '$icon Koki Spesialis $category',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Menampilkan koki terbaik di sekitarmu',
            style: TextStyle(color: textDim, fontSize: 14),
          ),
          const SizedBox(height: 15),

          // List of Chefs
          _ChefListCard(
            img:
                'https://images.unsplash.com/photo-1583394293214-28ded15ee548?w=200',
            name: 'Chef Mike',
            rating: '4.8',
            distance: '1.2 km',
            specialty: 'Spesialis $category',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChefProfileScreen(
                  name: 'Chef Mike',
                  img:
                      'https://images.unsplash.com/photo-1583394293214-28ded15ee548?w=200',
                  rating: '4.8',
                  specialty: 'Spesialis $category',
                ),
              ),
            ),
          ),
          _ChefListCard(
            img:
                'https://images.unsplash.com/photo-1583394293214-28ded15ee548?w=200',
            name: 'Chef Santi',
            rating: '4.9',
            distance: '2.5 km',
            specialty: 'Master $category Lokal',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChefProfileScreen(
                  name: 'Chef Santi',
                  img:
                      'https://images.unsplash.com/photo-1583394293214-28ded15ee548?w=200',
                  rating: '4.9',
                  specialty: 'Master $category Lokal',
                ),
              ),
            ),
          ),
          _ChefListCard(
            img:
                'https://images.unsplash.com/photo-1581299894007-aaa50297cf16?w=200',
            name: 'Chef Juna',
            rating: '4.7',
            distance: '4.1 km',
            specialty: '$category Fusion',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChefProfileScreen(
                  name: 'Chef Juna',
                  img:
                      'https://images.unsplash.com/photo-1581299894007-aaa50297cf16?w=200',
                  rating: '4.7',
                  specialty: '$category Fusion',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Widget for Category List
class _ChefListCard extends StatelessWidget {
  final String img;
  final String name;
  final String rating;
  final String distance;
  final String specialty;
  final VoidCallback? onTap;

  const _ChefListCard({
    required this.img,
    required this.name,
    required this.rating,
    required this.distance,
    required this.specialty,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 30, backgroundImage: NetworkImage(img)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialty,
                    style: const TextStyle(fontSize: 13, color: primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Icon(Icons.location_on, color: textDim, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        distance,
                        style: const TextStyle(fontSize: 12, color: textDim),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: textDim),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 7. WIDGET PROMO BANNER (BARU)
// ==========================================
class _PromoCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final Color color;

  const _PromoCard({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'PROMO',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
