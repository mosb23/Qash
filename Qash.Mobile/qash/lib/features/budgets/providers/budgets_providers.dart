import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/providers.dart';
import '../../../core/currency/currency_aggregation.dart';
import '../../../core/currency/currency_providers.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/utils/result.dart';
import '../../transactions/providers/transactions_providers.dart';
import '../../wallets/providers/wallets_providers.dart';
import '../../wallets/utils/wallet_balance_utils.dart';
import '../data/budgets_api.dart';
import '../data/datasources/budgets_remote_data_source.dart';
import '../data/repositories/budgets_repository_impl.dart';
import '../domain/entities/budget_status.dart';
import '../domain/repositories/budgets_repository.dart';
import '../domain/usecases/create_budget_use_case.dart';
import '../domain/usecases/delete_budget_use_case.dart';
import '../domain/usecases/get_budget_statuses_use_case.dart';

final budgetPeriodProvider = Provider<BudgetPeriod>((ref) {
  final now = DateTime.now();
  return BudgetPeriod(year: now.year, month: now.month);
});

final budgetsRemoteDataSourceProvider = Provider<BudgetsRemoteDataSource>((
  ref,
) {
  return BudgetsApi(ref.read(dioProvider));
});

final budgetsRepositoryProvider = Provider<BudgetsRepository>((ref) {
  return BudgetsRepositoryImpl(ref.read(budgetsRemoteDataSourceProvider));
});

final getBudgetStatusesUseCaseProvider = Provider<GetBudgetStatusesUseCase>((
  ref,
) {
  return GetBudgetStatusesUseCase(ref.read(budgetsRepositoryProvider));
});

final createBudgetUseCaseProvider = Provider<CreateBudgetUseCase>((ref) {
  return CreateBudgetUseCase(ref.read(budgetsRepositoryProvider));
});

final deleteBudgetUseCaseProvider = Provider<DeleteBudgetUseCase>((ref) {
  return DeleteBudgetUseCase(ref.read(budgetsRepositoryProvider));
});

final budgetStatusesProvider = FutureProvider<Result<List<BudgetStatusEntity>>>(
  (ref) async {
    final useCase = ref.read(getBudgetStatusesUseCaseProvider);
    final period = ref.watch(budgetPeriodProvider);
    return useCase(period);
  },
);

/// Recomputes spent amounts client-side using wallet currencies (fixes stale API metadata).
final adjustedBudgetStatusesProvider =
    Provider<AsyncValue<List<BudgetStatusEntity>>>((ref) {
      final budgetsAsync = ref.watch(budgetStatusesProvider);
      final transactionsAsync = ref.watch(transactionsProvider);
      final walletsAsync = ref.watch(walletsProvider);
      final conversion = ref.watch(currencyConversionServiceProvider);

      if (budgetsAsync.isLoading ||
          transactionsAsync.isLoading ||
          walletsAsync.isLoading) {
        return const AsyncValue.loading();
      }

      if (budgetsAsync.hasError) {
        return AsyncValue.error(budgetsAsync.error!, budgetsAsync.stackTrace!);
      }
      if (transactionsAsync.hasError) {
        return AsyncValue.error(
          transactionsAsync.error!,
          transactionsAsync.stackTrace!,
        );
      }
      if (walletsAsync.hasError) {
        return AsyncValue.error(walletsAsync.error!, walletsAsync.stackTrace!);
      }

      final budgetResult = budgetsAsync.value;
      final transactionResult = transactionsAsync.value;
      final walletResult = walletsAsync.value;

      if (budgetResult == null ||
          budgetResult.isFailure ||
          transactionResult == null ||
          transactionResult.isFailure) {
        return AsyncValue.error(
          budgetResult?.failure ??
              transactionResult?.failure ??
              const AppFailure(message: 'Failed to load budget data.'),
          StackTrace.current,
        );
      }

      final walletsById = walletsByIdMap(walletResult?.data ?? const []);
      final adjusted = recomputeBudgetSpentAmounts(
        budgets: budgetResult.data ?? const [],
        transactions: transactionResult.data ?? const [],
        walletsById: walletsById,
        conversion: conversion,
      );

      final filtered = adjusted
          .where(
            (budget) => budget.categoryName.trim().toLowerCase() != 'transfer',
          )
          .toList();

      return AsyncValue.data(filtered);
    });

enum BudgetFilter { all, current, expired }

bool isBudgetExpired(BudgetStatusEntity budget) => budget.isAtOrOverLimit;

final budgetsFilterProvider = StateProvider<BudgetFilter>((ref) {
  return BudgetFilter.all;
});

final hasExpiredBudgetsProvider = Provider<bool>((ref) {
  final budgetsAsync = ref.watch(adjustedBudgetStatusesProvider);

  return budgetsAsync.maybeWhen(
    data: (items) => items.any(isBudgetExpired),
    orElse: () => false,
  );
});

final filteredBudgetStatusesProvider =
    Provider<AsyncValue<List<BudgetStatusEntity>>>((ref) {
      final budgetsAsync = ref.watch(adjustedBudgetStatusesProvider);
      final filter = ref.watch(budgetsFilterProvider);

      return budgetsAsync.when(
        data: (items) {
          var filtered = List<BudgetStatusEntity>.from(items);
          switch (filter) {
            case BudgetFilter.current:
              filtered =
                  filtered.where((budget) => !isBudgetExpired(budget)).toList();
            case BudgetFilter.expired:
              filtered = filtered.where(isBudgetExpired).toList();
            case BudgetFilter.all:
              break;
          }

          return AsyncValue.data(filtered);
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    });
