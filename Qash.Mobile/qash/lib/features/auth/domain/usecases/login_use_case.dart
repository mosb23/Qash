import '../../../../core/utils/result.dart';
import '../entities/auth_requests.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<Result<AuthSession>> call(LoginCredentials credentials) {
    return _repository.login(credentials);
  }
}
