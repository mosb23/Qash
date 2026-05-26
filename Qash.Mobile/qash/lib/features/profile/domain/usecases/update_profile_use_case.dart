import '../../../../core/utils/result.dart';
import '../entities/profile.dart';
import '../entities/profile_update.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository _repository;

  const UpdateProfileUseCase(this._repository);

  Future<Result<ProfileEntity>> call(ProfileUpdateData data) {
    return _repository.updateProfile(data);
  }
}
