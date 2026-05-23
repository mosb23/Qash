import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  const ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<ProfileEntity>> getProfile() async {
    final response = await _remoteDataSource.getProfile();

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }
}
