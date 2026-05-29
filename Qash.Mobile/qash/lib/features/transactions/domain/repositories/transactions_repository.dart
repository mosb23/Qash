import '../../../../core/utils/result.dart';
import '../entities/transaction_create.dart';
import '../entities/transaction.dart';

abstract class TransactionsRepository {
  Future<Result<List<TransactionEntity>>> getTransactions();

  Future<Result<TransactionEntity>> getTransactionById(String transactionId);

  Future<Result<TransactionEntity>> createTransaction(
    TransactionCreateData data,
  );

  Future<Result<String>> deleteTransaction(String transactionId);
}
