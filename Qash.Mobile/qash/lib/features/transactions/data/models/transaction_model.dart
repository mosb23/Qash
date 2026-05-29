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
    super.toAmount,
    super.walletCurrency,
    super.toWalletCurrency,
    required super.type,
    required super.categoryId,
    required super.categoryName,
    required super.description,
    required super.transactionDate,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: _readString(json, 'transactionId') ?? '',
      walletId: _readString(json, 'walletId') ?? '',
      walletName: _readString(json, 'walletName') ?? '',
      toWalletId: _readString(json, 'toWalletId'),
      toWalletName: _readString(json, 'toWalletName'),
      userId: _readString(json, 'userId') ?? '',
      amount: _readDouble(json, 'amount') ?? 0,
      toAmount: _readDouble(json, 'toAmount'),
      walletCurrency: _readString(json, 'walletCurrency') ?? 'USD',
      toWalletCurrency: _readString(json, 'toWalletCurrency'),
      type: _parseTransactionType(json['transactionType']),
      categoryId: _readString(json, 'categoryId') ?? '',
      categoryName: _readString(json, 'categoryName') ?? '',
      description: _readString(json, 'description') ?? '',
      transactionDate: _parseDate(json['transactionDate']),
    );
  }

  static String? _readString(Map<String, dynamic> json, String key) {
    final camel = json[key];
    if (camel != null) {
      return camel.toString();
    }
    final pascal = json[_pascalCase(key)];
    return pascal?.toString();
  }

  static double? _readDouble(Map<String, dynamic> json, String key) {
    final camel = json[key];
    if (camel is num) {
      return camel.toDouble();
    }
    final pascal = json[_pascalCase(key)];
    if (pascal is num) {
      return pascal.toDouble();
    }
    return null;
  }

  static String _pascalCase(String key) {
    if (key.isEmpty) {
      return key;
    }
    return key[0].toUpperCase() + key.substring(1);
  }

  static TransactionType _parseTransactionType(dynamic value) {
    if (value is num) {
      if (value.toInt() == 1) {
        return TransactionType.income;
      }
      if (value.toInt() == 2) {
        return TransactionType.expense;
      }
      return TransactionType.transfer;
    }
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'income') {
        return TransactionType.income;
      }
      if (normalized == 'expense') {
        return TransactionType.expense;
      }
      if (normalized == 'transfer') {
        return TransactionType.transfer;
      }
      final asInt = int.tryParse(value);
      if (asInt == 1) {
        return TransactionType.income;
      }
      if (asInt == 2) {
        return TransactionType.expense;
      }
      if (asInt == 3) {
        return TransactionType.transfer;
      }
    }
    return TransactionType.expense;
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) {
      return value.isUtc ? value.toLocal() : value;
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed == null) {
        return DateTime.now();
      }
      return parsed.isUtc ? parsed.toLocal() : parsed;
    }
    return DateTime.now();
  }
}
