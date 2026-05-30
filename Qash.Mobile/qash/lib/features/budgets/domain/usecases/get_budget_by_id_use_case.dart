import '../../../../core/utils/result.dart';
import '../entities/budget_status.dart';
import '../repositories/budgets_repository.dart';

class GetBudgetByIdUseCase {
  final BudgetsRepository _repository;

  const GetBudgetByIdUseCase(this._repository);

  Future<Result<BudgetStatusEntity>> call(String budgetId) {
    return _repository.getBudgetById(budgetId);
  }
}
