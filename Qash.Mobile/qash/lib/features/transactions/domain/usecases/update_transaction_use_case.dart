import '../../../../core/utils/result.dart';
import '../entities/transaction.dart';
import '../entities/transaction_update.dart';
import '../repositories/transactions_repository.dart';

class UpdateTransactionUseCase {
  final TransactionsRepository _repository;

  const UpdateTransactionUseCase(this._repository);

  Future<Result<TransactionEntity>> call(TransactionUpdateData data) {
    return _repository.updateTransaction(data);
  }
}
