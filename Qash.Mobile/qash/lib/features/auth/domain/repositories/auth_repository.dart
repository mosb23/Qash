import '../../../../core/utils/result.dart';
import '../entities/auth_requests.dart';
import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<Result<AuthSession>> login(LoginCredentials credentials);

  Future<Result<AuthSession>> register(RegistrationData data);

  Future<Result<String>> verifyPhone(PhoneVerificationData data);
}
