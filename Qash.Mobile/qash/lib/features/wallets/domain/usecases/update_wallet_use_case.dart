import '../../../../core/utils/result.dart';
import '../entities/wallet.dart';
import '../entities/wallet_update.dart';
import '../repositories/wallets_repository.dart';

class UpdateWalletUseCase {
  final WalletsRepository _repository;

  const UpdateWalletUseCase(this._repository);

  Future<Result<WalletEntity>> call(WalletUpdateData data) {
    return _repository.updateWallet(data);
  }
}
