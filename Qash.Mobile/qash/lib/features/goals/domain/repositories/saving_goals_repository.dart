import '../../../../core/utils/result.dart';
import '../entities/saving_goal.dart';

abstract class SavingGoalsRepository {
  Future<Result<List<SavingGoalEntity>>> getSavingGoals();
}
