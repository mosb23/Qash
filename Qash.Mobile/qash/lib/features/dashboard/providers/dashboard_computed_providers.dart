import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/currency/currency_providers.dart';
import '../../../core/errors/app_failure.dart';
import '../../analytics/utils/analytics_transaction_aggregation.dart';
import '../../transactions/providers/transactions_providers.dart';
import '../../wallets/domain/entities/wallet.dart';
import '../../wallets/providers/wallets_providers.dart';
import '../../wallets/utils/wallet_balance_utils.dart';
import '../domain/entities/dashboard.dart';


/// Top categories for the current month, computed with wallet-aware conversion.
final clientTopCategoriesProvider =
    Provider<AsyncValue<List<TopCategoryEntity>>>((ref) {
      final transactionsAsync = ref.watch(transactionsProvider);
      final walletsAsync = ref.watch(walletsProvider);
      final conversion = ref.watch(currencyConversionServiceProvider);
      final displayCurrency = ref.watch(effectiveDisplayCurrencyProvider);

      return transactionsAsync.when(
        data: (result) {
          if (result.isFailure) {
            return AsyncValue.error(
              result.failure ??
                  const AppFailure(message: 'Failed to load transactions.'),
              StackTrace.current,
            );
          }

          final walletsById = walletsAsync.maybeWhen(
            data: (walletResult) {
              if (walletResult.isFailure) {
                return const <String, WalletEntity>{};
              }
              return walletsByIdMap(walletResult.data ?? const []);
            },
            orElse: () => const <String, WalletEntity>{},
          );

          return AsyncValue.data(
            computeTopCategoriesFromTransactions(
              transactions: (result.data ?? const [])
                  .where(
                    (transaction) =>
                        !transaction.isTransfer && !transaction.isTransferLinked,
                  )
                  .toList(),
              displayCurrency: displayCurrency,
              conversion: conversion,
              walletsById: walletsById,
            ),
          );
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    });
