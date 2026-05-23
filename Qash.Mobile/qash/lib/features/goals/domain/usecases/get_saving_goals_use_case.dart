import '../../../../core/utils/result.dart';
import '../entities/saving_goal.dart';
import '../repositories/saving_goals_repository.dart';

class GetSavingGoalsUseCase {
  final SavingGoalsRepository _repository;

  const GetSavingGoalsUseCase(this._repository);

  Future<Result<List<SavingGoalEntity>>> call() {
    return _repository.getSavingGoals();
  }
}
