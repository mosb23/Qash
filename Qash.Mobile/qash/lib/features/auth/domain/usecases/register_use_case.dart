import '../../../../core/utils/result.dart';
import '../entities/auth_requests.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCase(this._repository);

  Future<Result<AuthSession>> call(RegistrationData data) {
    return _repository.register(data);
  }
}
