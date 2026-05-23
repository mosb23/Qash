import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/transactions_remote_data_source.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  final TransactionsRemoteDataSource _remoteDataSource;

  const TransactionsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<TransactionEntity>>> getTransactions() async {
    final response = await _remoteDataSource.getTransactions();

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }
}
