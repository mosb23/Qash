class TransactionUpdateData {
  final String transactionId;
  final String userId;
  final String walletId;
  final double amount;
  final int transactionType;
  final String categoryId;
  final String description;
  final DateTime transactionDate;

  const TransactionUpdateData({
    required this.transactionId,
    required this.userId,
    required this.walletId,
    required this.amount,
    required this.transactionType,
    required this.categoryId,
    required this.description,
    required this.transactionDate,
  });
}
