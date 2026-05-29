import '../../../../core/utils/result.dart';
import '../entities/budget_create.dart';
import '../entities/budget_status.dart';
import '../entities/budget_update.dart';

abstract class BudgetsRepository {
  Future<Result<List<BudgetStatusEntity>>> getBudgetStatuses(
    BudgetPeriod period,
  );

  Future<Result<BudgetStatusEntity>> getBudgetById(String budgetId);

  Future<Result<String>> createBudget(BudgetCreateData data);

  Future<Result<String>> updateBudget(BudgetUpdateData data);

  Future<Result<String>> deleteBudget(String budgetId);
}
