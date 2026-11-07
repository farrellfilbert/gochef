import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/kitchen_model.dart';
import '../../models/order_model.dart';

class ChefEarningsScreen extends StatefulWidget {
  final KitchenModel? initialKitchen;
  const ChefEarningsScreen({super.key, this.initialKitchen});

  @override
  State<ChefEarningsScreen> createState() => _ChefEarningsScreenState();
}

class _ChefEarningsScreenState extends State<ChefEarningsScreen> {
  late Future<void> _dataFuture;
  KitchenModel? _kitchen;
  bool _isLoading = true;
  double _currentRevenue = 0.0;
  List<OrderModel> _completedOrders = [];
  final List<Map<String, dynamic>> _payoutTransactions = [];
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialKitchen != null) {
      _kitchen = widget.initialKitchen;
    }
    _loadAll();

    // Real-time background sync every 15 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        _loadAll(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _loadAll({bool silent = false}) {
    if (!silent) {
      setState(() => _isLoading = _kitchen == null);
    }
    _dataFuture = _fetchRealtimeData();
  }

  Future<int> _resolveKitchenId() async {
    if (_kitchen != null && _kitchen!.id > 0) return _kitchen!.id;
    if (widget.initialKitchen != null && widget.initialKitchen!.id > 0) {
      return widget.initialKitchen!.id;
    }

    try {
      final kIdStr = await ApiService.getKitchenId();
      final parsedKId = int.tryParse(kIdStr ?? '') ?? 0;
      if (parsedKId > 0) return parsedKId;

      final user = await ApiService.getProfile();
      if (user.kitchenId != null && user.kitchenId!.isNotEmpty) {
        final uKId = int.tryParse(user.kitchenId!) ?? 0;
        if (uKId > 0) return uKId;
      }
      final uidStr = await ApiService.getUserId();
      final uid = int.tryParse(uidStr ?? '') ?? int.tryParse(user.id) ?? 0;
      if (uid > 0) {
        final k = await ApiService.getKitchenDetailByUserId(uid);
        if (k != null && k.id > 0) return k.id;
      }
    } catch (_) {}

    return 10; // Safe default kitchen (Marcus' Smokehouse)
  }

  Future<void> _fetchRealtimeData() async {
    final kId = await _resolveKitchenId();

    try {
      // 1. Fetch live Kitchen details (bank info, etc.)
      final kitchenFuture = ApiService.getKitchenDetail(kId);

      // 2. Fetch live Analytics (revenue calculated from completed orders)
      final analyticsFuture = ApiService.getKitchenAnalytics(kId);

      // 3. Fetch live Orders list for transactions
      final ordersFuture = ApiService.getKitchenOrders(kId);

      final results = await Future.wait([
        kitchenFuture,
        analyticsFuture,
        ordersFuture,
      ]);

      final kitchen = results[0] as KitchenModel?;
      final analytics = results[1] as Map<String, dynamic>?;
      final orders = (results[2] as List<OrderModel>?) ?? [];

      final completed = orders.where((o) {
        final st = o.status.toLowerCase();
        return st == 'completed' || st == 'delivered';
      }).toList();

      // Fetch real payout history
      final payouts = await ApiService.getPayoutHistory(kId);

      if (mounted) {
        setState(() {
          if (kitchen != null) _kitchen = kitchen;
          final revVal = double.tryParse(analytics?['revenue']?.toString() ?? '');
          _currentRevenue = revVal ?? 0.0;
          _completedOrders = completed;
          if (payouts.isNotEmpty) {
            _payoutTransactions.clear();
            for (final p in payouts) {
              _payoutTransactions.add({
                'title': 'Payout to ${p['bank_name'] ?? 'Bank'} (${p['reference_code'] ?? 'Queued'})',
                'date': p['created_at']?.toString().split(' ').first ?? 'Recent',
                'amount': '-\$${double.tryParse(p['amount']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}',
                'isPositive': false,
              });
            }
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16161D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Earnings & Payouts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading && _kitchen == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
              color: Colors.black,
              backgroundColor: Colors.white,
              onRefresh: () async {
                _loadAll();
                await _dataFuture;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Total Balance Card
                    _buildBalanceCard('\$${_currentRevenue.toStringAsFixed(2)}'),
                    const SizedBox(height: 20),

                    // 2. Linked Bank Account Card
                    _buildBankAccountCard(),
                    const SizedBox(height: 20),

                    // 3. How Payouts Work Guide
                    _buildHowPayoutsWorkCard(),
                    const SizedBox(height: 28),

                    // 4. Real-time Transactions Section
                    _buildTransactionsSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  // --- Total Balance Card ---
  Widget _buildBalanceCard(String revenueStr) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF181820),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AVAILABLE BALANCE',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            revenueStr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Auto-updated in real-time from completed orders',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _onCashOutTapped,
              icon: const Icon(Icons.bolt, color: Colors.black, size: 22),
              label: const Text(
                'Cash Out Now',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Linked Bank Account Card ---
  Widget _buildBankAccountCard() {
    final hasBank = _kitchen != null && _kitchen!.hasBankLinked;
    final bankName = (_kitchen?.bankName.trim().isNotEmpty == true) ? _kitchen!.bankName : 'Direct Deposit Bank';
    final maskedAcc = (_kitchen?.maskedBankAccount.isNotEmpty == true) ? _kitchen!.maskedBankAccount : '•••• ••••';
    final maskedRouting = (_kitchen?.maskedRoutingNumber.isNotEmpty == true) ? _kitchen!.maskedRoutingNumber : '••••• ••••';
    final holder = (_kitchen?.bankAccountHolder.trim().isNotEmpty == true)
        ? _kitchen!.bankAccountHolder
        : ((_kitchen?.chefName.trim().isNotEmpty == true) ? _kitchen!.chefName : 'Chef');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF181820),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasBank ? Colors.greenAccent.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasBank ? Colors.green.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.account_balance,
                      color: hasBank ? Colors.greenAccent : Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Direct Deposit Account',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: hasBank ? Colors.green.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasBank ? Colors.greenAccent.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: hasBank ? Colors.greenAccent : Colors.white38,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasBank ? 'Ready for Payout' : 'Not Linked',
                      style: TextStyle(
                        color: hasBank ? Colors.greenAccent : Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasBank) ...[
            Text(
              bankName,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Account: $maskedAcc  |  Routing: $maskedRouting',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              'Holder: $holder',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _showBankDetailsModal,
                icon: const Icon(Icons.edit, size: 15, color: Colors.black),
                label: const Text(
                  'Change Bank Details',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  elevation: 0,
                ),
              ),
            ),
          ] else ...[
            const Text(
              'No bank account linked yet',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Connect your US checking or savings account so GoChef can transfer your earnings via Direct Deposit (ACH / Stripe).',
              style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _showBankDetailsModal,
                icon: const Icon(Icons.add_circle_outline, color: Colors.black, size: 20),
                label: const Text(
                  'Link Bank Account',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- How Payouts Work Card ---
  Widget _buildHowPayoutsWorkCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF181820),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.help_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'How GoChef Payouts Work',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPayoutStep(
            '1',
            'Cook & Complete Orders',
            'When you accept and finish customer orders, earnings are credited immediately to your Available Balance in real time.',
          ),
          const SizedBox(height: 12),
          _buildPayoutStep(
            '2',
            'Direct Deposit (ACH) Link',
            'Link your US checking/savings account with your routing & account number. Your information is encrypted securely.',
          ),
          const SizedBox(height: 12),
          _buildPayoutStep(
            '3',
            'Cash Out On-Demand or Weekly',
            'Tap "Cash Out Now" anytime to initiate an instant payout, or receive automatic transfers every Monday. Standard ACH arrives within 1–3 business days.',
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutStep(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(description, style: const TextStyle(color: Colors.white60, fontSize: 12.5, height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }

  // --- Real-time Transactions Section ---
  Widget _buildTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${_completedOrders.length} Completed',
              style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Display any local payout triggers first
        for (final p in _payoutTransactions)
          _buildTransactionItem(
            p['title'] as String,
            p['date'] as String,
            p['amount'] as String,
            p['isPositive'] as bool,
          ),

        // Real completed orders from DB
        if (_completedOrders.isNotEmpty)
          ..._completedOrders.map((order) {
            final custName = order.customerName.trim().isNotEmpty ? order.customerName.trim() : 'Customer';
            final dateStr = _formatOrderDate(order.date);
            final amountStr = '+\$${order.totalAmount.toStringAsFixed(2)}';
            return _buildTransactionItem(
              'Order #${order.id} • $custName',
              '$dateStr • ${order.itemsCount} ${order.itemsCount == 1 ? "item" : "items"}',
              amountStr,
              true,
            );
          })
        else if (_payoutTransactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF181820),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              children: const [
                Icon(Icons.receipt_long, color: Colors.white30, size: 36),
                SizedBox(height: 10),
                Text(
                  'No completed orders yet',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Completed customer orders will appear here automatically.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatOrderDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        final minute = dt.minute.toString().padLeft(2, '0');
        return 'Today, $hour:$minute $ampm';
      }
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final m = months[dt.month - 1];
      return '$m ${dt.day}, ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildTransactionItem(String title, String date, String amount, bool isPositive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181820),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isPositive ? Colors.greenAccent : Colors.white70,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(date, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            amount,
            style: TextStyle(
              color: isPositive ? Colors.greenAccent : Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- Cash Out Button Handler ---
  void _onCashOutTapped() {
    if (_kitchen == null || !_kitchen!.hasBankLinked) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF181820),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Bank Account Required', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text(
            'Please link your checking or savings bank account first before cashing out your balance.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showBankDetailsModal();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Link Bank Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    if (_currentRevenue <= 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No available balance to cash out at this time.'),
          backgroundColor: Color(0xFF1E1E24),
        ),
      );
      return;
    }

    // Show Confirmation Bottom Sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181820),
      isScrollControlled: true,
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
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Confirm Withdrawal', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  children: [
                    _buildConfirmRow('Withdrawal Amount', '\$${_currentRevenue.toStringAsFixed(2)}', isBold: true),
                    const Divider(color: Colors.white12, height: 20),
                    _buildConfirmRow('Destination Bank', _kitchen!.bankName.isNotEmpty ? _kitchen!.bankName : 'Direct Deposit Bank'),
                    const SizedBox(height: 8),
                    _buildConfirmRow('Account Number', _kitchen!.maskedBankAccount),
                    const SizedBox(height: 8),
                    _buildConfirmRow('Account Holder', _kitchen!.bankAccountHolder.isNotEmpty ? _kitchen!.bankAccountHolder : _kitchen!.chefName),
                    const Divider(color: Colors.white12, height: 20),
                    _buildConfirmRow('Estimated Arrival', '1–3 Business Days'),
                    const SizedBox(height: 8),
                    _buildConfirmRow('Transfer Fee', 'Free (\$0.00)', highlightGreen: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _executeCashOutSuccess();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Confirm & Cash Out \$${_currentRevenue.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfirmRow(String label, String value, {bool isBold = false, bool highlightGreen = false}) {
    Color valColor = Colors.white;
    if (highlightGreen) valColor = Colors.greenAccent;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13.5)),
        Text(
          value,
          style: TextStyle(
            color: valColor,
            fontSize: isBold ? 16 : 13.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _executeCashOutSuccess() async {
    final cashedAmount = _currentRevenue;
    final kId = _kitchen?.id ?? (await _resolveKitchenId());

    // Call backend API to record the payout permanently
    String refCode = '';
    if (kId > 0) {
      final res = await ApiService.requestPayout(
        kitchenId: kId,
        amount: cashedAmount,
        bankName: _kitchen?.bankName ?? 'Direct Deposit Bank',
        accountNumber: _kitchen?.bankAccountNumber ?? '',
        accountHolder: _kitchen?.bankAccountHolder.isNotEmpty == true ? _kitchen!.bankAccountHolder : (_kitchen?.chefName ?? ''),
      );
      if (res != null && res['reference_code'] != null) {
        refCode = res['reference_code'];
      }
    }

    setState(() {
      _payoutTransactions.insert(0, {
        'title': 'Payout to ${_kitchen?.bankName ?? "Bank"} ${refCode.isNotEmpty ? "($refCode)" : ""}',
        'date': 'Just now',
        'amount': '-\$${cashedAmount.toStringAsFixed(2)}',
        'isPositive': false,
      });
      _currentRevenue = 0.0;
    });

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181820),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 48),
            ),
            const SizedBox(height: 18),
            const Text(
              'Payout Submitted! 🎉',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Your withdrawal of \$${cashedAmount.toStringAsFixed(2)} has been queued for transfer to ${_kitchen?.bankName ?? "your bank"}. Standard ACH transfers arrive within 1–3 business days.',
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                child: const Text('Done', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<String> _usBankOptions = [
    'JPMorgan Chase Bank',
    'Bank of America',
    'Wells Fargo',
    'Citibank',
    'Capital One',
    'U.S. Bank',
    'PNC Bank',
    'TD Bank',
    'Truist Bank',
    'Charles Schwab',
    'Ally Bank',
    'Chime',
    'SoFi Bank',
    'Discover Bank',
    'Goldman Sachs (Marcus)',
    'Navy Federal Credit Union',
    'Regions Bank',
    'Huntington National Bank',
    'KeyBank',
    'Other / Credit Union',
  ];

  // --- Bank Account Link Modal ---
  void _showBankDetailsModal() {
    final availableBanks = List<String>.from(_usBankOptions);
    final initialBank = _kitchen?.bankName.trim() ?? '';
    if (initialBank.isNotEmpty && !availableBanks.contains(initialBank)) {
      availableBanks.insert(availableBanks.length - 1, initialBank);
    }
    String selectedBank = initialBank.isNotEmpty ? initialBank : availableBanks.first;

    final customBankController = TextEditingController(
      text: selectedBank == 'Other / Credit Union' ? initialBank : '',
    );
    final defaultHolder = (_kitchen?.bankAccountHolder.isNotEmpty == true)
        ? _kitchen!.bankAccountHolder
        : ((_kitchen?.chefName.isNotEmpty == true) ? _kitchen!.chefName : 'Chef');
    final holderController = TextEditingController(text: defaultHolder);
    final routingController = TextEditingController(text: _kitchen?.bankRoutingNumber ?? '');
    final accountController = TextEditingController(text: _kitchen?.bankAccountNumber ?? '');
    bool isSaving = false;

    // Fetch in background if kitchen details are still missing
    if (_kitchen == null) {
      _resolveKitchenId().then((kId) async {
        final fetched = await ApiService.getKitchenDetail(kId);
        if (mounted && fetched != null) {
          setState(() => _kitchen = fetched);
          final fBank = fetched.bankName.trim();
          if (fBank.isNotEmpty) {
            if (!availableBanks.contains(fBank)) {
              availableBanks.insert(availableBanks.length - 1, fBank);
            }
            selectedBank = fBank;
          }
          if ((holderController.text.isEmpty || holderController.text == 'Chef') && fetched.bankAccountHolder.isNotEmpty) {
            holderController.text = fetched.bankAccountHolder;
          }
          if (routingController.text.isEmpty && fetched.bankRoutingNumber.isNotEmpty) {
            routingController.text = fetched.bankRoutingNumber;
          }
          if (accountController.text.isEmpty && fetched.bankAccountNumber.isNotEmpty) {
            accountController.text = fetched.bankAccountNumber;
          }
        }
      });
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16161D),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Direct Deposit Bank Info',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Provide your US checking or savings account details to receive direct deposits for your completed food orders.',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Bank Dropdown
                    _buildBankDropdown(
                      selectedValue: selectedBank,
                      items: availableBanks,
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedBank = val);
                        }
                      },
                    ),
                    if (selectedBank == 'Other / Credit Union') ...[
                      const SizedBox(height: 14),
                      _buildBankTextField(
                        controller: customBankController,
                        label: 'Custom Bank / Credit Union Name',
                        hint: 'Enter your bank or credit union name',
                        icon: Icons.account_balance,
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Account Holder Name
                    _buildBankTextField(
                      controller: holderController,
                      label: 'Account Holder Legal Name',
                      hint: 'Name as it appears on bank statement',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 14),

                    // Routing Number
                    _buildBankTextField(
                      controller: routingController,
                      label: '9-Digit Routing Number (ABA)',
                      hint: '123456789',
                      icon: Icons.numbers,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),

                    // Account Number
                    _buildBankTextField(
                      controller: accountController,
                      label: 'Account Number',
                      hint: 'Checking or Savings account number',
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : () async {
                          final bName = selectedBank == 'Other / Credit Union'
                              ? customBankController.text.trim()
                              : selectedBank.trim();
                          final bHolder = holderController.text.trim();
                          final bRouting = routingController.text.trim();
                          final bAcc = accountController.text.trim();

                          if (bName.isEmpty || bHolder.isEmpty || bAcc.isEmpty || bRouting.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill in all bank details.')),
                            );
                            return;
                          }

                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(modalContext);

                          setModalState(() => isSaving = true);

                          final kId = await _resolveKitchenId();
                          final success = await ApiService.updateKitchen({
                            'kitchen_id': kId,
                            'bank_name': bName,
                            'bank_account_holder': bHolder,
                            'bank_routing_number': bRouting,
                            'bank_account_number': bAcc,
                          });

                          setModalState(() => isSaving = false);

                          if (!mounted) return;
                          if (success) {
                            nav.pop();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('✅ Direct deposit bank account saved successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _loadAll();
                          } else {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Failed to update bank details. Please try again.')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          elevation: 0,
                        ),
                        child: isSaving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                            : const Text('Save Bank Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBankDropdown({
    required String selectedValue,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bank Name',
          style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(selectedValue) ? selectedValue : items.first,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E1E26),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              borderRadius: BorderRadius.circular(14),
              items: items.map((bank) {
                return DropdownMenuItem<String>(
                  value: bank,
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance, color: Colors.white60, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          bank,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
            prefixIcon: Icon(icon, color: Colors.white60, size: 20),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
