import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/saving_goal.dart';
import '../../domain/entities/saving_goal_create.dart';
import '../../domain/entities/saving_goal_contribution.dart';
import '../../domain/entities/saving_goal_update.dart';
import '../../domain/repositories/saving_goals_repository.dart';
import '../datasources/saving_goals_remote_data_source.dart';
import '../models/saving_goal_contribution_request_model.dart';
import '../models/saving_goal_create_request_model.dart';
import '../models/saving_goal_update_request_model.dart';

class SavingGoalsRepositoryImpl implements SavingGoalsRepository {
  final SavingGoalsRemoteDataSource _remoteDataSource;

  const SavingGoalsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<SavingGoalEntity>>> getSavingGoals() async {
    final response = await _remoteDataSource.getSavingGoals();

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }

  @override
  Future<Result<SavingGoalEntity>> getSavingGoalById(String goalId) async {
    final response = await _remoteDataSource.getSavingGoalById(goalId);

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }

  @override
  Future<Result<SavingGoalEntity>> createSavingGoal(
    SavingGoalCreateData data,
  ) async {
    final response = await _remoteDataSource.createSavingGoal(
      SavingGoalCreateRequestModel.fromDomain(data),
    );

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }

  @override
  Future<Result<SavingGoalEntity>> contributeToSavingGoal(
    SavingGoalContributionData data,
  ) async {
    final response = await _remoteDataSource.contributeToSavingGoal(
      data.savingGoalId,
      SavingGoalContributionRequestModel.fromDomain(data),
    );

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }

  @override
  Future<Result<SavingGoalEntity>> updateSavingGoal(
    SavingGoalUpdateData data,
  ) async {
    final response = await _remoteDataSource.updateSavingGoal(
      data.savingGoalId,
      SavingGoalUpdateRequestModel.fromDomain(data),
    );

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }

  @override
  Future<Result<String>> deleteSavingGoal(String savingGoalId) async {
    final response = await _remoteDataSource.deleteSavingGoal(savingGoalId);

    if (response.success) {
      return Result.success(response.data ?? '');
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }
}
