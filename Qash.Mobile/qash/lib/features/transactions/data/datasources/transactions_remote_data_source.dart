import '../../../../core/network/api_response.dart';
import '../models/transaction_model.dart';

abstract class TransactionsRemoteDataSource {
  Future<ApiResponse<List<TransactionModel>>> getTransactions();
}
