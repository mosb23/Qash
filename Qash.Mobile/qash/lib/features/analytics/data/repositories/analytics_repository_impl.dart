import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/category_breakdown.dart';
import '../../domain/entities/date_range_summary.dart';
import '../../domain/entities/income_vs_expense.dart';
import '../../domain/entities/monthly_summary.dart';
import '../../domain/entities/spending_trend.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_data_source.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _remoteDataSource;

  const AnalyticsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<MonthlySummaryEntity>> getMonthlySummary(
    int year,
    int month,
  ) async {
    try {
      final response = await _remoteDataSource.getMonthlySummary(year, month);
      return Result.success(response);
    } catch (error) {
      return Result.failure(
        const AppFailure(message: 'Failed to load summary.'),
      );
    }
  }

  @override
  Future<Result<List<CategoryBreakdownEntity>>> getCategoryBreakdown(
    int year,
    int month,
  ) async {
    try {
      final response = await _remoteDataSource.getCategoryBreakdown(
        year,
        month,
      );
      return Result.success(response);
    } catch (error) {
      return Result.failure(
        const AppFailure(message: 'Failed to load category breakdown.'),
      );
    }
  }

  @override
  Future<Result<List<IncomeVsExpenseEntity>>> getIncomeVsExpense(
    int year,
  ) async {
    try {
      final response = await _remoteDataSource.getIncomeVsExpense(year);
      return Result.success(response);
    } catch (error) {
      return Result.failure(
        const AppFailure(message: 'Failed to load income vs expense.'),
      );
    }
  }

  @override
  Future<Result<List<SpendingTrendEntity>>> getSpendingTrend(int days) async {
    try {
      final response = await _remoteDataSource.getSpendingTrend(days);
      return Result.success(response);
    } catch (error) {
      return Result.failure(
        const AppFailure(message: 'Failed to load spending trend.'),
      );
    }
  }

  @override
  Future<Result<DateRangeSummaryEntity>> getDateRangeSummary(
    DateTime fromUtc,
    DateTime toUtc,
  ) async {
    try {
      final response = await _remoteDataSource.getDateRangeSummary(
        fromUtc,
        toUtc,
      );
      return Result.success(response);
    } catch (error) {
      return Result.failure(
        const AppFailure(message: 'Failed to load date range summary.'),
      );
    }
  }
}
