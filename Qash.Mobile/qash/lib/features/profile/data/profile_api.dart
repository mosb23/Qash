import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import 'datasources/profile_remote_data_source.dart';
import 'models/profile_model.dart';
import 'models/profile_update_request_model.dart';

class ProfileApi implements ProfileRemoteDataSource {
  final Dio _dio;

  const ProfileApi(this._dio);

  @override
  Future<ApiResponse<ProfileModel>> getProfile() async {
    try {
      final response = await _dio.get('/api/profile');
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<ProfileModel>.fromJson(
        data,
        (json) => ProfileModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return _handleError<ProfileModel>(error);
    }
  }

  @override
  Future<ApiResponse<ProfileModel>> updateProfile(
    ProfileUpdateRequestModel request,
  ) async {
    try {
      final response = await _dio.put('/api/profile', data: request.toJson());
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<ProfileModel>.fromJson(
        data,
        (json) => ProfileModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return _handleError<ProfileModel>(error);
    }
  }

  @override
  Future<ApiResponse<String>> deleteProfile() async {
    try {
      final response = await _dio.delete('/api/profile');
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
