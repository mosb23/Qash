import '../../domain/entities/transaction.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.walletId,
    required super.walletName,
    super.toWalletId,
    super.toWalletName,
    required super.userId,
    required super.amount,
    required super.type,
    required super.categoryId,
    required super.categoryName,
    required super.description,
    required super.transactionDate,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['transactionId']?.toString() ?? '',
      walletId: json['walletId']?.toString() ?? '',
      walletName: json['walletName']?.toString() ?? '',
      toWalletId: json['toWalletId']?.toString(),
      toWalletName: json['toWalletName']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      type: _parseTransactionType(json['transactionType']),
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      transactionDate: _parseDate(json['transactionDate']),
    );
  }

  static TransactionType _parseTransactionType(dynamic value) {
    if (value is num) {
      switch (value.toInt()) {
        case 1:
          return TransactionType.income;
        case 3:
          return TransactionType.transfer;
        default:
          return TransactionType.expense;
      }
    }
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'income') {
        return TransactionType.income;
      }
      if (normalized == 'transfer') {
        return TransactionType.transfer;
      }
      if (normalized == 'expense') {
        return TransactionType.expense;
      }
      final asInt = int.tryParse(value);
      if (asInt == 1) {
        return TransactionType.income;
      }
      if (asInt == 3) {
        return TransactionType.transfer;
      }
    }
    return TransactionType.expense;
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
