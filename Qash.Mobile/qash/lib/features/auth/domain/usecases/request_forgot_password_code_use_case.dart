import '../../../../core/utils/result.dart';
import '../entities/auth_requests.dart';
import '../entities/forgot_password_code.dart';
import '../repositories/auth_repository.dart';

class RequestForgotPasswordCodeUseCase {
  final AuthRepository _repository;

  const RequestForgotPasswordCodeUseCase(this._repository);

  Future<Result<ForgotPasswordCode>> call(ForgotPasswordCodeRequestData data) {
    return _repository.requestForgotPasswordCode(data);
  }
}
