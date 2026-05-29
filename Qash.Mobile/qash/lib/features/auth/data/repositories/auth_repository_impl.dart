import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_requests.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/forgot_password_code.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_response_model.dart';
import '../models/change_password_request_model.dart';
import '../models/forgot_password_code_request_model.dart';
import '../models/reset_forgot_password_request_model.dart';
import '../models/login_request_model.dart';
import '../models/logout_request_model.dart';
import '../models/refresh_token_request_model.dart';
import '../models/register_request_model.dart';
import '../models/verify_phone_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _storage;

  const AuthRepositoryImpl(this._remoteDataSource, this._storage);

  @override
  Future<Result<AuthSession>> login(LoginCredentials credentials) async {
    final response = await _remoteDataSource.login(
      LoginRequestModel.fromDomain(credentials),
    );

    final result = _mapAuthResponse(response);
    final session = result.data;
    if (result.isSuccess && session != null) {
      await _saveTokens(session);
    }

    return result;
  }

  @override
  Future<Result<AuthSession>> register(RegistrationData data) async {
    final response = await _remoteDataSource.register(
      RegisterRequestModel.fromDomain(data),
    );

    return _mapAuthResponse(response);
  }

  @override
  Future<Result<AuthSession>> verifyPhone(PhoneVerificationData data) async {
    final response = await _remoteDataSource.verifyPhone(
      VerifyPhoneRequestModel.fromDomain(data),
    );

    final result = _mapAuthResponse(response);
    final session = result.data;
    if (result.isSuccess && session != null) {
      await _saveTokens(session);
    }

    return result;
  }

  @override
  Future<Result<ForgotPasswordCode>> requestForgotPasswordCode(
    ForgotPasswordCodeRequestData data,
  ) async {
    final response = await _remoteDataSource.requestForgotPasswordCode(
      ForgotPasswordCodeRequestModel.fromDomain(data),
    );

    if (response.success && response.data != null) {
      return Result.success(response.data!.toDomain());
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }

  @override
  Future<Result<String>> resetForgotPassword(
    ResetForgotPasswordData data,
  ) async {
    final response = await _remoteDataSource.resetForgotPassword(
      ResetForgotPasswordRequestModel.fromDomain(data),
    );

    if (response.success) {
      return Result.success(response.data ?? response.message);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }

  @override
  Future<Result<String>> changePassword(ChangePasswordData data) async {
    final resolvedUserId = data.userId.isNotEmpty
        ? data.userId
        : await _storage.getUserId() ?? '';

    if (resolvedUserId.isEmpty) {
      return Result.failure(
        const AppFailure(message: 'Missing user id. Please sign in again.'),
      );
    }

    final response = await _remoteDataSource.changePassword(
      ChangePasswordRequestModel.fromDomain(
        ChangePasswordData(
          userId: resolvedUserId,
          oldPassword: data.oldPassword,
          newPassword: data.newPassword,
          confirmPassword: data.confirmPassword,
        ),
      ),
    );

    if (response.success) {
      return Result.success(response.data ?? response.message);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }

  Result<AuthSession> _mapAuthResponse(
    ApiResponse<AuthResponseModel> response,
  ) {
    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }

  @override
  Future<Result<AuthSession>> refreshSession() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return Result.failure(
        const AppFailure(message: 'Session expired. Please sign in again.'),
      );
    }

    final response = await _remoteDataSource.refreshToken(
      RefreshTokenRequestModel(refreshToken: refreshToken),
    );

    final result = _mapAuthResponse(response);
    final session = result.data;
    if (result.isSuccess && session != null) {
      await _saveTokens(session);
    }
    return result;
  }

  @override
  Future<Result<String>> logout() async {
    final refreshToken = await _storage.getRefreshToken() ?? '';
    if (refreshToken.isNotEmpty) {
      await _remoteDataSource.logout(
        LogoutRequestModel(refreshToken: refreshToken),
      );
    }
    await _storage.clearTokens();
    return Result.success('Signed out');
  }

  Future<void> _saveTokens(AuthSession session) async {
    if (session.userId.isNotEmpty) {
      await _storage.saveUserId(session.userId);
    }
    if (session.accessToken.isNotEmpty) {
      await _storage.saveAccessToken(session.accessToken);
    }
    if (session.refreshToken.isNotEmpty) {
      await _storage.saveRefreshToken(session.refreshToken);
    }
  }
}
