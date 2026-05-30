enum TransactionType { income, expense, transfer }

class TransactionEntity {
  final String id;
  final String walletId;
  final String walletName;
  final String? toWalletId;
  final String? toWalletName;
  final String? transferGroupId;
  final String? linkedTransactionId;
  final String userId;
  final double amount;
  final double? toAmount;
  final String walletCurrency;
  final String? toWalletCurrency;
  final String sourceCurrency;
  final String? destinationCurrency;
  final double amountInBaseCurrency;
  final double? exchangeRateUsed;
  final TransactionType type;
  final String categoryId;
  final String categoryName;
  final String? description;
  final DateTime transactionDate;

  const TransactionEntity({
    required this.id,
    required this.walletId,
    required this.walletName,
    this.toWalletId,
    this.toWalletName,
    this.transferGroupId,
    this.linkedTransactionId,
    required this.userId,
    required this.amount,
    this.toAmount,
    this.walletCurrency = 'USD',
    this.toWalletCurrency,
    this.sourceCurrency = 'USD',
    this.destinationCurrency,
    this.amountInBaseCurrency = 0,
    this.exchangeRateUsed,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    this.description,
    required this.transactionDate,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isTransfer => type == TransactionType.transfer;

  /// Paired transfer leg (expense on source + income on destination).
  bool get isTransferLinked =>
      transferGroupId != null && transferGroupId!.isNotEmpty;

  /// Exclude from global income/expense/net analytics to avoid double counting.
  bool get excludeFromGlobalTotals => isTransfer || isTransferLinked;

  bool get isCrossCurrencyTransfer =>
      isTransfer &&
      toWalletCurrency != null &&
      toWalletCurrency!.isNotEmpty &&
      walletCurrency.isNotEmpty &&
      toWalletCurrency!.toUpperCase() != walletCurrency.toUpperCase();

  double get creditAmount => toAmount ?? amount;
}
