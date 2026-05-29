import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/budget_create.dart';
import '../../domain/entities/budget_detail.dart';
import '../../domain/entities/budget_status.dart';
import '../../domain/repositories/budgets_repository.dart';
import '../datasources/budgets_remote_data_source.dart';
import '../models/budget_create_request_model.dart';

class BudgetsRepositoryImpl implements BudgetsRepository {
  final BudgetsRemoteDataSource _remoteDataSource;

  const BudgetsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<BudgetStatusEntity>>> getBudgetStatuses(
    BudgetPeriod period,
  ) async {
    final response = await _remoteDataSource.getBudgetStatuses(
      period.year,
      period.month,
    );

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }

  @override
  Future<Result<BudgetDetailEntity>> createBudget(BudgetCreateData data) async {
    final response = await _remoteDataSource.createBudget(
      BudgetCreateRequestModel.fromDomain(
        BudgetCreateData(
          userId: data.userId,
          categoryId: data.categoryId,
          amount: data.amount,
          year: data.year,
          month: data.month,
        ),
      ),
    );

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }

  @override
  Future<Result<String>> deleteBudget(String budgetId) async {
    final response = await _remoteDataSource.deleteBudget(budgetId);

    if (response.success) {
      return Result.success(response.data ?? response.message);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }
}
