import '../../../../core/utils/result.dart';
import '../entities/budget_status.dart';

abstract class BudgetsRepository {
  Future<Result<List<BudgetStatusEntity>>> getBudgetStatuses(
    BudgetPeriod period,
  );
}
