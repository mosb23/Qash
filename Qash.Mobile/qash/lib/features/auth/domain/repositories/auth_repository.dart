import '../../../../core/utils/result.dart';
import '../entities/auth_requests.dart';
import '../entities/auth_session.dart';
import '../entities/forgot_password_code.dart';

abstract class AuthRepository {
  Future<Result<AuthSession>> login(LoginCredentials credentials);

  Future<Result<AuthSession>> register(RegistrationData data);

  Future<Result<AuthSession>> verifyPhone(PhoneVerificationData data);

  Future<Result<ForgotPasswordCode>> requestForgotPasswordCode(
    ForgotPasswordCodeRequestData data,
  );

  Future<Result<String>> resetForgotPassword(ResetForgotPasswordData data);

  Future<Result<String>> changePassword(ChangePasswordData data);

  Future<Result<AuthSession>> refreshSession();

  Future<Result<String>> logout();
}
