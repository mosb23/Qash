import '../../../../core/utils/result.dart';
import '../entities/saving_goal.dart';
import '../entities/saving_goal_create.dart';
import '../entities/saving_goal_contribution.dart';

abstract class SavingGoalsRepository {
  Future<Result<List<SavingGoalEntity>>> getSavingGoals();

  Future<Result<SavingGoalEntity>> createSavingGoal(SavingGoalCreateData data);

  Future<Result<SavingGoalEntity>> contributeToSavingGoal(
    SavingGoalContributionData data,
  );

  Future<Result<String>> deleteSavingGoal(String savingGoalId);
}
