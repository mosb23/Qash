import '../../../../core/utils/result.dart';
import '../entities/transaction.dart';
import '../repositories/transactions_repository.dart';

class GetTransactionByIdUseCase {
  final TransactionsRepository _repository;

  const GetTransactionByIdUseCase(this._repository);

  Future<Result<TransactionEntity>> call(String transactionId) {
    return _repository.getTransactionById(transactionId);
  }
}
