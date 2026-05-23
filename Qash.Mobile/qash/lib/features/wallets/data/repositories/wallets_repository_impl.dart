import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallets_repository.dart';
import '../datasources/wallets_remote_data_source.dart';

class WalletsRepositoryImpl implements WalletsRepository {
  final WalletsRemoteDataSource _remoteDataSource;

  const WalletsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<WalletEntity>>> getWallets() async {
    final response = await _remoteDataSource.getWallets();

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }
}
