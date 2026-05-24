import '../../../../core/utils/result.dart';
import '../entities/transaction_create.dart';
import '../entities/transaction.dart';

abstract class TransactionsRepository {
  Future<Result<List<TransactionEntity>>> getTransactions();

  Future<Result<String>> createTransaction(TransactionCreateData data);
}
