import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import 'delete_wallet_screen.dart';
import '../domain/entities/wallet.dart';
import '../providers/wallets_providers.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qash = context.qash;
    final wallets = ref.watch(walletsProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: qash.surface,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: qash.textPrimary),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: Text(
          'Wallets',
          style: TextStyle(
            color: qash.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: qash.accent,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => context.push('/wallets/create'),
                icon: Icon(Icons.add, color: qash.onAccent),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: wallets.when(
            data: (result) {
              if (result.isFailure) {
                return Text(
                  result.message,
                  style: TextStyle(
                    color: qash.textSecondary,
                    fontSize: 12,
                  ),
                );
              }
              final items = result.data ?? const [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryCard(context, items),
                  const SizedBox(height: 20),
                  if (items.isEmpty)
                    Text(
                      'No wallets yet.',
                      style: TextStyle(color: qash.textSecondary, fontSize: 12),
                    )
                  else
                    for (final wallet in items) ...[
                      _walletCard(context, ref, wallet),
                      const SizedBox(height: 12),
                    ],
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/wallets/create'),
                      icon: Icon(Icons.add, color: qash.textSecondary),
                      label: Text(
                        'Add New Wallet',
                        style: TextStyle(
                          color: qash.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: qash.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Text(
              _errorText(error),
              style: TextStyle(color: qash.textSecondary, fontSize: 12),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentTab: AppTab.home,
        onSelected: (tab) => _onTabSelected(context, tab),
      ),
    );
  }

  Widget _summaryCard(BuildContext context, List<WalletEntity> wallets) {
    final qash = context.qash;
    final total = wallets.fold<double>(
      0,
      (sum, wallet) => sum + wallet.balance,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: qash.primaryButton,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Assets',
            style: TextStyle(color: qash.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(total),
            style: TextStyle(
              color: qash.onPrimaryButton,
              fontSize: 30,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${wallets.length} wallets',
            style: TextStyle(color: qash.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _walletCard(BuildContext context, WidgetRef ref, WalletEntity wallet) {
    final qash = context.qash;
    return GestureDetector(
      onTap: () =>
          context.push('/wallets/${wallet.walletId}/edit', extra: wallet),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: qash.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: qash.cardShadow,
              blurRadius: 2,
              offset: const Offset(0, 1),
              spreadRadius: -1,
            ),
            BoxShadow(
              color: qash.cardShadow,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.account_balance_wallet_outlined,
                  color: qash.textPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.name,
                    style: TextStyle(
                      color: qash.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wallet.currency,
                    style: TextStyle(
                      color: qash.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(wallet.balance),
                  style: TextStyle(
                    color: qash.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  wallet.currency,
                  style: TextStyle(
                    color: qash.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.delete_outline, color: qash.danger),
              onPressed: () => _confirmDelete(context, ref, wallet),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    WalletEntity wallet,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (pageContext) => DeleteWalletScreen(
          walletName: wallet.name,
          onDelete: () => _deleteWallet(pageContext, ref, wallet),
          onCancel: () => Navigator.of(pageContext).pop(),
        ),
      ),
    );
  }

  Future<void> _deleteWallet(
    BuildContext context,
    WidgetRef ref,
    WalletEntity wallet,
  ) async {
    final result = await ref.read(deleteWalletUseCaseProvider)(wallet.walletId);
    if (!context.mounted) return;

    if (result.isSuccess) {
      ref.invalidate(walletsProvider);
      Navigator.of(context).pop();
      return;
    }

    final message = result.message.isNotEmpty
        ? result.message
        : 'Failed to delete wallet.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onTabSelected(BuildContext context, AppTab tab) {
    switch (tab) {
      case AppTab.home:
        context.go('/home');
        return;
      case AppTab.transactions:
        context.go('/transactions');
        return;
      case AppTab.analytics:
        context.go('/analytics');
        return;
      case AppTab.goals:
        context.go('/goals');
        return;
      case AppTab.profile:
        context.go('/profile');
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(symbol: '\$').format(value);
  }

  String _errorText(Object error) {
    if (error is AppFailure) {
      return error.message;
    }
    return 'Failed to load wallets.';
  }
}
