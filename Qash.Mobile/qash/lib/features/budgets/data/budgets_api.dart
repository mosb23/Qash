import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import 'datasources/budgets_remote_data_source.dart';
import 'models/budget_status_model.dart';

class BudgetsApi implements BudgetsRemoteDataSource {
  final Dio _dio;

  const BudgetsApi(this._dio);

  @override
  Future<ApiResponse<List<BudgetStatusModel>>> getBudgetStatuses(
    int year,
    int month,
  ) async {
    try {
      final response = await _dio.get(
        '/api/budgets/status',
        queryParameters: {'year': year, 'month': month},
      );
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<List<BudgetStatusModel>>.fromJson(data, (json) {
        final items = json as List<dynamic>? ?? [];
        return items
            .map(
              (item) =>
                  BudgetStatusModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      });
    } on DioException catch (error) {
      return _handleError<List<BudgetStatusModel>>(error);
    }
  }

  ApiResponse<T> _handleError<T>(DioException error) {
    final response = error.response?.data;
    if (response is Map<String, dynamic>) {
      return ApiResponse<T>.fromJson(response, null);
    }
    return ApiResponse<T>.failure('Request failed. Please try again.');
  }
}
