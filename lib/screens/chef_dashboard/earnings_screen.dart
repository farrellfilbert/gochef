import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../models/kitchen_model.dart';

class ChefEarningsScreen extends StatefulWidget {
  const ChefEarningsScreen({super.key});

  @override
  State<ChefEarningsScreen> createState() => _ChefEarningsScreenState();
}

class _ChefEarningsScreenState extends State<ChefEarningsScreen> {
  late Future<Map<String, dynamic>?> _analyticsFuture;
  KitchenModel? _kitchen;
  bool _isLoadingKitchen = true;
  double _currentRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() {
    _analyticsFuture = _loadData();
  }

  Future<Map<String, dynamic>?> _loadData() async {
    setState(() => _isLoadingKitchen = true);
    final user = await ApiService.getProfile();
    if (user.kitchenId != null) {
      final parsedId = int.tryParse(user.kitchenId!) ?? 0;
      if (parsedId > 0) {
        final kitchen = await ApiService.getKitchenDetail(parsedId);
        final analytics = await ApiService.getKitchenAnalytics(parsedId);
        if (mounted) {
          setState(() {
            _kitchen = kitchen;
            _isLoadingKitchen = false;
            final revVal = double.tryParse(analytics?['revenue']?.toString() ?? '');
            _currentRevenue = revVal ?? 0.0;
          });
        }
        return analytics;
      }
    }
    if (mounted) {
      setState(() => _isLoadingKitchen = false);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        elevation: 0,
        title: const Text('Earnings & Payouts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _isLoadingKitchen) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final revenueStr = '\$${_currentRevenue.toStringAsFixed(2)}';

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              _loadAll();
              await _analyticsFuture;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Total Balance Card
                  _buildBalanceCard(revenueStr),
                  const SizedBox(height: 24),

                  // 2. Linked Bank Account Card
                  _buildBankAccountCard(),
                  const SizedBox(height: 24),

                  // 3. How Payouts Work Guide
                  _buildHowPayoutsWorkCard(),
                  const SizedBox(height: 28),

                  // 4. Recent Transactions
                  Text('Recent Transactions', style: AppTextStyles.headlineMd(color: Colors.white)),
                  const SizedBox(height: 14),
                  _buildTransactionItem('Payout sent to Bank', 'Yesterday', '-\$420.50', false),
                  _buildTransactionItem('Order #ORD-2026-3027', 'Today, 2:30 PM', '+\$110.00', true),
                  _buildTransactionItem('Order #ORD-2026-1231', 'Today, 1:15 PM', '+\$8.50', true),
                  _buildTransactionItem('Order #ORD-1028', 'Oct 20, 1:15 PM', '+\$32.00', true),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Total Balance Card ---
  Widget _buildBalanceCard(String revenueStr) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('AVAILABLE BALANCE', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(letterSpacing: 1.2)),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(revenueStr, style: AppTextStyles.displayLgMobile(color: Colors.white)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
              const SizedBox(width: 6),
              Text(
                'Auto-updated from completed customer orders',
                style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
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
    final bankName = _kitchen?.bankName.trim().isNotEmpty == true ? _kitchen!.bankName : 'Direct Deposit Bank';
    final maskedAcc = _kitchen?.maskedBankAccount.isNotEmpty == true ? _kitchen!.maskedBankAccount : 'Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢ Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢';
    final maskedRouting = _kitchen?.maskedRoutingNumber.isNotEmpty == true ? _kitchen!.maskedRoutingNumber : 'Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢ Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢';
    final holder = _kitchen?.bankAccountHolder.trim().isNotEmpty == true ? _kitchen!.bankAccountHolder : (_kitchen?.chefName ?? 'Cook');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasBank ? Colors.green.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.3),
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
                      color: hasBank ? Colors.green.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.account_balance,
                      color: hasBank ? Colors.green : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Direct Deposit Account',
                    style: AppTextStyles.bodyLg(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: hasBank ? Colors.green.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: hasBank ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasBank ? 'Ready for Payout' : 'Not Linked',
                      style: TextStyle(
                        color: hasBank ? Colors.green : Colors.orange,
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
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              'Holder: $holder',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _showBankDetailsModal,
                icon: const Icon(Icons.edit, size: 16, color: AppColors.primary),
                label: const Text('Change Bank Details', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ),
          ] else ...[
            Text(
              'No bank account linked yet',
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Connect your checking or savings account so GoChef can transfer your earnings via Direct Deposit (ACH / Stripe).',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: _showBankDetailsModal,
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('Link Bank Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
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
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'How GoChef Payouts Work',
                style: AppTextStyles.bodyLg(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPayoutStep(
            '1',
            'Cook & Complete Orders',
            'When you accept and finish customer orders, the earnings are credited immediately to your Available Balance.',
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
            'Tap "Cash Out Now" anytime to initiate an instant payout, or receive automatic transfers every Monday. Funds typically clear within 1Ã¢â‚¬â€œ3 business days.',
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
            color: AppColors.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(description, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.5, height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }

  // --- Cash Out Button Handler ---
  void _onCashOutTapped() {
    if (_kitchen == null || !_kitchen!.hasBankLinked) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
              ),
              child: const Text('Link Bank Now'),
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
          backgroundColor: AppColors.surface,
        ),
      );
      return;
    }

    // Show Confirmation Bottom Sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
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
                  color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildConfirmRow('Withdrawal Amount', '\$${_currentRevenue.toStringAsFixed(2)}', isBold: true, highlight: true),
                    const Divider(color: Colors.white12, height: 20),
                    _buildConfirmRow('Destination Bank', _kitchen!.bankName.isNotEmpty ? _kitchen!.bankName : 'Direct Deposit Bank'),
                    const SizedBox(height: 8),
                    _buildConfirmRow('Account Number', _kitchen!.maskedBankAccount),
                    const SizedBox(height: 8),
                    _buildConfirmRow('Account Holder', _kitchen!.bankAccountHolder.isNotEmpty ? _kitchen!.bankAccountHolder : _kitchen!.chefName),
                    const Divider(color: Colors.white12, height: 20),
                    _buildConfirmRow('Estimated Arrival', '1Ã¢â‚¬â€œ3 Business Days'),
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
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  ),
                  child: Text(
                    'Confirm & Cash Out \$${_currentRevenue.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  Widget _buildConfirmRow(String label, String value, {bool isBold = false, bool highlight = false, bool highlightGreen = false}) {
    Color valColor = Colors.white;
    if (highlight) valColor = AppColors.primary;
    if (highlightGreen) valColor = Colors.green;

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

  void _executeCashOutSuccess() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 18),
            const Text(
              'Payout Submitted! Ã°Å¸Å½â€°',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Your withdrawal of \$${_currentRevenue.toStringAsFixed(2)} has been queued for transfer to ${_kitchen?.bankName ?? "your bank"}. Standard ACH transfers arrive within 1Ã¢â‚¬â€œ3 business days.',
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Bank Account Link Modal ---
  void _showBankDetailsModal() {
    if (_kitchen == null) return;

    final bankNameController = TextEditingController(text: _kitchen!.bankName);
    final holderController = TextEditingController(text: _kitchen!.bankAccountHolder.isNotEmpty ? _kitchen!.bankAccountHolder : _kitchen!.chefName);
    final routingController = TextEditingController(text: _kitchen!.bankRoutingNumber);
    final accountController = TextEditingController(text: _kitchen!.bankAccountNumber);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
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
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
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
                    const SizedBox(height: 8),
                    Text(
                      'Provide your US checking or savings account details to receive direct deposits for your completed food orders.',
                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Bank Name
                    _buildBankTextField(
                      controller: bankNameController,
                      label: 'Bank Name',
                      hint: 'e.g. Chase, Bank of America, Wells Fargo',
                      icon: Icons.account_balance,
                    ),
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
                          final bName = bankNameController.text.trim();
                          final bHolder = holderController.text.trim();
                          final bRouting = routingController.text.trim();
                          final bAcc = accountController.text.trim();

                          if (bName.isEmpty || bHolder.isEmpty || bAcc.isEmpty || bRouting.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill in all bank details.')),
                            );
                            return;
                          }

                          setModalState(() => isSaving = true);

                          final success = await ApiService.updateKitchen({
                            'kitchen_id': _kitchen!.id,
                            'bank_name': bName,
                            'bank_account_holder': bHolder,
                            'bank_routing_number': bRouting,
                            'bank_account_number': bAcc,
                          });

                          setModalState(() => isSaving = false);

                          if (success && mounted) {
                            Navigator.pop(modalContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ã¢Å“â€¦ Direct deposit bank account saved successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _loadAll();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to update bank details. Please try again.')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: isSaving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                            : const Text('Save Bank Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
            prefixIcon: Icon(icon, color: Colors.white54, size: 20),
            filled: true,
            fillColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }

  // --- Transactions ---
  Widget _buildTransactionItem(String title, String date, String amount, bool isPositive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLg(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(date, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: AppTextStyles.bodyLg(color: isPositive ? Colors.green : Colors.red).copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
