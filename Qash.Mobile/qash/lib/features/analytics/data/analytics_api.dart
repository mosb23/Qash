import 'package:dio/dio.dart';

import 'datasources/analytics_remote_data_source.dart';
import 'models/category_breakdown_model.dart';
import 'models/date_range_summary_model.dart';
import 'models/income_vs_expense_model.dart';
import 'models/monthly_summary_model.dart';
import 'models/spending_trend_model.dart';

class AnalyticsApi implements AnalyticsRemoteDataSource {
  final Dio _dio;

  const AnalyticsApi(this._dio);

  @override
  Future<MonthlySummaryModel> getMonthlySummary(int year, int month) async {
    final response = await _dio.get(
      '/api/reports/monthly-summary',
      queryParameters: {'year': year, 'month': month},
    );
    return MonthlySummaryModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<CategoryBreakdownModel>> getCategoryBreakdown(
    int year,
    int month,
  ) async {
    final response = await _dio.get(
      '/api/reports/category-breakdown',
      queryParameters: {'year': year, 'month': month},
    );
    final data = response.data as List<dynamic>;
    return data
        .map(
          (item) =>
              CategoryBreakdownModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<List<IncomeVsExpenseModel>> getIncomeVsExpense(int year) async {
    final response = await _dio.get(
      '/api/reports/income-vs-expense',
      queryParameters: {'year': year},
    );
    final data = response.data as List<dynamic>;
    return data
        .map(
          (item) => IncomeVsExpenseModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<List<SpendingTrendModel>> getSpendingTrend(int days) async {
    final response = await _dio.get(
      '/api/reports/spending-trend',
      queryParameters: {'days': days},
    );
    final data = response.data as List<dynamic>;
    return data
        .map(
          (item) => SpendingTrendModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<DateRangeSummaryModel> getDateRangeSummary(
    DateTime fromUtc,
    DateTime toUtc,
  ) async {
    final response = await _dio.get(
      '/api/reports/date-range-summary',
      queryParameters: {
        'fromUtc': fromUtc.toUtc().toIso8601String(),
        'toUtc': toUtc.toUtc().toIso8601String(),
      },
    );
    return DateRangeSummaryModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
