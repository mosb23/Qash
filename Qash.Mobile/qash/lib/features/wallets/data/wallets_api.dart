import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import 'datasources/wallets_remote_data_source.dart';
import 'models/wallet_create_request_model.dart';
import 'models/wallet_model.dart';
import 'models/wallet_update_request_model.dart';

class WalletsApi implements WalletsRemoteDataSource {
  final Dio _dio;

  const WalletsApi(this._dio);

  @override
  Future<ApiResponse<List<WalletModel>>> getWallets() async {
    try {
      final response = await _dio.get('/api/wallets');
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<List<WalletModel>>.fromJson(data, (json) {
        final items = json as List<dynamic>? ?? [];
        return items
            .map((item) => WalletModel.fromJson(item as Map<String, dynamic>))
            .toList();
      });
    } on DioException catch (error) {
      return _handleError<List<WalletModel>>(error);
    }
  }

  @override
  Future<ApiResponse<WalletModel>> createWallet(
    WalletCreateRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/wallets',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<WalletModel>.fromJson(
        data,
        (json) => WalletModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return _handleError<WalletModel>(error);
    }
  }

  @override
  Future<ApiResponse<WalletModel>> updateWallet(
    String walletId,
    WalletUpdateRequestModel request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/wallets/$walletId',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<WalletModel>.fromJson(
        data,
        (json) => WalletModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return _handleError<WalletModel>(error);
    }
  }

  @override
  Future<ApiResponse<String>> deleteWallet(String walletId) async {
    try {
      final response = await _dio.delete('/api/wallets/$walletId');
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<String>.fromJson(
        data,
        (json) => json?.toString() ?? '',
      );
    } on DioException catch (error) {
      return _handleError<String>(error);
    }
  }

  ApiResponse<T> _handleError<T>(DioException error) {
    final response = error.response?.data;
    if (response is Map<String, dynamic>) {
      return ApiResponse<T>.fromJson(response, null);
    }
    return ApiResponse<T>.failure('Request failed. Please try again.');
  }
}
