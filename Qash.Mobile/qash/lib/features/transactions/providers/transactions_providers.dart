import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/providers.dart';
import '../../../core/currency/currency_aggregation.dart';
import '../../../core/currency/currency_providers.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/utils/result.dart';
import '../../wallets/domain/entities/wallet.dart';
import '../../wallets/providers/wallets_providers.dart';
import '../../wallets/utils/wallet_balance_utils.dart';
import '../data/datasources/transactions_remote_data_source.dart';
import '../data/exchange_rates_api.dart';
import '../data/transactions_api.dart';
import '../data/repositories/transactions_repository_impl.dart';
import '../domain/entities/transaction.dart';
import '../domain/repositories/transactions_repository.dart';
import '../domain/usecases/create_transaction_use_case.dart';
import '../domain/usecases/delete_transaction_use_case.dart';
import '../domain/usecases/get_transaction_by_id_use_case.dart';
import '../domain/usecases/get_transactions_use_case.dart';

enum TransactionFilter { all, income, expense, transfer }

enum TransactionListSort {
  dateNewest,
  dateOldest,
  amountLowToHigh,
  amountHighToLow,
}

class TransactionListOptions {
  final TransactionListSort sort;
  final String? walletId;

  const TransactionListOptions({
    this.sort = TransactionListSort.dateNewest,
    this.walletId,
  });

  bool get hasActiveFilters =>
      sort != TransactionListSort.dateNewest || walletId != null;

  TransactionListOptions copyWith({
    TransactionListSort? sort,
    String? walletId,
    bool clearWallet = false,
  }) {
    return TransactionListOptions(
      sort: sort ?? this.sort,
      walletId: clearWallet ? null : (walletId ?? this.walletId),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TransactionListOptions &&
            other.sort == sort &&
            other.walletId == walletId;
  }

  @override
  int get hashCode => Object.hash(sort, walletId);
}

String normalizeTransactionId(String? id) {
  if (id == null || id.isEmpty) {
    return '';
  }
  return id.replaceAll('{', '').replaceAll('}', '').trim().toLowerCase();
}

DateTime transactionLocalDate(DateTime date) {
  final local = date.isUtc ? date.toLocal() : date;
  return DateTime(local.year, local.month, local.day);
}

int compareTransactionDatesDesc(TransactionEntity a, TransactionEntity b) {
  final dateCompare = b.transactionDate.compareTo(a.transactionDate);
  if (dateCompare != 0) {
    return dateCompare;
  }
  return b.id.compareTo(a.id);
}

int compareTransactionDatesAsc(TransactionEntity a, TransactionEntity b) {
  final dateCompare = a.transactionDate.compareTo(b.transactionDate);
  if (dateCompare != 0) {
    return dateCompare;
  }
  return a.id.compareTo(b.id);
}

int compareTransactionAmountsAsc(TransactionEntity a, TransactionEntity b) {
  final amountCompare = a.amount.compareTo(b.amount);
  if (amountCompare != 0) {
    return amountCompare;
  }
  return compareTransactionDatesDesc(a, b);
}

int compareTransactionAmountsDesc(TransactionEntity a, TransactionEntity b) {
  final amountCompare = b.amount.compareTo(a.amount);
  if (amountCompare != 0) {
    return amountCompare;
  }
  return compareTransactionDatesDesc(a, b);
}

class TransactionsSummary {
  final double incomeTotal;
  final double expenseTotal;

  const TransactionsSummary({
    required this.incomeTotal,
    required this.expenseTotal,
  });
}

final transactionsRemoteDataSourceProvider =
    Provider<TransactionsRemoteDataSource>((ref) {
      return TransactionsApi(ref.read(dioProvider));
    });

final exchangeRatesApiProvider = Provider<ExchangeRatesApi>((ref) {
  return ExchangeRatesApi(ref.read(dioProvider));
});

final exchangeRatesProvider = FutureProvider<Map<String, double>>((ref) async {
  return ref.read(exchangeRatesApiProvider).fetchRates();
});

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepositoryImpl(
    ref.read(transactionsRemoteDataSourceProvider),
    ref.read(secureStorageProvider),
  );
});

final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>((ref) {
  return GetTransactionsUseCase(ref.read(transactionsRepositoryProvider));
});

final getTransactionByIdUseCaseProvider =
    Provider<GetTransactionByIdUseCase>((ref) {
  return GetTransactionByIdUseCase(ref.read(transactionsRepositoryProvider));
});

final createTransactionUseCaseProvider = Provider<CreateTransactionUseCase>((
  ref,
) {
  return CreateTransactionUseCase(ref.read(transactionsRepositoryProvider));
});

final deleteTransactionUseCaseProvider = Provider<DeleteTransactionUseCase>((
  ref,
) {
  return DeleteTransactionUseCase(ref.read(transactionsRepositoryProvider));
});

final transactionDetailProvider = FutureProvider.autoDispose
    .family<Result<TransactionEntity>, String>((ref, transactionId) async {
  final useCase = ref.read(getTransactionByIdUseCaseProvider);
  return useCase(transactionId);
});

