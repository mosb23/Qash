import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import 'datasources/dashboard_remote_data_source.dart';
import 'models/dashboard_model.dart';

class DashboardApi implements DashboardRemoteDataSource {
  final Dio _dio;

  const DashboardApi(this._dio);

  @override
  Future<ApiResponse<DashboardModel>> getDashboard() async {
    try {
      final response = await _dio.get('/api/dashboard');
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<DashboardModel>.fromJson(
        data,
        (json) => DashboardModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return _handleError<DashboardModel>(error);
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
