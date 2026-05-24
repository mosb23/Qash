import '../../../../core/utils/result.dart';
import '../entities/saving_goal.dart';
import '../entities/saving_goal_contribution.dart';
import '../repositories/saving_goals_repository.dart';

class ContributeToSavingGoalUseCase {
  final SavingGoalsRepository _repository;

  const ContributeToSavingGoalUseCase(this._repository);

  Future<Result<SavingGoalEntity>> call(SavingGoalContributionData data) {
    return _repository.contributeToSavingGoal(data);
  }
}
