import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/budget_status.dart';
import '../../domain/repositories/budgets_repository.dart';
import '../datasources/budgets_remote_data_source.dart';

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
}
