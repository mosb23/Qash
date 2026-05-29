import '../../../../core/utils/result.dart';
import '../entities/budget_update.dart';
import '../repositories/budgets_repository.dart';

class UpdateBudgetUseCase {
  final BudgetsRepository _repository;

  const UpdateBudgetUseCase(this._repository);

  Future<Result<String>> call(BudgetUpdateData data) {
    return _repository.updateBudget(data);
  }
}
