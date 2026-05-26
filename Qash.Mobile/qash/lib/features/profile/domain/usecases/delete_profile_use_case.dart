import '../../../../core/utils/result.dart';
import '../repositories/profile_repository.dart';

class DeleteProfileUseCase {
  final ProfileRepository _repository;

  const DeleteProfileUseCase(this._repository);

  Future<Result<String>> call() {
    return _repository.deleteProfile();
  }
}
