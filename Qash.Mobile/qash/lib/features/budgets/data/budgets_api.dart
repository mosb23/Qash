import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import 'datasources/budgets_remote_data_source.dart';
import 'models/budget_create_request_model.dart';
import 'models/budget_status_model.dart';
import 'models/budget_update_request_model.dart';

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

  @override
  Future<ApiResponse<BudgetStatusModel>> getBudgetById(String budgetId) async {
    try {
      final response = await _dio.get('/api/budgets/$budgetId');
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<BudgetStatusModel>.fromJson(
        data,
        (json) => BudgetStatusModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return _handleError<BudgetStatusModel>(error);
    }
  }

  @override
  Future<ApiResponse<String>> createBudget(
    BudgetCreateRequestModel request,
  ) async {
    try {
      final response = await _dio.post('/api/budgets', data: request.toJson());
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<String>.fromJson(
        data,
        (json) => json?.toString() ?? '',
      );
    } on DioException catch (error) {
      return _handleError<String>(error);
    }
  }

  @override
  Future<ApiResponse<String>> updateBudget(
    String budgetId,
    BudgetUpdateRequestModel request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/budgets/$budgetId',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<String>.fromJson(
        data,
        (json) => json?.toString() ?? '',
      );
    } on DioException catch (error) {
      return _handleError<String>(error);
    }
  }

  @override
  Future<ApiResponse<String>> deleteBudget(String budgetId) async {
    try {
      final response = await _dio.delete('/api/budgets/$budgetId');
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<String>.fromJson(
        data,
        (json) => json?.toString() ?? '',
      );
    } on DioException catch (error) {
      return _handleError<String>(error);
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
