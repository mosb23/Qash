import '../../../../core/utils/result.dart';
import '../entities/saving_goal.dart';
import '../entities/saving_goal_create.dart';
import '../repositories/saving_goals_repository.dart';

class CreateSavingGoalUseCase {
  final SavingGoalsRepository _repository;

  const CreateSavingGoalUseCase(this._repository);

  Future<Result<SavingGoalEntity>> call(SavingGoalCreateData data) {
    return _repository.createSavingGoal(data);
  }
}
