import '../../../../core/utils/result.dart';
import '../entities/wallet.dart';
import '../entities/wallet_create.dart';
import '../entities/wallet_update.dart';

abstract class WalletsRepository {
  Future<Result<List<WalletEntity>>> getWallets();

  Future<Result<WalletEntity>> createWallet(WalletCreateData data);

  Future<Result<WalletEntity>> updateWallet(WalletUpdateData data);

  Future<Result<String>> deleteWallet(String walletId);
}
