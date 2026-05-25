import '../../../../core/errors/app_failure.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/budget_create.dart';
import '../../domain/entities/budget_status.dart';
import '../../domain/repositories/budgets_repository.dart';
import '../datasources/budgets_remote_data_source.dart';
import '../models/budget_create_request_model.dart';

class BudgetsRepositoryImpl implements BudgetsRepository {
  final BudgetsRemoteDataSource _remoteDataSource;
  final SecureStorageService _storage;

  const BudgetsRepositoryImpl(this._remoteDataSource, this._storage);

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
  Future<Result<String>> createBudget(BudgetCreateData data) async {
    final resolvedUserId = data.userId.isNotEmpty
        ? data.userId
        : await _storage.getUserId() ?? '';

    if (resolvedUserId.isEmpty) {
      return Result.failure(
        const AppFailure(message: 'Missing user id. Please sign in again.'),
      );
    }

    final response = await _remoteDataSource.createBudget(
      BudgetCreateRequestModel.fromDomain(
        BudgetCreateData(
          userId: resolvedUserId,
          categoryId: data.categoryId,
          amount: data.amount,
          year: data.year,
          month: data.month,
        ),
      ),
    );

    if (response.success) {
      return Result.success(response.data ?? response.message);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }
}
