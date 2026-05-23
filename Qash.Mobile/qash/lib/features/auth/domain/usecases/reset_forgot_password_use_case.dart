import '../../../../core/utils/result.dart';
import '../entities/auth_requests.dart';
import '../repositories/auth_repository.dart';

class ResetForgotPasswordUseCase {
  final AuthRepository _repository;

  const ResetForgotPasswordUseCase(this._repository);

  Future<Result<String>> call(ResetForgotPasswordData data) {
    return _repository.resetForgotPassword(data);
  }
}
