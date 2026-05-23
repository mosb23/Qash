import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/providers.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/wallets_remote_data_source.dart';
import '../data/repositories/wallets_repository_impl.dart';
import '../data/wallets_api.dart';
import '../domain/entities/wallet.dart';
import '../domain/repositories/wallets_repository.dart';
import '../domain/usecases/get_wallets_use_case.dart';

final walletsRemoteDataSourceProvider = Provider<WalletsRemoteDataSource>((
  ref,
) {
  return WalletsApi(ref.read(dioProvider));
});

final walletsRepositoryProvider = Provider<WalletsRepository>((ref) {
  return WalletsRepositoryImpl(ref.read(walletsRemoteDataSourceProvider));
});

final getWalletsUseCaseProvider = Provider<GetWalletsUseCase>((ref) {
  return GetWalletsUseCase(ref.read(walletsRepositoryProvider));
});

final walletsProvider = FutureProvider<Result<List<WalletEntity>>>((ref) async {
  final useCase = ref.read(getWalletsUseCaseProvider);
  return useCase();
});
