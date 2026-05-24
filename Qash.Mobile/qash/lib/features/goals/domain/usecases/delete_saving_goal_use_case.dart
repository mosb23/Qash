import '../../../../core/utils/result.dart';
import '../repositories/saving_goals_repository.dart';

class DeleteSavingGoalUseCase {
  final SavingGoalsRepository _repository;

  const DeleteSavingGoalUseCase(this._repository);

  Future<Result<String>> call(String savingGoalId) {
    return _repository.deleteSavingGoal(savingGoalId);
  }
}
