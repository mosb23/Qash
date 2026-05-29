import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/utils/result.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../wallets/domain/entities/wallet.dart';
import '../../wallets/providers/wallets_providers.dart';
import '../domain/entities/transaction.dart';
import '../providers/transactions_providers.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(transactionDetailProvider(transactionId));
    final walletsAsync = ref.watch(walletsProvider);

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
          'Transaction',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentTab: AppTab.transactions,
        onSelected: (tab) => _onTabSelected(context, tab),
      ),
      body: detailAsync.when(
        data: (result) {
          if (result.isFailure) {
            return _messageState(
              result.message.isNotEmpty
                  ? result.message
                  : 'Failed to load transaction.',
            );
          }

          final transaction = result.data;
          if (transaction == null) {
            return _messageState('Transaction not found.');
          }

          final currency = _resolveCurrency(
            transaction.walletId,
            walletsAsync,
          );

          return _TransactionDetailBody(
            transaction: transaction,
            currency: currency,
            transactionId: transactionId,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _messageState(
          error is AppFailure ? error.message : 'Failed to load transaction.',
        ),
      ),
    );
  }

  Widget _messageState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 14),
        ),
      ),
    );
  }

  String _resolveCurrency(
    String walletId,
    AsyncValue<Result<List<WalletEntity>>> walletsAsync,
  ) {
    return walletsAsync.maybeWhen(
      data: (result) {
        if (result.isFailure) {
          return 'USD';
        }
        final wallets = result.data ?? const <WalletEntity>[];
        final target = normalizeTransactionId(walletId);
        for (final wallet in wallets) {
          if (normalizeTransactionId(wallet.walletId) == target) {
            return wallet.currency;
          }
        }
        return 'USD';
      },
      orElse: () => 'USD',
    );
  }

  void _onTabSelected(BuildContext context, AppTab tab) {
    switch (tab) {
      case AppTab.home:
        context.go('/home');
      case AppTab.transactions:
        context.go('/transactions');
      case AppTab.analytics:
        context.go('/analytics');
      case AppTab.goals:
        context.go('/goals');
      case AppTab.profile:
        context.go('/profile');
    }
  }
}

class _TransactionDetailBody extends StatelessWidget {
  const _TransactionDetailBody({
    required this.transaction,
    required this.currency,
    required this.transactionId,
  });

  final TransactionEntity transaction;
  final String currency;
  final String transactionId;

  TransactionStyle get _style => TransactionStyle.from(transaction);

  @override
  Widget build(BuildContext context) {
    final title = transaction.description.isNotEmpty
        ? transaction.description
        : transaction.categoryName;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: _style.summaryBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _style.icon,
                    color: _style.accent,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${_style.amountPrefix}${_formatCurrency(transaction.amount)}',
                  style: TextStyle(
                    color: _style.accent,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF8B8B8B),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
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
            child: Column(
              children: [
                _detailRow('Type', _style.typeLabel, valueColor: _style.accent),
                _divider(),
                _detailRow('Category', transaction.categoryName),
                _divider(),
                _detailRow('Wallet', _walletLabel(transaction)),
                _divider(),
                _detailRow('Date', _formatLongDate(transaction.transactionDate)),
                _divider(),
                _detailRow('Currency', _currencyLabel(currency)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () =>
                  context.push('/transactions/$transactionId/delete'),
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              label: const Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFFFE8E8),
                side: const BorderSide(color: Color(0xFFFECACA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, color: Color(0xFFF3F4F6));
  }

  Widget _detailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8B8B8B),
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? const Color(0xFF111111),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _walletLabel(TransactionEntity transaction) {
    if (transaction.isTransfer &&
        transaction.toWalletName != null &&
        transaction.toWalletName!.isNotEmpty) {
      return '${transaction.walletName} → ${transaction.toWalletName}';
    }
    return transaction.walletName;
  }

  String _currencyLabel(String currency) {
    final code = currency.toUpperCase();
    if (code == 'USD') {
      return 'USD (\$)';
    }
    if (code == 'EUR') {
      return 'EUR (€)';
    }
    if (code == 'EGP') {
      return 'EGP (E£)';
    }
    return code;
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(symbol: '\$').format(value);
  }

  String _formatLongDate(DateTime value) {
    return DateFormat('EEEE, MMMM d, yyyy').format(value);
  }
}

class TransactionStyle {
  final Color summaryBackground;
  final Color accent;
  final String typeLabel;
  final String amountPrefix;
  final IconData icon;

  const TransactionStyle({
    required this.summaryBackground,
    required this.accent,
    required this.typeLabel,
    required this.amountPrefix,
    required this.icon,
  });

  factory TransactionStyle.from(TransactionEntity transaction) {
    if (transaction.isIncome) {
      return const TransactionStyle(
        summaryBackground: Color(0xFFE8F7ED),
        accent: Color(0xFF00A63E),
        typeLabel: 'Income',
        amountPrefix: '+',
        icon: Icons.arrow_downward_rounded,
      );
    }
    if (transaction.isTransfer) {
      return const TransactionStyle(
        summaryBackground: Color(0xFFE1EBFF),
        accent: Color(0xFF2B7FFF),
        typeLabel: 'Transfer',
        amountPrefix: '',
        icon: Icons.swap_horiz_rounded,
      );
    }
    return const TransactionStyle(
      summaryBackground: Color(0xFFFFE8E8),
      accent: Color(0xFFFF0000),
      typeLabel: 'Expense',
      amountPrefix: '-',
      icon: Icons.arrow_upward_rounded,
    );
  }
}
