import '../models/category_breakdown_model.dart';
import '../models/date_range_summary_model.dart';
import '../models/income_vs_expense_model.dart';
import '../models/monthly_summary_model.dart';
import '../models/spending_trend_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<MonthlySummaryModel> getMonthlySummary(int year, int month);

  Future<List<CategoryBreakdownModel>> getCategoryBreakdown(
    int year,
    int month,
  );

  Future<List<IncomeVsExpenseModel>> getIncomeVsExpense(int year);

  Future<List<SpendingTrendModel>> getSpendingTrend(int days);

  Future<DateRangeSummaryModel> getDateRangeSummary(
    DateTime fromUtc,
    DateTime toUtc,
  );
}
