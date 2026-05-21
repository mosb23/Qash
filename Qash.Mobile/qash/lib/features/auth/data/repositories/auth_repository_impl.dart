import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_requests.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
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
  Future<Result<String>> verifyPhone(PhoneVerificationData data) async {
    final response = await _remoteDataSource.verifyPhone(
      VerifyPhoneRequestModel.fromDomain(data),
    );

    if (response.success) {
      return Result.success(response.data ?? response.message);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }

  Result<AuthSession> _mapAuthResponse(ApiResponse<AuthResponseModel> response) {
    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }

  Future<void> _saveTokens(AuthSession session) async {
    if (session.accessToken.isNotEmpty) {
      await _storage.saveAccessToken(session.accessToken);
    }
    if (session.refreshToken.isNotEmpty) {
      await _storage.saveRefreshToken(session.refreshToken);
    }
  }
}
