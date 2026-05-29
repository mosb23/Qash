import '../../../../core/utils/result.dart';
import '../repositories/transactions_repository.dart';

class DeleteTransactionUseCase {
  final TransactionsRepository _repository;

  const DeleteTransactionUseCase(this._repository);

  Future<Result<String>> call(String transactionId) {
    return _repository.deleteTransaction(transactionId);
  }
}
