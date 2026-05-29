import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/providers.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/utils/result.dart';
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

enum BudgetFilter { all, current, expired }

bool isBudgetExpired(BudgetStatusEntity budget) => budget.isAtOrOverLimit;

final budgetsFilterProvider = StateProvider<BudgetFilter>((ref) {
  return BudgetFilter.all;
});

final hasExpiredBudgetsProvider = Provider<bool>((ref) {
  final budgetsAsync = ref.watch(budgetStatusesProvider);

  return budgetsAsync.maybeWhen(
    data: (result) {
      if (result.isFailure) {
        return false;
      }
      return (result.data ?? const []).any(isBudgetExpired);
    },
    orElse: () => false,
  );
});

final filteredBudgetStatusesProvider =
    Provider<AsyncValue<List<BudgetStatusEntity>>>((ref) {
      final budgetsAsync = ref.watch(budgetStatusesProvider);
      final filter = ref.watch(budgetsFilterProvider);

      return budgetsAsync.when(
        data: (result) {
          if (result.isFailure) {
            return AsyncValue.error(
              result.failure ??
                  const AppFailure(message: 'Failed to load budgets.'),
              StackTrace.current,
            );
          }

          var items = List<BudgetStatusEntity>.from(result.data ?? const []);
          switch (filter) {
            case BudgetFilter.current:
              items = items.where((budget) => !isBudgetExpired(budget)).toList();
            case BudgetFilter.expired:
              items = items.where(isBudgetExpired).toList();
            case BudgetFilter.all:
              break;
          }

          return AsyncValue.data(items);
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    });
