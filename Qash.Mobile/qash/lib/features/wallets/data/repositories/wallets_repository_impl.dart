import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/entities/wallet_create.dart';
import '../../domain/entities/wallet_update.dart';
import '../../domain/repositories/wallets_repository.dart';
import '../datasources/wallets_remote_data_source.dart';
import '../models/wallet_create_request_model.dart';
import '../models/wallet_update_request_model.dart';

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

  @override
  Future<Result<WalletEntity>> createWallet(WalletCreateData data) async {
    final response = await _remoteDataSource.createWallet(
      WalletCreateRequestModel.fromDomain(data),
    );

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }

  @override
  Future<Result<WalletEntity>> updateWallet(WalletUpdateData data) async {
    final response = await _remoteDataSource.updateWallet(
      data.walletId,
      WalletUpdateRequestModel.fromDomain(data),
    );

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }

  @override
  Future<Result<String>> deleteWallet(String walletId) async {
    final response = await _remoteDataSource.deleteWallet(walletId);

    if (response.success) {
      return Result.success(response.data ?? response.message);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }
}
