import '../../../../core/utils/result.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository _repository;

  const GetProfileUseCase(this._repository);

  Future<Result<ProfileEntity>> call() {
    return _repository.getProfile();
  }
}
