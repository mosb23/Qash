import '../../../../core/network/api_response.dart';
import '../models/wallet_model.dart';

abstract class WalletsRemoteDataSource {
  Future<ApiResponse<List<WalletModel>>> getWallets();
}
