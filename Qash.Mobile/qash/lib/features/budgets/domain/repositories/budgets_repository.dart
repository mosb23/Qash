import '../../../../core/utils/result.dart';
import '../entities/budget_create.dart';
import '../entities/budget_detail.dart';
import '../entities/budget_status.dart';

abstract class BudgetsRepository {
  Future<Result<List<BudgetStatusEntity>>> getBudgetStatuses(
    BudgetPeriod period,
  );

  Future<Result<BudgetDetailEntity>> createBudget(BudgetCreateData data);

  Future<Result<String>> deleteBudget(String budgetId);
}
