import '../../../../core/utils/result.dart';
import '../entities/wallet.dart';
import '../repositories/wallets_repository.dart';

class GetWalletsUseCase {
  final WalletsRepository _repository;

  const GetWalletsUseCase(this._repository);

  Future<Result<List<WalletEntity>>> call() {
    return _repository.getWallets();
  }
}
