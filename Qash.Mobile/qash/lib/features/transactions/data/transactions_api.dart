import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import 'datasources/transactions_remote_data_source.dart';
import 'models/transaction_create_request_model.dart';
import 'models/transaction_model.dart';

class TransactionsApi implements TransactionsRemoteDataSource {
  final Dio _dio;

  const TransactionsApi(this._dio);

  @override
  Future<ApiResponse<List<TransactionModel>>> getTransactions() async {
    try {
      final response = await _dio.get('/api/transactions');
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<List<TransactionModel>>.fromJson(data, (json) {
        final items = json as List<dynamic>? ?? [];
        return items
            .map(
              (item) => TransactionModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      });
    } on DioException catch (error) {
      return _handleError<List<TransactionModel>>(error);
    }
  }

  @override
  Future<ApiResponse<String>> createTransaction(
    TransactionCreateRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/transactions',
        data: request.toJson(),
      );
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
