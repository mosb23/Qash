import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import 'datasources/saving_goals_remote_data_source.dart';
import 'models/saving_goal_model.dart';

class SavingGoalsApi implements SavingGoalsRemoteDataSource {
  final Dio _dio;

  const SavingGoalsApi(this._dio);

  @override
  Future<ApiResponse<List<SavingGoalModel>>> getSavingGoals() async {
    try {
      final response = await _dio.get('/api/saving-goals');
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<List<SavingGoalModel>>.fromJson(data, (json) {
        final items = json as List<dynamic>? ?? [];
        return items
            .map(
              (item) => SavingGoalModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      });
    } on DioException catch (error) {
      return _handleError<List<SavingGoalModel>>(error);
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
