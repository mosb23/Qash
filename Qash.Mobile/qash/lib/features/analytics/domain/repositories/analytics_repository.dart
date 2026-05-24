import '../../../../core/utils/result.dart';
import '../entities/category_breakdown.dart';
import '../entities/date_range_summary.dart';
import '../entities/income_vs_expense.dart';
import '../entities/monthly_summary.dart';
import '../entities/spending_trend.dart';

abstract class AnalyticsRepository {
  Future<Result<MonthlySummaryEntity>> getMonthlySummary(int year, int month);

  Future<Result<List<CategoryBreakdownEntity>>> getCategoryBreakdown(
    int year,
    int month,
  );

  Future<Result<List<IncomeVsExpenseEntity>>> getIncomeVsExpense(int year);

  Future<Result<List<SpendingTrendEntity>>> getSpendingTrend(int days);

  Future<Result<DateRangeSummaryEntity>> getDateRangeSummary(
    DateTime fromUtc,
    DateTime toUtc,
  );
}
