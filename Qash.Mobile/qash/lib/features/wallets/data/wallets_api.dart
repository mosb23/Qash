import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import 'datasources/wallets_remote_data_source.dart';
import 'models/wallet_model.dart';

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

  ApiResponse<T> _handleError<T>(DioException error) {
    final response = error.response?.data;
    if (response is Map<String, dynamic>) {
      return ApiResponse<T>.fromJson(response, null);
    }
    return ApiResponse<T>.failure('Request failed. Please try again.');
  }
}
