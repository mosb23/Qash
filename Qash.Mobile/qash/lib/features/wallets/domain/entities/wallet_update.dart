class WalletUpdateData {
  final String walletId;
  final String name;
  final String currency;
  final double balance;

  const WalletUpdateData({
    required this.walletId,
    required this.name,
    required this.currency,
    required this.balance,
  });
}
