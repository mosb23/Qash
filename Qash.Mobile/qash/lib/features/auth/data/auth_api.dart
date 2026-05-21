import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/verify_phone_request.dart';

class AuthApi {
  final Dio _dio;
  final SecureStorageService _storage;

  AuthApi(this._dio, this._storage);

  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<AuthResponse>.fromJson(
        data,
        (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return _handleError<AuthResponse>(error);
    }
  }

  Future<ApiResponse<String>> verifyPhone(VerifyPhoneRequest request) async {
    try {
      final response = await _dio.post(
        '/api/auth/verify-phone',
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

  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      final apiResponse = ApiResponse<AuthResponse>.fromJson(
        data,
        (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
      );
      if (apiResponse.success && apiResponse.data != null) {
        final auth = apiResponse.data!;
        if (auth.accessToken.isNotEmpty) {
          await _storage.saveAccessToken(auth.accessToken);
        }
        if (auth.refreshToken.isNotEmpty) {
          await _storage.saveRefreshToken(auth.refreshToken);
        }
      }
      return apiResponse;
    } on DioException catch (error) {
      return _handleError<AuthResponse>(error);
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
