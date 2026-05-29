import '../../../../core/utils/result.dart';
import '../entities/saving_goal.dart';
import '../repositories/saving_goals_repository.dart';

class GetSavingGoalByIdUseCase {
  final SavingGoalsRepository _repository;

  const GetSavingGoalByIdUseCase(this._repository);

  Future<Result<SavingGoalEntity>> call(String goalId) {
    return _repository.getSavingGoalById(goalId);
  }
}
