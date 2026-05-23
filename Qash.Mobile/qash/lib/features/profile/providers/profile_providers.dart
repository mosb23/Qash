import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/providers.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/profile_remote_data_source.dart';
import '../data/profile_api.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/entities/profile.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/usecases/get_profile_use_case.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  return ProfileApi(ref.read(dioProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.read(profileRemoteDataSourceProvider));
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.read(profileRepositoryProvider));
});

final profileProvider = FutureProvider<Result<ProfileEntity>>((ref) async {
  final useCase = ref.read(getProfileUseCaseProvider);
  return useCase();
});
