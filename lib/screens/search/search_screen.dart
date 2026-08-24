import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/notification_bell.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';
import '../../models/kitchen_model.dart';
import '../../models/promotion_model.dart';
import '../kitchen/kitchen_profile_screen.dart';
import 'search_results_screen.dart';
import '../legal/terms_of_service_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  UserModel? _user;
  bool _isLoading = true;
  int _userCoins = 1250;
  int _voucherCount = 25;
  bool _isChefPlus = true;
  
  // Daily check-in state
  final List<int> _dailyCoins = [2000, 30, 50, 1000, 100, 3000, 150];
  int _currentDayIndex = 3; // Day 4 (0-indexed: 3)
  bool _isTodayClaimed = false;
  
  // Real data lists
  List<PromotionModel> _promotions = [];
  List<KitchenModel> _featuredKitchens = [];

  // Claimed Exclusive Offers Tracking
  Set<String> _claimedOfferIds = {};

  // Exclusive Offers List
  final List<Map<String, dynamic>> _exclusiveOffers = [
    {
      'id': 'offer_50_first',
      'title': '50% Off Your First Order',
      'subtitle': 'Exclusive to University District students',
      'code': 'FIRST50',
      'discount': '50% OFF',
      'discountType': 'percent',
      'discountValue': 50.0,
      'minSpend': 0.0,
    },
    {
      'id': 'offer_free_deliv',
      'title': 'Free Delivery This Week',
      'subtitle': 'On all orders above \$20',
      'code': 'FREEDELIV',
      'discount': 'FREE DELIVERY',
      'discountType': 'free_delivery',
      'discountValue': 4.0,
      'minSpend': 20.0,
    },
    {
      'id': 'offer_buy2get1',
      'title': 'Buy 2 Get 1 Free',
      'subtitle': "On selected ramen bowls at Yosuke's",
      'code': 'B2G1RAMEN',
      'discount': 'BUY 2 GET 1',
      'discountType': 'fixed',
      'discountValue': 12.0,
      'minSpend': 15.0,
    },
  ];

  // Active user vouchers
  List<Map<String, dynamic>> _userVouchers = [
    {
      'code': 'GOCHEF40',
      'discount': '40% OFF',
      'title': 'Gourmet Feast Special',
      'minSpend': 30,
      'expiresIn': '5 Days',
      'category': 'All Kitchens',
      'discountType': 'percent',
      'discountValue': 40.0,
    },
    {
      'code': 'FREEDELIV',
      'discount': 'FREE DELIVERY',
      'title': 'Zero Delivery Fee',
      'minSpend': 0,
      'expiresIn': '3 Days',
      'category': 'Orders > \$15',
      'discountType': 'free_delivery',
      'discountValue': 4.0,
    },
    {
      'code': 'BUY1GET1',
      'discount': 'BUY 1 GET 1',
      'title': 'Burger & Ramen Treat',
      'minSpend': 20,
      'expiresIn': '7 Days',
      'category': 'Selected Dishes',
      'discountType': 'fixed',
      'discountValue': 10.0,
    },
    {
      'code': 'PLUSVIP15',
      'discount': '15% OFF',
      'title': 'GoChef PLUS Member Perk',
      'minSpend': 10,
      'expiresIn': '14 Days',
      'category': 'VIP Exclusive',
      'discountType': 'percent',
      'discountValue': 15.0,
    },
    {
      'code': 'ASIAN25',
      'discount': '25% OFF',
      'title': 'Asian Cuisine Weekend',
      'minSpend': 25,
      'expiresIn': '4 Days',
      'category': 'Asian Category',
      'discountType': 'percent',
      'discountValue': 25.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await ApiService.getUserId() ?? prefs.getString('user_id') ?? 'local_user';
      
      try {
        _user = await ApiService.getProfile();
      } catch (_) {}

      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final lastClaimDate = prefs.getString('daily_claim_date_$userId') ?? prefs.getString('daily_claim_date');
      
      _isTodayClaimed = (lastClaimDate == todayStr);
      _userCoins = prefs.getInt('user_coins_$userId') ?? prefs.getInt('user_coins') ?? 1250;
      _voucherCount = prefs.getInt('user_vouchers_$userId') ?? prefs.getInt('user_vouchers') ?? 25;
      _currentDayIndex = prefs.getInt('user_streak_day_$userId') ?? prefs.getInt('user_streak_day') ?? 0;
      
      if (lastClaimDate != null && lastClaimDate != todayStr) {
        final lastDate = DateTime.tryParse(lastClaimDate);
        final now = DateTime.now();
        if (lastDate != null) {
          final diffDays = DateTime(now.year, now.month, now.day).difference(DateTime(lastDate.year, lastDate.month, lastDate.day)).inDays;
          if (diffDays >= 1) {
            _currentDayIndex = (_currentDayIndex + 1) % 7;
            await prefs.setInt('user_streak_day_$userId', _currentDayIndex);
            await prefs.setInt('user_streak_day', _currentDayIndex);
          }
        }
      }
      _isChefPlus = prefs.getBool('user_chef_plus_$userId') ?? prefs.getBool('user_chef_plus') ?? true;

      // Load claimed offers (combining user-scoped and global keys)
      final claimedListUser = prefs.getStringList('claimed_offers_$userId') ?? [];
      final claimedListGlobal = prefs.getStringList('claimed_offers_global') ?? [];
      _claimedOfferIds = {...claimedListUser, ...claimedListGlobal};

      // Load saved vouchers if any
      final savedVouchersJson = prefs.getString('user_claimed_vouchers_$userId') ?? prefs.getString('user_claimed_vouchers_global');
      if (savedVouchersJson != null) {
        try {
          final List decoded = jsonDecode(savedVouchersJson);
          final customVouchers = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          for (var v in customVouchers) {
            if (!_userVouchers.any((existing) => existing['code'] == v['code'])) {
              _userVouchers.insert(0, v);
            }
          }
        } catch (_) {}
      }

      // Fetch promotions and kitchens
      try {
        final homeData = await ApiService.getHomeData();
        _promotions = (homeData['promotions'] as List<PromotionModel>?) ?? [];
        _featuredKitchens = (homeData['featured_kitchens'] as List<KitchenModel>?) ?? [];
      } catch (_) {}

      if (_featuredKitchens.isEmpty) {
        try {
          _featuredKitchens = await ApiService.getKitchens(featured: true);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Error loading Promo & Rewards data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await ApiService.getUserId() ?? prefs.getString('user_id') ?? 'local_user';

    // User-specific keys
    await prefs.setInt('user_coins_$userId', _userCoins);
    await prefs.setInt('user_vouchers_$userId', _voucherCount);
    await prefs.setInt('user_streak_day_$userId', _currentDayIndex);
    await prefs.setBool('user_chef_plus_$userId', _isChefPlus);
    await prefs.setStringList('claimed_offers_$userId', _claimedOfferIds.toList());
    await prefs.setString('user_claimed_vouchers_$userId', jsonEncode(_userVouchers));

    // Global fallback keys (guarantees persistence even if session key shifts)
    await prefs.setInt('user_coins', _userCoins);
    await prefs.setInt('user_vouchers', _voucherCount);
    await prefs.setInt('user_streak_day', _currentDayIndex);
    await prefs.setBool('user_chef_plus', _isChefPlus);
    await prefs.setStringList('claimed_offers_global', _claimedOfferIds.toList());
    await prefs.setString('user_claimed_vouchers_global', jsonEncode(_userVouchers));
  }

  // ==========================================
  // ACTION: CLAIM EXCLUSIVE OFFER
  // ==========================================
  Future<void> _claimExclusiveOffer(Map<String, dynamic> offer) async {
    final offerId = offer['id'] as String;
    if (_claimedOfferIds.contains(offerId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have already claimed "${offer['title']}"! It is ready to use at Checkout.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newVoucher = {
      'code': offer['code'],
      'discount': offer['discount'],
      'title': offer['title'],
      'subtitle': offer['subtitle'],
      'minSpend': offer['minSpend'] ?? 0.0,
      'expiresIn': '7 Days',
      'category': 'Exclusive Offer',
      'discountType': offer['discountType'] ?? 'percent',
      'discountValue': (offer['discountValue'] as num?)?.toDouble() ?? 0.0,
    };

    setState(() {
      _claimedOfferIds.add(offerId);
      _voucherCount++;
      if (!_userVouchers.any((v) => v['code'] == offer['code'])) {
        _userVouchers.insert(0, newVoucher);
      }
    });

    await _saveUserData();

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.celebration, color: AppColors.primary, size: 28),
            const SizedBox(width: 10),
            Text('Voucher Claimed! 🎉', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${offer['title']} has been claimed!',
              style: AppTextStyles.bodyLg(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Code: ${offer['code']} (${offer['discount']})',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This voucher will automatically apply a discount when you place an order at Checkout!',
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ACTION: CLAIM DAILY COINS
  // ==========================================
  Future<void> _claimDailyReward() async {
    if (_isTodayClaimed) {
      _showAlreadyClaimedDialog();
      return;
    }

    final coinsGained = _dailyCoins[_currentDayIndex];
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    setState(() {
      _userCoins += coinsGained;
      _isTodayClaimed = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = await ApiService.getUserId() ?? prefs.getString('user_id') ?? 'local_user';
    await prefs.setString('daily_claim_date_$userId', todayStr);
    await prefs.setString('daily_claim_date', todayStr);
    await _saveUserData();

    if (!mounted) return;
    _showCoinClaimedSuccessDialog(coinsGained);
  }

  void _showCoinClaimedSuccessDialog(int coinsGained) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.monetization_on, color: AppColors.primary, size: 48),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Daily Reward Claimed!',
                  style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '+$coinsGained GoChef Coins',
                  style: AppTextStyles.displayLgMobile(color: AppColors.primary).copyWith(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  'Day ${_currentDayIndex + 1} Check-in Complete!\nYour new balance is $_userCoins coins.',
                  style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Awesome!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAlreadyClaimedDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final nextDayIndex = (_currentDayIndex + 1) % 7;
        final nextCoins = _dailyCoins[nextDayIndex];
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 10),
              Text('Already Claimed Today', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18)),
            ],
          ),
          content: Text(
            'You have already collected Day ${_currentDayIndex + 1} coins!\n\nCome back tomorrow to unlock Day ${nextDayIndex + 1} reward ($nextCoins coins)!',
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // ACTION: DAY DETAIL SHEET
  // ==========================================
  void _showDayDetail(int dayIndex) {
    final coins = _dailyCoins[dayIndex];
    final isToday = dayIndex == _currentDayIndex;
    final isPast = dayIndex < _currentDayIndex || (isToday && _isTodayClaimed);
    final status = isPast
        ? 'Claimed ✓'
        : (isToday ? 'Available Today!' : 'Upcoming Reward');

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                  border: Border.all(color: isToday ? AppColors.primary : Colors.transparent),
                ),
                child: Icon(Icons.monetization_on, color: isToday ? AppColors.primary : Colors.amber, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Day ${dayIndex + 1} Reward',
                style: AppTextStyles.headlineMd(color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                '$coins Coins',
                style: AppTextStyles.displayLgMobile(color: AppColors.primary).copyWith(fontSize: 26),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: isPast
                    ? BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      )
                    : null,
                child: Text(
                  status,
                  style: TextStyle(
                    color: isPast ? Colors.green : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (isToday && !_isTodayClaimed)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _claimDailyReward();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Claim Reward Now', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Close', style: TextStyle(color: Colors.white)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // ACTION: VOUCHERS MODAL
  // ==========================================
  void _showVouchersModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('My Vouchers', style: AppTextStyles.headlineMd(color: Colors.white)),
                          Text('$_voucherCount vouchers ready to use', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('$_voucherCount Available', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: _userVouchers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final v = _userVouchers[idx];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(Icons.confirmation_number, color: Colors.orange, size: 26),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        v['discount'] ?? 'PROMO',
                                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(v['title'] ?? 'Discount Voucher', style: AppTextStyles.bodyLg(color: Colors.white).copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 2),
                                    Text('Code: ${v['code']} • Expires in ${v['expiresIn'] ?? '7 Days'}', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: v['code']));
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    SnackBar(
                                      content: Text('Voucher code "${v['code']}" copied! Use it at Checkout.'),
                                      backgroundColor: AppColors.primary,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.onPrimary,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Use', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // ACTION: GOCHEF PLUS MODAL
  // ==========================================
  void _showChefPlusModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.stars, color: Colors.green, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('GoChef PLUS', style: AppTextStyles.headlineMd(color: Colors.white)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('ACTIVE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                            )
                          ],
                        ),
                        Text('VIP Membership Active', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Your VIP Benefits:', style: AppTextStyles.bodyLg(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildPlusBenefit(Icons.delivery_dining, 'Unlimited \$0 Free Delivery on all orders'),
              _buildPlusBenefit(Icons.percent, 'Extra 15% discount across 500+ restaurants'),
              _buildPlusBenefit(Icons.monetization_on, '2x Daily Coins & Loyalty Points Multiplier'),
              _buildPlusBenefit(Icons.bolt, 'Priority Kitchen Prep & Express Delivery'),
              _buildPlusBenefit(Icons.support_agent, '24/7 Dedicated Concierge Support'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchResultsScreen(initialQuery: 'PLUS Deals')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Explore PLUS Exclusive Deals', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlusBenefit(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ACTION: ENTER PROMO CODE DIALOG
  // ==========================================
  void _showPromoCodeDialog() {
    final controller = TextEditingController();
    bool isValidating = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.percent, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text('Apply Promo Code', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Enter coupon or chef promo code below:', style: AppTextStyles.bodyMd(color: Colors.white70)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2),
                    decoration: InputDecoration(
                      hintText: 'e.g. GOCHEF50',
                      hintStyle: const TextStyle(color: Colors.white60, letterSpacing: 1),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white)),
                      prefixIcon: const Icon(Icons.local_offer, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try: GOCHEF50, WELCOME10, PLUSVIP, CHEFBUDI',
                    style: AppTextStyles.labelSm(color: Colors.white60).copyWith(fontSize: 11),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isValidating ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: isValidating
                      ? null
                      : () async {
                          final code = controller.text.trim().toUpperCase();
                          if (code.isEmpty) return;

                          setDialogState(() => isValidating = true);
                          await Future.delayed(const Duration(milliseconds: 500));

                          final is50 = (code == 'GOCHEF50' || code == 'FIRST50');
                          final newVoucher = {
                            'code': code,
                            'discount': is50 ? '50% OFF' : '20% OFF',
                            'title': '$code Promo Applied',
                            'minSpend': 15.0,
                            'expiresIn': '7 Days',
                            'category': 'All Orders',
                            'discountType': 'percent',
                            'discountValue': is50 ? 50.0 : 20.0,
                          };

                          setState(() {
                            _voucherCount++;
                            _userVouchers.insert(0, newVoucher);
                          });
                          await _saveUserData();

                          if (ctx.mounted) Navigator.pop(ctx);

                          if (mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text('🎉 Promo Code "$code" successfully applied! Voucher added to wallet.'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isValidating
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // ACTION: TERMS & CONDITIONS MODAL
  // ==========================================
  void _showTermsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Terms & Conditions', style: AppTextStyles.headlineMd(color: Colors.white)),
              const SizedBox(height: 16),
              _buildTermItem('1. Daily Coin Rewards', 'Users can claim 1 check-in reward per calendar day. The 7-day cycle repeats sequentially upon completion.'),
              _buildTermItem('2. Coin Redemption', 'GoChef coins can be applied as instant discounts on checkout or converted into special food perks.'),
              _buildTermItem('3. Voucher Expiry', 'Promotional vouchers expire within the specified timeframe from the issue date.'),
              _buildTermItem('4. GoChef PLUS', 'Membership privileges apply automatically at checkout for subscribed accounts.'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()));
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white38),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Full Terms', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Understood', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTermItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyLg(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 2),
          Text(desc, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  // ==========================================
  // ACTION: CATEGORY TAP
  // ==========================================
  void _onCategoryTap(String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(initialQuery: categoryName),
      ),
    );
  }

  // ==========================================
  // BUILD METHOD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: _loadAllData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // AppBar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Promo & Rewards',
                            style: AppTextStyles.headlineLgMobile(color: Colors.white)
                                .copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          if (_user != null)
                            Text(
                              'Hello, ${_user!.name} • $_userCoins Coins',
                              style: AppTextStyles.labelSm(color: Colors.white70),
                            )
                          else if (_isLoading)
                            Text(
                              'Loading your rewards...',
                              style: AppTextStyles.labelSm(color: Colors.white70),
                            ),
                        ],
                      ),
                      const NotificationBell(iconColor: Colors.white),
                    ],
                  ),
                ),
              ),

              // Top Card: Vouchers & Subscription
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // 25 Vouchers Tap Target
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: _showVouchersModal,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.confirmation_number, color: Colors.orange, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('$_voucherCount Vouchers', style: AppTextStyles.bodyLg(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                                            Text('Use now!', style: AppTextStyles.labelSm(color: Colors.white70)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(width: 1, height: 40, color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                            // GoChef PLUS Tap Target
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: _showChefPlusModal,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.star, color: Colors.green, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('GoChef PLUS', style: AppTextStyles.bodyLg(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                                            Text(_isChefPlus ? 'Subscribed' : 'Join Now', style: AppTextStyles.labelSm(color: Colors.green)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Enter Promo Code Tap Target
                        Material(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: _showPromoCodeDialog,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.percent, color: Colors.white70, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text('Enter promo code', style: AppTextStyles.bodyMd(color: Colors.white70)),
                                  ),
                                  const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              // Daily Check-in Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.card_giftcard, color: Colors.white, size: 28),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('A gift for you!', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                                      Text('Claim your daily coins.', style: AppTextStyles.labelSm(color: Colors.white.withValues(alpha: 0.9))),
                                    ],
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: _claimDailyReward,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isTodayClaimed ? Colors.white.withValues(alpha: 0.25) : Colors.white,
                                  foregroundColor: _isTodayClaimed ? Colors.white : AppColors.primary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: Text(
                                  _isTodayClaimed ? 'Claimed ✓' : 'Claim',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _isTodayClaimed ? Colors.white : AppColors.primary,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(7, (index) {
                                  final isToday = index == _currentDayIndex;
                                  final isPast = index < _currentDayIndex || (isToday && _isTodayClaimed);
                                  final coins = _dailyCoins[index];
                                  return GestureDetector(
                                    onTap: () => _showDayDetail(index),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: isPast
                                                ? AppColors.surfaceContainerHigh
                                                : AppColors.surfaceContainerLow,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: (isToday && !_isTodayClaimed) ? Colors.white70 : Colors.transparent,
                                              width: (isToday && !_isTodayClaimed) ? 1.5 : 1,
                                            ),
                                          ),
                                          child: Icon(
                                            isPast ? Icons.check : Icons.monetization_on,
                                            size: 20,
                                            color: isPast
                                                ? Colors.greenAccent
                                                : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          coins.toString(),
                                          style: AppTextStyles.labelSm(
                                            color: Colors.white,
                                          ).copyWith(fontWeight: FontWeight.bold, fontSize: 11),
                                        ),
                                        Text(
                                          'Day ${index + 1}',
                                          style: AppTextStyles.labelSm(color: Colors.white70).copyWith(fontSize: 9),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: _showTermsModal,
                                    child: Text('Expires in 7 Days', style: AppTextStyles.labelSm(color: Colors.white70)),
                                  ),
                                  GestureDetector(
                                    onTap: _showTermsModal,
                                    child: Text('T&C Apply', style: AppTextStyles.labelSm(color: Colors.white70).copyWith(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              // Food Shortcuts: Explore Categories
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32.0, bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('Explore Categories', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            _buildShortcutIcon(Icons.local_fire_department, 'Trending'),
                            const SizedBox(width: 16),
                            _buildShortcutIcon(Icons.ramen_dining, 'Asian'),
                            const SizedBox(width: 16),
                            _buildShortcutIcon(Icons.local_pizza, 'Western'),
                            const SizedBox(width: 16),
                            _buildShortcutIcon(Icons.fastfood, 'Fast Food'),
                            const SizedBox(width: 16),
                            _buildShortcutIcon(Icons.eco, 'Healthy'),
                            const SizedBox(width: 16),
                            _buildShortcutIcon(Icons.cake, 'Dessert'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top Promos Today
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Top Promos Today ~', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                          GestureDetector(
                            onTap: () => _onCategoryTap('Promos'),
                            child: Text('View All', style: AppTextStyles.labelSm(color: Colors.white)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: _featuredKitchens.isNotEmpty
                            ? ListView.separated(
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                itemCount: _featuredKitchens.length,
                                separatorBuilder: (context, index) => const SizedBox(width: 16),
                                itemBuilder: (context, idx) {
                                  final k = _featuredKitchens[idx];
                                  final discounts = ['40% OFF', '25% OFF', 'BUY 1 GET 1', '30% OFF', '20% OFF'];
                                  final discount = discounts[idx % discounts.length];
                                  return _buildPromoCardWithKitchen(
                                    discount: discount,
                                    kitchen: k,
                                  );
                                },
                              )
                            : ListView(
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                children: [
                                  _buildPromoCard('40% OFF', 'Spicy Thai Kitchen', 'Authentic Thai Cuisine', 'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=500&auto=format&fit=crop'),
                                  const SizedBox(width: 16),
                                  _buildPromoCard('21% OFF', 'Fresh Poke', 'Hawaiian Bowls', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop'),
                                  const SizedBox(width: 16),
                                  _buildPromoCard('BUY 1 GET 1', 'Burger Master', 'American Fast Food', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop'),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // Exclusive Offers Section (Claimable Vouchers with dynamic Claim -> Claimed status)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Exclusive Offers', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ..._exclusiveOffers.map((offer) {
                        final isClaimed = _claimedOfferIds.contains(offer['id']);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isClaimed
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : AppColors.outlineVariant.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isClaimed
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isClaimed ? Icons.check_circle : Icons.confirmation_number,
                                  color: isClaimed ? Colors.greenAccent : Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      offer['title'] ?? '',
                                      style: AppTextStyles.bodyLg(color: Colors.white).copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      offer['subtitle'] ?? '',
                                      style: AppTextStyles.labelSm(color: Colors.white70).copyWith(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _claimExclusiveOffer(offer),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isClaimed
                                      ? Colors.white.withValues(alpha: 0.15)
                                      : AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: Text(
                                  isClaimed ? 'Claimed ✓' : 'Claim',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isClaimed ? Colors.white70 : Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                      // Additional API promotions if available (de-duplicated)
                      ..._promotions
                          .where((p) => !_exclusiveOffers.any((e) => e['title'] == p.title || e['code'] == p.code))
                          .map((p) {
                        final apiId = 'api_promo_${p.id}';
                        final isClaimed = _claimedOfferIds.contains(apiId);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isClaimed
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : AppColors.outlineVariant.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isClaimed ? Colors.green.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isClaimed ? Icons.check_circle : Icons.confirmation_number,
                                  color: isClaimed ? Colors.greenAccent : Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.title, style: AppTextStyles.bodyLg(color: Colors.white).copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                                    if (p.subtitle.isNotEmpty)
                                      Text(p.subtitle, style: AppTextStyles.labelSm(color: Colors.white70).copyWith(fontSize: 11)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  final offerMap = {
                                    'id': apiId,
                                    'title': p.title,
                                    'subtitle': p.subtitle,
                                    'code': p.code.isNotEmpty ? p.code : 'PROMO${p.id}',
                                    'discount': p.discountPercent > 0 ? '${p.discountPercent}% OFF' : 'SPECIAL',
                                    'discountType': 'percent',
                                    'discountValue': p.discountPercent > 0 ? p.discountPercent.toDouble() : 15.0,
                                    'minSpend': 0.0,
                                  };
                                  _claimExclusiveOffer(offerMap);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isClaimed ? Colors.white.withValues(alpha: 0.15) : AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: Text(
                                  isClaimed ? 'Claimed ✓' : 'Claim',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isClaimed ? Colors.white70 : Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
  Widget _buildShortcutIcon(IconData icon, String label) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onCategoryTap(label),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(height: 8),
              Text(label, style: AppTextStyles.labelSm(color: Colors.white70).copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoCardWithKitchen({
    required String discount,
    required KitchenModel kitchen,
  }) {
    final image = kitchen.coverImage.isNotEmpty
        ? kitchen.coverImage
        : (kitchen.avatar.isNotEmpty ? kitchen.avatar : 'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=500&auto=format&fit=crop');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KitchenProfileScreen(kitchenId: kitchen.id),
            ),
          );
        },
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      image,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 140,
                        color: AppColors.surfaceContainerHigh,
                        child: const Icon(Icons.restaurant, color: AppColors.onSurfaceVariant, size: 40),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: const BoxDecoration(
                        color: AppColors.fuchsia,
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
                      ),
                      child: Text(
                        discount,
                        style: AppTextStyles.labelSm(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kitchen.name, style: AppTextStyles.bodyLg(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(kitchen.description.isNotEmpty ? kitchen.description : (kitchen.cuisineType.isNotEmpty ? kitchen.cuisineType : 'Gourmet Kitchen'), style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoCard(String discount, String title, String subtitle, String imageUrl) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onCategoryTap(title),
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      imageUrl,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 140,
                        color: AppColors.surfaceContainerHigh,
                        child: const Icon(Icons.restaurant, color: AppColors.onSurfaceVariant, size: 40),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: const BoxDecoration(
                        color: AppColors.fuchsia,
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
                      ),
                      child: Text(
                        discount,
                        style: AppTextStyles.labelSm(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.bodyLg(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
