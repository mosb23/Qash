import '../../../../core/utils/result.dart';
import '../entities/auth_requests.dart';
import '../repositories/auth_repository.dart';

class VerifyPhoneUseCase {
  final AuthRepository _repository;

  const VerifyPhoneUseCase(this._repository);

  Future<Result<String>> call(PhoneVerificationData data) {
    return _repository.verifyPhone(data);
  }
}
