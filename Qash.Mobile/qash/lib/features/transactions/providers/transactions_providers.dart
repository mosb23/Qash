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
import '../domain/usecases/get_transactions_use_case.dart';

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

final createTransactionUseCaseProvider = Provider<CreateTransactionUseCase>((
  ref,
) {
  return CreateTransactionUseCase(ref.read(transactionsRepositoryProvider));
});

final transactionsFilterProvider = StateProvider<TransactionFilter>((ref) {
  return TransactionFilter.all;
});

final transactionsProvider = FutureProvider<Result<List<TransactionEntity>>>((
  ref,
) async {
  final useCase = ref.read(getTransactionsUseCaseProvider);
  return useCase();
});

final filteredTransactionsProvider =
    Provider<AsyncValue<List<TransactionEntity>>>((ref) {
      final transactionsAsync = ref.watch(transactionsProvider);
      final filter = ref.watch(transactionsFilterProvider);

      return transactionsAsync.whenData((result) {
        if (result.isFailure) {
          throw result.failure ??
              const AppFailure(message: 'Failed to load transactions.');
        }

        final items = result.data ?? const [];
        switch (filter) {
          case TransactionFilter.income:
            return items.where((item) => item.isIncome).toList();
          case TransactionFilter.expense:
            return items.where((item) => item.isExpense).toList();
          case TransactionFilter.transfer:
            return items.where((item) => item.isTransfer).toList();
          case TransactionFilter.all:
            return items;
        }
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
