import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import 'datasources/saving_goals_remote_data_source.dart';
import 'models/saving_goal_contribution_request_model.dart';
import 'models/saving_goal_create_request_model.dart';
import 'models/saving_goal_model.dart';
import 'models/saving_goal_update_request_model.dart';

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

  @override
  Future<ApiResponse<SavingGoalModel>> getSavingGoalById(String goalId) async {
    try {
      final response = await _dio.get('/api/saving-goals/$goalId');
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<SavingGoalModel>.fromJson(
        data,
        (json) => SavingGoalModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return _handleError<SavingGoalModel>(error);
    }
  }

  @override
  Future<ApiResponse<SavingGoalModel>> createSavingGoal(
    SavingGoalCreateRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/saving-goals',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<SavingGoalModel>.fromJson(
        data,
        (json) => SavingGoalModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return _handleError<SavingGoalModel>(error);
    }
  }

  @override
  Future<ApiResponse<SavingGoalModel>> contributeToSavingGoal(
    String savingGoalId,
    SavingGoalContributionRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/saving-goals/$savingGoalId/contribute',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<SavingGoalModel>.fromJson(
        data,
        (json) => SavingGoalModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return _handleError<SavingGoalModel>(error);
    }
  }

  @override
  Future<ApiResponse<SavingGoalModel>> updateSavingGoal(
    String savingGoalId,
    SavingGoalUpdateRequestModel request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/saving-goals/$savingGoalId',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<SavingGoalModel>.fromJson(
        data,
        (json) => SavingGoalModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return _handleError<SavingGoalModel>(error);
    }
  }

  @override
  Future<ApiResponse<String>> deleteSavingGoal(String savingGoalId) async {
    try {
      final response = await _dio.delete('/api/saving-goals/$savingGoalId');
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
