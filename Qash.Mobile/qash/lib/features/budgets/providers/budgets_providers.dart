import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/providers.dart';
import '../../../core/utils/result.dart';
import '../data/budgets_api.dart';
import '../data/datasources/budgets_remote_data_source.dart';
import '../data/repositories/budgets_repository_impl.dart';
import '../domain/entities/budget_status.dart';
import '../domain/repositories/budgets_repository.dart';
import '../domain/usecases/create_budget_use_case.dart';
import '../domain/usecases/delete_budget_use_case.dart';
import '../domain/usecases/get_budget_by_id_use_case.dart';
import '../domain/usecases/get_budget_statuses_use_case.dart';
import '../domain/usecases/update_budget_use_case.dart';

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
  return BudgetsRepositoryImpl(
    ref.read(budgetsRemoteDataSourceProvider),
    ref.read(secureStorageProvider),
  );
});

final getBudgetStatusesUseCaseProvider = Provider<GetBudgetStatusesUseCase>((
  ref,
) {
  return GetBudgetStatusesUseCase(ref.read(budgetsRepositoryProvider));
});

final getBudgetByIdUseCaseProvider = Provider<GetBudgetByIdUseCase>((ref) {
  return GetBudgetByIdUseCase(ref.read(budgetsRepositoryProvider));
});

final createBudgetUseCaseProvider = Provider<CreateBudgetUseCase>((ref) {
  return CreateBudgetUseCase(ref.read(budgetsRepositoryProvider));
});

final updateBudgetUseCaseProvider = Provider<UpdateBudgetUseCase>((ref) {
  return UpdateBudgetUseCase(ref.read(budgetsRepositoryProvider));
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

final budgetByIdProvider = FutureProvider.family<Result<BudgetStatusEntity>, String>(
  (ref, budgetId) async {
    final useCase = ref.read(getBudgetByIdUseCaseProvider);
    return useCase(budgetId);
  },
);
