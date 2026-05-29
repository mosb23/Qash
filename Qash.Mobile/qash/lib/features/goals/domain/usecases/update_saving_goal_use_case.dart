import '../../../../core/utils/result.dart';
import '../entities/saving_goal.dart';
import '../entities/saving_goal_update.dart';
import '../repositories/saving_goals_repository.dart';

class UpdateSavingGoalUseCase {
  final SavingGoalsRepository _repository;

  const UpdateSavingGoalUseCase(this._repository);

  Future<Result<SavingGoalEntity>> call(SavingGoalUpdateData data) {
    return _repository.updateSavingGoal(data);
  }
}
