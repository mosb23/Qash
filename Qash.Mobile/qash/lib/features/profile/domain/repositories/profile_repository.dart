import '../../../../core/utils/result.dart';
import '../entities/profile.dart';
import '../entities/profile_update.dart';

abstract class ProfileRepository {
  Future<Result<ProfileEntity>> getProfile();

  Future<Result<ProfileEntity>> updateProfile(ProfileUpdateData data);

  Future<Result<String>> deleteProfile(String password);
}
