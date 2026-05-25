import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import 'delete_wallet_screen.dart';
import '../domain/entities/wallet.dart';
import '../providers/wallets_providers.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6F3),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: const Text(
          'Wallets',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4D93A),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => context.push('/wallets/create'),
                icon: const Icon(Icons.add, color: Colors.black),
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
                  style: const TextStyle(
                    color: Color(0xFF8B8B8B),
                    fontSize: 12,
                  ),
                );
              }
              final items = result.data ?? const [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryCard(items),
                  const SizedBox(height: 20),
                  if (items.isEmpty)
                    const Text(
                      'No wallets yet.',
                      style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
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
                      icon: const Icon(Icons.add, color: Color(0xFF8B8B8B)),
                      label: const Text(
                        'Add New Wallet',
                        style: TextStyle(
                          color: Color(0xFF8B8B8B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
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
              style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
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

  Widget _summaryCard(List<WalletEntity> wallets) {
    final total = wallets.fold<double>(
      0,
      (sum, wallet) => sum + wallet.balance,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Assets',
            style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${wallets.length} wallets',
            style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _walletCard(BuildContext context, WidgetRef ref, WalletEntity wallet) {
    return GestureDetector(
      onTap: () =>
          context.push('/wallets/${wallet.walletId}/edit', extra: wallet),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 2,
              offset: Offset(0, 1),
              spreadRadius: -1,
            ),
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 3,
              offset: Offset(0, 1),
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
              child: const Icon(Icons.account_balance_wallet_outlined),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.name,
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wallet.currency,
                    style: const TextStyle(
                      color: Color(0xFF8B8B8B),
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
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  wallet.currency,
                  style: const TextStyle(
                    color: Color(0xFF8B8B8B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFFB2C36)),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Coming soon.')));
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
