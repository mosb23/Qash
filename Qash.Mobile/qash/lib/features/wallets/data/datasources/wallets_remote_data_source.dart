import '../../../../core/network/api_response.dart';
import '../models/wallet_create_request_model.dart';
import '../models/wallet_model.dart';
import '../models/wallet_update_request_model.dart';

abstract class WalletsRemoteDataSource {
  Future<ApiResponse<List<WalletModel>>> getWallets();

  Future<ApiResponse<WalletModel>> createWallet(
    WalletCreateRequestModel request,
  );

  Future<ApiResponse<WalletModel>> updateWallet(
    String walletId,
    WalletUpdateRequestModel request,
  );

  Future<ApiResponse<String>> deleteWallet(String walletId);
}
