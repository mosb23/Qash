import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../core/currency/currency_conversion_service.dart';
import '../../../core/currency/currency_format.dart';
import '../../../core/providers/user_session_invalidation.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/transaction_category_icon.dart';
import '../../transactions/domain/entities/transaction.dart';
import '../../transactions/providers/transactions_providers.dart';
import '../../transactions/utils/transaction_wallet_display.dart';
import '../../transactions/utils/transfer_amount_utils.dart';
import '../utils/wallet_balance_utils.dart';
import '../domain/entities/wallet.dart';
import '../providers/wallets_providers.dart';
import 'delete_wallet_screen.dart';

class WalletDetailScreen extends ConsumerWidget {
  final WalletEntity wallet;

  const WalletDetailScreen({super.key, required this.wallet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsProvider);
    final exchangeRatesAsync = ref.watch(exchangeRatesProvider);
    final transactions = _resolveResultList<TransactionEntity>(
      ref.watch(transactionsProvider),
    );

    final wallets = walletsAsync.maybeWhen(
      data: (result) =>
          result.isFailure ? const <WalletEntity>[] : (result.data ?? const []),
      orElse: () => const <WalletEntity>[],
    );
    final walletsById = walletsByIdMap(wallets);
    final currentWallet = resolveLiveWallet(
      fallback: wallet,
      wallets: wallets.isEmpty ? [wallet] : wallets,
    );
    final exchangeRates = exchangeRatesAsync.maybeWhen(
      data: (rates) => defaultRatesOr(rates),
      orElse: () => defaultRatesOr(null),
    );

    final walletTransactions = _walletTransactions(
      transactions,
      currentWallet.walletId,
    );
    final displayBalance = adjustWalletBalanceForTransfers(
      wallet: currentWallet,
      walletTransactions: walletTransactions,
      walletsById: walletsById,
      exchangeRates: exchangeRates,
    );
    final summary = _walletSummary(
      walletTransactions,
      currentWallet.walletId,
      walletsById: walletsById,
      exchangeRates: exchangeRates,
    );

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
              onPressed: () => popOrGo(context, '/wallets'),
            ),
          ),
        ),
        title: Text(
          currentWallet.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _balanceCard(currentWallet, displayBalance),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _summaryTile(
                    label: 'Income',
                    value: _formatCurrencyWithSymbol(
                      summary.income,
                      currentWallet.currency,
                    ),
                    icon: Icons.arrow_downward,
                    iconBg: const Color(0xFFD9F0C8),
                    iconColor: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryTile(
                    label: 'Expenses',
                    value: _formatCurrencyWithSymbol(
                      summary.expenses,
                      currentWallet.currency,
                    ),
                    icon: Icons.arrow_upward,
                    iconBg: const Color(0xFFFFD3D4),
                    iconColor: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transactions',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/transactions'),
                  child: const Text(
                    'See all >',
                    style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (walletTransactions.isEmpty)
              const Text(
                'No transactions yet.',
                style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
              )
            else
              Column(
                children: [
                  for (final transaction in walletTransactions) ...[
                    _transactionCard(
                      transaction,
                      currentWallet.currency,
                      walletsById: walletsById,
                      exchangeRates: exchangeRates,
                      walletId: currentWallet.walletId,
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _confirmDelete(context, ref, currentWallet),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFFB2C36),
                ),
                label: const Text(
                  'Delete Wallet',
                  style: TextStyle(
                    color: Color(0xFFFB2C36),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFECACA)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _balanceCard(WalletEntity wallet, double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            wallet.currency.toUpperCase(),
            style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrencyWithSymbol(balance, wallet.currency),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile({
    required String label,
    required String value,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionCard(
    TransactionEntity item,
    String currencyCode, {
    required String walletId,
    required Map<String, WalletEntity> walletsById,
    required Map<String, double> exchangeRates,
  }) {
    final display = walletTransactionDisplay(
      item,
      walletId: walletId,
      fallbackCurrency: currencyCode,
      walletsById: walletsById,
      exchangeRates: exchangeRates,
    );
    final isTransfer = item.isTransfer || item.isTransferLinked;
    final amountSign = display.sign;
    final amountColor = amountSign == '-'
        ? const Color(0xFFFF0000)
        : const Color(0xFF00A63E);
    final iconBg = isTransfer
        ? const Color(0xFFE1EBFF)
        : item.isIncome
        ? const Color(0xFFD9F0C8)
        : const Color(0xFFFFD3D4);
    final transferContext = _transferContextText(
      item: item,
      walletId: walletId,
      walletsById: walletsById,
      display: display,
    );

    return Container(
      padding: const EdgeInsets.all(14),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              TransactionCategoryIcon(
                categoryName: item.categoryName,
                categoryIcon: item.categoryName,
                isTransfer: item.isTransfer,
                backgroundColor: iconBg,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (item.description?.isNotEmpty == true)
                        ? item.description!
                        : item.categoryName,
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatDate(item.transactionDate),
                    style: const TextStyle(
                      color: Color(0xFF8B8B8B),
                      fontSize: 12,
                    ),
                  ),
                  if (transferContext != null)
                    Text(
                      transferContext,
                      style: const TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 12,
                      ),
                    ),
                  if (display.exchangeRateText != null)
                    Text(
                      display.exchangeRateText!,
                      style: const TextStyle(
                        color: Color(0xFF8B8B8B),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ],
          ),
          Text(
            '$amountSign${formatMoney(display.amount, display.currencyCode)}',
            style: TextStyle(
              color: amountColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
          onDelete: () => _deleteWallet(context, pageContext, ref, wallet),
          onCancel: () => Navigator.of(pageContext).pop(),
        ),
      ),
    );
  }

  Future<void> _deleteWallet(
    BuildContext detailContext,
    BuildContext deleteContext,
    WidgetRef ref,
    WalletEntity wallet,
  ) async {
    final result = await ref.read(deleteWalletUseCaseProvider)(wallet.walletId);

    if (result.isSuccess) {
      invalidateTransactionRelatedData(ref);

      if (deleteContext.mounted) {
        Navigator.of(deleteContext).pop();
      }

      if (detailContext.mounted) {
        GoRouter.of(detailContext).go('/wallets');
      }
      return;
    }

    if (!deleteContext.mounted) return;

    final message = result.message.isNotEmpty
        ? result.message
        : 'Failed to delete wallet.';
    ScaffoldMessenger.of(deleteContext).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<TransactionEntity> _walletTransactions(
    AsyncValue<List<TransactionEntity>> transactions,
    String walletId,
  ) {
    return transactions.maybeWhen(
      data: (items) {
        final filtered =
            items
                .where(
                  (item) =>
                      transactionInvolvesWallet(item, walletId),
                )
                .toList()
              ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        return filtered;
      },
      orElse: () => const [],
    );
  }

  _WalletSummary _walletSummary(
    List<TransactionEntity> items,
    String walletId, {
    required Map<String, WalletEntity> walletsById,
    required Map<String, double> exchangeRates,
  }) {
    var income = 0.0;
    var expenses = 0.0;
    final conversion = CurrencyConversionService(exchangeRates);

    for (final item in items) {
      if (item.isTransfer) {
        if (isIncomingTransferToWallet(item, walletId)) {
          income += resolveTransferCreditAmount(
            item,
            walletsById: walletsById,
            conversion: conversion,
          );
        } else if (isOutgoingTransferFromWallet(item, walletId)) {
          expenses += resolveTransferDebitAmount(
            item,
            walletsById: walletsById,
          );
        }
        continue;
      }

      if (item.isIncome) {
        income += item.amount;
      } else if (item.isExpense) {
        expenses += item.amount;
      }
    }

    return _WalletSummary(income: income, expenses: expenses);
  }

  AsyncValue<List<T>> _resolveResultList<T>(AsyncValue<dynamic> value) {
    return value.whenData((result) {
      if (result.isFailure) {
        throw result.failure ??
            const AppFailure(message: 'Failed to load data.');
      }
      return (result.data as List<T>?) ?? const [];
    });
  }

  String _formatCurrencyWithSymbol(double value, String currencyCode) {
    final symbol = _currencySymbol(currencyCode);
    return NumberFormat.currency(symbol: symbol).format(value);
  }

  String _currencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '\u20ac';
      case 'GBP':
        return '\u00a3';
      case 'EGP':
        return 'E£';
      case 'JPY':
        return '\u00a5';
      default:
        return currencyCode.isNotEmpty ? currencyCode.substring(0, 1) : '\$';
    }
  }

  String _formatDate(DateTime value) {
    return DateFormat('yyyy-MM-dd').format(value);
  }

  String? _transferContextText({
    required TransactionEntity item,
    required String walletId,
    required Map<String, WalletEntity> walletsById,
    required WalletTransactionDisplay display,
  }) {
    if (!item.isTransfer) {
      return null;
    }

    final normalizedWalletId = normalizeTransactionId(walletId);
    final sourceWalletName = walletsById[normalizeTransactionId(item.walletId)]?.name ??
        item.walletName;
    final destinationWalletId = item.toWalletId;
    final destinationWalletName = destinationWalletId == null
        ? (item.toWalletName ?? '')
        : (walletsById[normalizeTransactionId(destinationWalletId)]?.name ??
            (item.toWalletName ?? ''));
    final sourceCurrency = (item.sourceCurrency.isNotEmpty
            ? item.sourceCurrency
            : item.walletCurrency)
        .trim()
        .toUpperCase();
    final destinationCurrency =
        (item.destinationCurrency ?? item.toWalletCurrency ?? '')
            .trim()
            .toUpperCase();

    final sourceMatch = normalizeTransactionId(item.walletId) == normalizedWalletId;
    if (sourceMatch) {
      final targetCurrencyText = destinationCurrency.isNotEmpty
          ? destinationCurrency
          : display.currencyCode;
      final receivedText = item.toAmount != null
          ? formatMoney(item.toAmount!, targetCurrencyText)
          : formatMoney(display.amount, display.currencyCode);
      return 'To $destinationWalletName · Receives $receivedText';
    }

    final destinationMatch = destinationWalletId != null &&
        normalizeTransactionId(destinationWalletId) == normalizedWalletId;
    if (destinationMatch) {
      final sentText = formatMoney(item.amount, sourceCurrency);
      return 'From $sourceWalletName · Sent $sentText';
    }

    return null;
  }
}

class _WalletSummary {
  final double income;
  final double expenses;

  const _WalletSummary({required this.income, required this.expenses});
}
