import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qash/core/theme/qash_theme_extension.dart';
import 'package:qash/core/utils/currency_formatter.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/utils/result.dart';
import '../../dashboard/providers/home_preferences_provider.dart';
import '../../wallets/domain/entities/wallet.dart';
import '../../wallets/providers/wallets_providers.dart';
import '../domain/entities/transaction.dart';
import '../providers/transactions_providers.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qash = context.qash;
    final displayCurrency = ref.watch(displayCurrencyProvider);
    final wallets = ref.watch(walletsProvider);
    final detail = ref.watch(transactionDetailProvider(transactionId));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: qash.surface,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: qash.cardShadow,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: qash.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Transaction Details',
                    style: TextStyle(
                      color: qash.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: detail.when(
                data: (result) {
                  if (result.isFailure) {
                    return Center(
                      child: Text(
                        result.failure?.message ?? 'Failed to load transaction.',
                        style: TextStyle(color: qash.textSecondary),
                      ),
                    );
                  }
                  final item = result.data;
                  if (item == null) {
                    return Center(
                      child: Text(
                        'Transaction not found.',
                        style: TextStyle(color: qash.textSecondary),
                      ),
                    );
                  }
                  return _detailBody(
                    context,
                    item,
                    displayCurrency,
                    wallets,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text(
                    error is AppFailure
                        ? error.message
                        : 'Failed to load transaction.',
                    style: TextStyle(color: qash.textSecondary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailBody(
    BuildContext context,
    TransactionEntity item,
    String displayCurrency,
    AsyncValue<Result<List<WalletEntity>>> wallets,
  ) {
    final qash = context.qash;
    final dateFormat = DateFormat('MMM d, yyyy · h:mm a');
    final amountCurrency = wallets.maybeWhen(
      data: (result) {
        final list = result.data ?? const [];
        for (final wallet in list) {
          if (wallet.walletId == item.walletId) {
            return wallet.currency;
          }
        }
        return displayCurrency;
      },
      orElse: () => displayCurrency,
    );

    final rows = <MapEntry<String, String>>[
      MapEntry('Type', _typeLabel(item)),
      MapEntry(
        'Amount',
        CurrencyFormatter.format(item.amount, amountCurrency),
      ),
      MapEntry('Description', item.description),
      if (item.categoryName.isNotEmpty)
        MapEntry('Category', item.categoryName),
      MapEntry('From wallet', item.walletName),
      if (item.isTransfer && item.toWalletName.isNotEmpty)
        MapEntry('To wallet', item.toWalletName),
      MapEntry('Date', dateFormat.format(item.transactionDate)),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final row in rows) ...[
            Text(
              row.key,
              style: TextStyle(
                color: qash.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: qash.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: qash.cardShadow,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                row.value,
                style: TextStyle(
                  color: qash.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  String _typeLabel(TransactionEntity item) {
    if (item.isTransfer) {
      return 'Transfer';
    }
    if (item.isIncome) {
      return 'Income';
    }
    return 'Expense';
  }
}
