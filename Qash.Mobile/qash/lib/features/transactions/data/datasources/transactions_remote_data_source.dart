import '../../../../core/network/api_response.dart';
import '../models/transaction_create_request_model.dart';
import '../models/transaction_model.dart';

abstract class TransactionsRemoteDataSource {
  Future<ApiResponse<List<TransactionModel>>> getTransactions();

  Future<ApiResponse<TransactionModel>> getTransactionById(String transactionId);

  Future<ApiResponse<String>> createTransaction(
    TransactionCreateRequestModel request,
  );
}
