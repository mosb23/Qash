import '../../../../core/utils/result.dart';
import '../entities/transaction.dart';
import '../repositories/transactions_repository.dart';

class GetTransactionsUseCase {
  final TransactionsRepository _repository;

  const GetTransactionsUseCase(this._repository);

  Future<Result<List<TransactionEntity>>> call() {
    return _repository.getTransactions();
  }
}
