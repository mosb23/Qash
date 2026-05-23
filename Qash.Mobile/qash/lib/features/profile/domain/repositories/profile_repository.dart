import '../../../../core/utils/result.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Result<ProfileEntity>> getProfile();
}
