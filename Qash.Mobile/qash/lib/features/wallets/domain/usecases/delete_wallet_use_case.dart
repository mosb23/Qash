import '../../../../core/utils/result.dart';
import '../repositories/wallets_repository.dart';

class DeleteWalletUseCase {
  final WalletsRepository _repository;

  const DeleteWalletUseCase(this._repository);

  Future<Result<String>> call(String walletId) {
    return _repository.deleteWallet(walletId);
  }
}