final transactionsFilterProvider = StateProvider<TransactionFilter>((ref) {
  return TransactionFilter.all;
});

final transactionListOptionsProvider =
    StateProvider<TransactionListOptions>((ref) {
      return const TransactionListOptions();
    });

final transactionsProvider = FutureProvider<Result<List<TransactionEntity>>>((
  ref,
) async {
  final useCase = ref.read(getTransactionsUseCaseProvider);
  return useCase();
});

bool matchesWalletFilter(TransactionEntity item, String walletId) {
  final target = normalizeTransactionId(walletId);
  if (target.isEmpty) {
    return false;
  }

  final sourceMatch = normalizeTransactionId(item.walletId) == target;
  final destinationMatch =
      item.toWalletId != null &&
      item.toWalletId!.isNotEmpty &&
      normalizeTransactionId(item.toWalletId) == target;

  if (item.isTransfer || item.isTransferLinked) {
    // For a wallet-specific view, keep only one transfer leg:
    // source wallet sees outgoing, destination wallet sees incoming.
    if (item.isTransferLinked) {
      return sourceMatch;
    }

    if (!item.isTransfer) {
      return false;
    }

    return sourceMatch || destinationMatch;
  }

  return sourceMatch;
}

List<TransactionEntity> sortTransactions(
  List<TransactionEntity> items,
  TransactionListSort sort,
) {
  final sorted = List<TransactionEntity>.from(items);
  switch (sort) {
    case TransactionListSort.dateNewest:
      sorted.sort(compareTransactionDatesDesc);
    case TransactionListSort.dateOldest:
      sorted.sort(compareTransactionDatesAsc);
    case TransactionListSort.amountLowToHigh:
      sorted.sort(compareTransactionAmountsAsc);
    case TransactionListSort.amountHighToLow:
      sorted.sort(compareTransactionAmountsDesc);
  }
  return sorted;
}

final filteredTransactionsProvider =
    Provider<AsyncValue<List<TransactionEntity>>>((ref) {
      final transactionsAsync = ref.watch(transactionsProvider);
      final filter = ref.watch(transactionsFilterProvider);
      final listOptions = ref.watch(transactionListOptionsProvider);

      return transactionsAsync.whenData((result) {
        if (result.isFailure) {
          throw result.failure ??
              const AppFailure(message: 'Failed to load transactions.');
        }

        var items = result.data ?? const [];
        switch (filter) {
          case TransactionFilter.income:
            items = items
                .where((item) => item.isIncome && !item.isTransferLinked)
                .toList();
          case TransactionFilter.expense:
            items = items
                .where((item) => item.isExpense && !item.isTransferLinked)
                .toList();
          case TransactionFilter.transfer:
            items = items
                .where((item) => item.isTransfer || item.isTransferLinked)
                .toList();
          case TransactionFilter.all:
            break;
        }

        final walletId = listOptions.walletId;
        if (walletId != null && walletId.isNotEmpty) {
          items = items
              .where((item) => matchesWalletFilter(item, walletId))
              .toList();
          items = _dedupeTransferLegs(items);
        }

        return sortTransactions(items, listOptions.sort);
      });
    });

final transactionsSummaryProvider = Provider<AsyncValue<TransactionsSummary>>((
  ref,
) {
  final transactionsAsync = ref.watch(transactionsProvider);
  final walletsAsync = ref.watch(walletsProvider);
  final conversion = ref.watch(currencyConversionServiceProvider);
  final displayCurrency = ref.watch(effectiveDisplayCurrencyProvider);

  return transactionsAsync.whenData((result) {
    if (result.isFailure) {
      throw result.failure ??
          const AppFailure(message: 'Failed to load summary.');
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

    final items = result.data ?? const [];
    var incomeTotal = 0.0;
    var expenseTotal = 0.0;

    for (final item in items) {
      final converted = convertTransactionAmount(
        transaction: item,
        targetCurrency: displayCurrency,
        conversion: conversion,
        walletsById: walletsById,
      );

      if (item.isTransfer) {
        expenseTotal += converted;
      } else if (item.isIncome) {
        incomeTotal += converted;
      } else if (item.isExpense) {
        expenseTotal += converted;
      }
    }

    return TransactionsSummary(
      incomeTotal: incomeTotal,
      expenseTotal: expenseTotal,
    );
  });
});

List<TransactionEntity> _dedupeTransferLegs(List<TransactionEntity> items) {
  final grouped = <String, List<TransactionEntity>>{};
  final withoutGroup = <TransactionEntity>[];

  for (final item in items) {
    final groupId = item.transferGroupId?.trim();
    if (groupId == null || groupId.isEmpty) {
      withoutGroup.add(item);
      continue;
    }
    grouped.putIfAbsent(groupId, () => []).add(item);
  }

  final deduped = <TransactionEntity>[...withoutGroup];
  for (final groupItems in grouped.values) {
    TransactionEntity? preferred;
    for (final candidate in groupItems) {
      if (candidate.isTransfer) {
        preferred = candidate;
        break;
      }
    }
    deduped.add(preferred ?? groupItems.first);
  }

  return deduped;
}
