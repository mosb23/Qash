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
import '../domain/usecases/update_transaction_use_case.dart';

enum TransactionFilter { all, income, expense, transfer }

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

final getTransactionByIdUseCaseProvider = Provider<GetTransactionByIdUseCase>((
  ref,
) {
  return GetTransactionByIdUseCase(ref.read(transactionsRepositoryProvider));
});

final createTransactionUseCaseProvider = Provider<CreateTransactionUseCase>((
  ref,
) {
  return CreateTransactionUseCase(ref.read(transactionsRepositoryProvider));
});

final updateTransactionUseCaseProvider = Provider<UpdateTransactionUseCase>((
  ref,
) {
  return UpdateTransactionUseCase(ref.read(transactionsRepositoryProvider));
});

final deleteTransactionUseCaseProvider = Provider<DeleteTransactionUseCase>((
  ref,
) {
  return DeleteTransactionUseCase(ref.read(transactionsRepositoryProvider));
});

final transactionsFilterProvider = StateProvider<TransactionFilter>((ref) {
  return TransactionFilter.all;
});

final transactionsSearchQueryProvider = StateProvider<String>((ref) => '');

final transactionsWalletFilterProvider = StateProvider<String?>((ref) => null);

final transactionsProvider = FutureProvider<Result<List<TransactionEntity>>>((
  ref,
) async {
  final useCase = ref.read(getTransactionsUseCaseProvider);
  return useCase();
});

final transactionDetailProvider = FutureProvider.family<
    Result<TransactionEntity>,
    String
>((ref, transactionId) async {
  final useCase = ref.read(getTransactionByIdUseCaseProvider);
  return useCase(transactionId);
});

List<TransactionEntity> _applyFilters({
  required List<TransactionEntity> items,
  required TransactionFilter filter,
  required String searchQuery,
  required String? walletFilterId,
}) {
  Iterable<TransactionEntity> filtered = items;

  switch (filter) {
    case TransactionFilter.income:
      filtered = filtered.where((item) => item.isIncome);
      break;
    case TransactionFilter.expense:
      filtered = filtered.where((item) => item.isExpense);
      break;
    case TransactionFilter.transfer:
      filtered = filtered.where((item) => item.isTransfer);
      break;
    case TransactionFilter.all:
      break;
  }

  if (walletFilterId != null && walletFilterId.isNotEmpty) {
    filtered = filtered.where(
      (item) =>
          item.walletId == walletFilterId ||
          item.toWalletId == walletFilterId,
    );
  }

  final query = searchQuery.trim().toLowerCase();
  if (query.isNotEmpty) {
    filtered = filtered.where((item) {
      final haystack = [
        item.description,
        item.categoryName,
        item.walletName,
        item.toWalletName,
        item.amount.toString(),
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    });
  }

  return filtered.toList();
}

final filteredTransactionsProvider =
    Provider<AsyncValue<List<TransactionEntity>>>((ref) {
      final transactionsAsync = ref.watch(transactionsProvider);
      final filter = ref.watch(transactionsFilterProvider);
      final searchQuery = ref.watch(transactionsSearchQueryProvider);
      final walletFilterId = ref.watch(transactionsWalletFilterProvider);

      return transactionsAsync.whenData((result) {
        if (result.isFailure) {
          throw result.failure ??
              const AppFailure(message: 'Failed to load transactions.');
        }

        final items = result.data ?? const [];
        return _applyFilters(
          items: items,
          filter: filter,
          searchQuery: searchQuery,
          walletFilterId: walletFilterId,
        );
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
