import '../../../../core/utils/result.dart';
import '../entities/wallet.dart';

abstract class WalletsRepository {
  Future<Result<List<WalletEntity>>> getWallets();
}
