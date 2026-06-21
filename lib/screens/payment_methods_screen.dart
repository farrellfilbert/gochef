import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Methods',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Primary E-Wallet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentCard(
            title: 'GoChef Pay',
            subtitle: 'Balance: Rp 450.000',
            icon: LucideIcons.wallet,
            isPrimary: true,
          ),
          const SizedBox(height: 32),
          const Text(
            'Credit / Debit Card',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentCard(
            title: 'Mastercard',
            subtitle: '**** **** **** 1234',
            icon: LucideIcons.creditCard,
            isPrimary: false,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppTheme.fuchsiaPrimary,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text('Add Method', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPaymentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isPrimary
            ? const LinearGradient(
                colors: [Color(0xFF2A2D3E), Color(0xFF1E1F2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPrimary ? null : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPrimary ? AppTheme.fuchsiaPrimary.withValues(alpha: 0.5) : AppTheme.surfaceLight,
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPrimary ? AppTheme.fuchsiaPrimary.withValues(alpha: 0.2) : AppTheme.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isPrimary ? AppTheme.fuchsiaPrimary : AppTheme.textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isPrimary ? AppTheme.fuchsiaPrimary : AppTheme.textSecondary,
                    fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (isPrimary)
            const Icon(LucideIcons.checkCircle2, color: AppTheme.fuchsiaPrimary)
          else
            IconButton(
              icon: const Icon(LucideIcons.moreVertical, color: AppTheme.textSecondary),
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}
