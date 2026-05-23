enum TransactionType { income, expense }

class TransactionEntity {
  final String id;
  final String walletId;
  final String walletName;
  final String userId;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String categoryName;
  final String description;
  final DateTime transactionDate;

  const TransactionEntity({
    required this.id,
    required this.walletId,
    required this.walletName,
    required this.userId,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.transactionDate,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  bool get isTransfer {
    final haystack =
        '${categoryName.toLowerCase()} ${description.toLowerCase()}';
    return haystack.contains('transfer');
  }
}
