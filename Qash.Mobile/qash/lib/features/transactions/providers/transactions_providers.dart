import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/providers.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/transactions_remote_data_source.dart';
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

  if (normalizeTransactionId(item.walletId) == target) {
    return true;
  }

  final destinationId = item.toWalletId;
  if (destinationId != null && destinationId.isNotEmpty) {
    return normalizeTransactionId(destinationId) == target;
  }

  return false;
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
            items = items.where((item) => item.isIncome).toList();
          case TransactionFilter.expense:
            items = items.where((item) => item.isExpense).toList();
          case TransactionFilter.transfer:
            items = items.where((item) => item.isTransfer).toList();
          case TransactionFilter.all:
            break;
        }

        final walletId = listOptions.walletId;
        if (walletId != null && walletId.isNotEmpty) {
          items = items
              .where((item) => matchesWalletFilter(item, walletId))
              .toList();
        }

        return sortTransactions(items, listOptions.sort);
      });
    });

final transactionsSummaryProvider = Provider<AsyncValue<TransactionsSummary>>((
  ref,
) {
  final transactionsAsync = ref.watch(transactionsProvider);

  return transactionsAsync.whenData((result) {
    if (result.isFailure) {
      throw result.failure ??
          const AppFailure(message: 'Failed to load summary.');
    }

    final items = result.data ?? const [];
    var incomeTotal = 0.0;
    var expenseTotal = 0.0;

    for (final item in items) {
      if (item.isIncome) {
        incomeTotal += item.amount;
      } else if (item.isExpense) {
        expenseTotal += item.amount;
      }
    }

    return TransactionsSummary(
      incomeTotal: incomeTotal,
      expenseTotal: expenseTotal,
    );
  });
});
