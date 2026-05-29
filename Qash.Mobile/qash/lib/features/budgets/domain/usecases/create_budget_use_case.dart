import '../../../../core/utils/result.dart';
import '../entities/budget_create.dart';
import '../entities/budget_detail.dart';
import '../repositories/budgets_repository.dart';

class CreateBudgetUseCase {
  final BudgetsRepository _repository;

  const CreateBudgetUseCase(this._repository);

  Future<Result<BudgetDetailEntity>> call(BudgetCreateData data) {
    return _repository.createBudget(data);
  }
}
