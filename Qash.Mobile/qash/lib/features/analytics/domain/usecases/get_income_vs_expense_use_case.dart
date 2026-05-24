import '../../../../core/utils/result.dart';
import '../entities/income_vs_expense.dart';
import '../repositories/analytics_repository.dart';

class GetIncomeVsExpenseUseCase {
  final AnalyticsRepository _repository;

  const GetIncomeVsExpenseUseCase(this._repository);

  Future<Result<List<IncomeVsExpenseEntity>>> call(int year) {
    return _repository.getIncomeVsExpense(year);
  }
}
