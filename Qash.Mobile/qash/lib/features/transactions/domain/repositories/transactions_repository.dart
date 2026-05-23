import '../../../../core/utils/result.dart';
import '../entities/transaction.dart';

abstract class TransactionsRepository {
  Future<Result<List<TransactionEntity>>> getTransactions();
}
