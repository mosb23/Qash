import '../../../../core/errors/app_failure.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_create.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/transactions_remote_data_source.dart';
import '../models/transaction_create_request_model.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  final TransactionsRemoteDataSource _remoteDataSource;
  final SecureStorageService _storage;

  const TransactionsRepositoryImpl(this._remoteDataSource, this._storage);

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

  @override
  Future<Result<TransactionEntity>> getTransactionById(
    String transactionId,
  ) async {
    final response = await _remoteDataSource.getTransactionById(transactionId);

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }

  @override
  Future<Result<String>> deleteTransaction(String transactionId) async {
    final response = await _remoteDataSource.deleteTransaction(transactionId);

    if (response.success) {
      return Result.success(response.message);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }

  @override
  Future<Result<TransactionEntity>> createTransaction(
    TransactionCreateData data,
  ) async {
    final resolvedUserId = data.userId.isNotEmpty
        ? data.userId
        : await _storage.getUserId() ?? '';

    if (resolvedUserId.isEmpty) {
      return Result.failure(
        const AppFailure(message: 'Missing user id. Please sign in again.'),
      );
    }

    final response = await _remoteDataSource.createTransaction(
      TransactionCreateRequestModel.fromDomain(
        TransactionCreateData(
          userId: resolvedUserId,
          walletId: data.walletId,
          toWalletId: data.toWalletId,
          amount: data.amount,
          transactionType: data.transactionType,
          categoryId: data.categoryId,
          description: data.description,
          transactionDate: data.transactionDate,
        ),
      ),
    );

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }
}
