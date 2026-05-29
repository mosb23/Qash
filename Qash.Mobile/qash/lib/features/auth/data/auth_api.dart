import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import 'datasources/auth_remote_data_source.dart';
import 'models/auth_response_model.dart';
import 'models/change_password_request_model.dart';
import 'models/forgot_password_code_request_model.dart';
import 'models/forgot_password_code_response_model.dart';
import 'models/login_request_model.dart';
import 'models/register_request_model.dart';
import 'models/reset_forgot_password_request_model.dart';
import 'models/verify_phone_request_model.dart';

class AuthApi implements AuthRemoteDataSource {
  final Dio _dio;

  const AuthApi(this._dio);

  @override
  Future<ApiResponse<AuthResponseModel>> register(
    RegisterRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<AuthResponseModel>.fromJson(
        data,
        (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return _handleError<AuthResponseModel>(error);
    }
  }

  @override
  Future<ApiResponse<AuthResponseModel>> verifyPhone(
    VerifyPhoneRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/auth/verify-phone',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<AuthResponseModel>.fromJson(
        data,
        (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return _handleError<AuthResponseModel>(error);
    }
  }

  @override
  Future<ApiResponse<AuthResponseModel>> login(
    LoginRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<AuthResponseModel>.fromJson(
        data,
        (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return _handleError<AuthResponseModel>(error);
    }
  }

  @override
  Future<ApiResponse<ForgotPasswordCodeResponseModel>>
  requestForgotPasswordCode(ForgotPasswordCodeRequestModel request) async {
    try {
      final response = await _dio.post(
        '/api/auth/forgot-password/request-code',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<ForgotPasswordCodeResponseModel>.fromJson(
        data,
        (json) => ForgotPasswordCodeResponseModel.fromJson(
          json as Map<String, dynamic>,
        ),
      );
    } on DioException catch (error) {
      return _handleError<ForgotPasswordCodeResponseModel>(error);
    }
  }

  @override
  Future<ApiResponse<String>> resetForgotPassword(
    ResetForgotPasswordRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/auth/forgot-password/reset',
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
  Future<ApiResponse<String>> changePassword(
    ChangePasswordRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/profile/change-password',
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

  ApiResponse<T> _handleError<T>(DioException error) {
    final response = error.response?.data;
    if (response is Map<String, dynamic>) {
      return ApiResponse<T>.fromJson(response, null);
    }
    return ApiResponse<T>.failure('Request failed. Please try again.');
  }
}
