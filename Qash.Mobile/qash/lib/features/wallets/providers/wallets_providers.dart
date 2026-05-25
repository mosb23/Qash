import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/providers.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/wallets_remote_data_source.dart';
import '../data/repositories/wallets_repository_impl.dart';
import '../data/wallets_api.dart';
import '../domain/entities/wallet.dart';
import '../domain/repositories/wallets_repository.dart';
import '../domain/usecases/create_wallet_use_case.dart';
import '../domain/usecases/delete_wallet_use_case.dart';
import '../domain/usecases/get_wallets_use_case.dart';
import '../domain/usecases/update_wallet_use_case.dart';

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

final createWalletUseCaseProvider = Provider<CreateWalletUseCase>((ref) {
  return CreateWalletUseCase(ref.read(walletsRepositoryProvider));
});

final updateWalletUseCaseProvider = Provider<UpdateWalletUseCase>((ref) {
  return UpdateWalletUseCase(ref.read(walletsRepositoryProvider));
});

final deleteWalletUseCaseProvider = Provider<DeleteWalletUseCase>((ref) {
  return DeleteWalletUseCase(ref.read(walletsRepositoryProvider));
});

final walletsProvider = FutureProvider<Result<List<WalletEntity>>>((ref) async {
  final useCase = ref.read(getWalletsUseCaseProvider);
  return useCase();
});
