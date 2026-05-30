import '../../../../core/utils/result.dart';
import '../entities/transaction_create.dart';
import '../repositories/transactions_repository.dart';

class CreateTransactionUseCase {
  final TransactionsRepository _repository;

  const CreateTransactionUseCase(this._repository);

  Future<Result<String>> call(TransactionCreateData data) {
    return _repository.createTransaction(data);
  }
}
