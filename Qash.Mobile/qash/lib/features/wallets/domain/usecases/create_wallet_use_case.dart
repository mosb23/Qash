import '../../../../core/utils/result.dart';
import '../entities/wallet.dart';
import '../entities/wallet_create.dart';
import '../repositories/wallets_repository.dart';

class CreateWalletUseCase {
  final WalletsRepository _repository;

  const CreateWalletUseCase(this._repository);

  Future<Result<WalletEntity>> call(WalletCreateData data) {
    return _repository.createWallet(data);
  }
}
