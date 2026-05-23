import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/saving_goal.dart';
import '../../domain/repositories/saving_goals_repository.dart';
import '../datasources/saving_goals_remote_data_source.dart';

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
}
