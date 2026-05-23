import '../../../../core/utils/result.dart';
import '../entities/budget_status.dart';
import '../repositories/budgets_repository.dart';

class GetBudgetStatusesUseCase {
  final BudgetsRepository _repository;

  const GetBudgetStatusesUseCase(this._repository);

  Future<Result<List<BudgetStatusEntity>>> call(BudgetPeriod period) {
    return _repository.getBudgetStatuses(period);
  }
}
