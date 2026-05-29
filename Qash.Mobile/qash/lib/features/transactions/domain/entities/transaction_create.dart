class TransactionCreateData {
  final String userId;
  final String walletId;
  final String? toWalletId;
  final double amount;
  final int transactionType;
  final String categoryId;
  final String description;
  final DateTime transactionDate;

  const TransactionCreateData({
    required this.userId,
    required this.walletId,
    this.toWalletId,
    required this.amount,
    required this.transactionType,
    required this.categoryId,
    required this.description,
    required this.transactionDate,
  });
}
