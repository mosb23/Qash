import '../../../../core/utils/result.dart';
import '../repositories/budgets_repository.dart';

class DeleteBudgetUseCase {
  final BudgetsRepository _repository;

  const DeleteBudgetUseCase(this._repository);

  Future<Result<String>> call(String budgetId) {
    return _repository.deleteBudget(budgetId);
  }
}
