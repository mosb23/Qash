import '../../../../core/utils/result.dart';
import '../entities/auth_requests.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository _repository;

  const ChangePasswordUseCase(this._repository);

  Future<Result<String>> call(ChangePasswordData data) {
    return _repository.changePassword(data);
  }
}
