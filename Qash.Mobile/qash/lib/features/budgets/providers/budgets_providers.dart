import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/providers.dart';
import '../../../core/utils/result.dart';
import '../data/budgets_api.dart';
import '../data/datasources/budgets_remote_data_source.dart';
import '../data/repositories/budgets_repository_impl.dart';
import '../domain/entities/budget_status.dart';
import '../domain/repositories/budgets_repository.dart';
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

final budgetStatusesProvider = FutureProvider<Result<List<BudgetStatusEntity>>>(
  (ref) async {
    final useCase = ref.read(getBudgetStatusesUseCaseProvider);
    final period = ref.watch(budgetPeriodProvider);
    return useCase(period);
  },
);
