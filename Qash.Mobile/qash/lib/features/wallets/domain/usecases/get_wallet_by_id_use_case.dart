import '../../../../core/utils/result.dart';
import '../entities/wallet.dart';
import '../repositories/wallets_repository.dart';

class GetWalletByIdUseCase {
  final WalletsRepository _repository;

  const GetWalletByIdUseCase(this._repository);

  Future<Result<WalletEntity>> call(String walletId) {
    return _repository.getWalletById(walletId);
  }
}
