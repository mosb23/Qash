import '../../domain/entities/transaction_update.dart';

class TransactionUpdateRequestModel {
  final String userId;
  final String walletId;
  final double amount;
  final int transactionType;
  final String categoryId;
  final String description;
  final DateTime transactionDate;

  const TransactionUpdateRequestModel({
    required this.userId,
    required this.walletId,
    required this.amount,
    required this.transactionType,
    required this.categoryId,
    required this.description,
    required this.transactionDate,
  });

  factory TransactionUpdateRequestModel.fromDomain(TransactionUpdateData data) {
    return TransactionUpdateRequestModel(
      userId: data.userId,
      walletId: data.walletId,
      amount: data.amount,
      transactionType: data.transactionType,
      categoryId: data.categoryId,
      description: data.description,
      transactionDate: data.transactionDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'walletId': walletId,
      'amount': amount,
      'transactionType': transactionType,
      'categoryId': categoryId,
      'description': description,
      'transactionDate': transactionDate.toUtc().toIso8601String(),
    };
  }
}
