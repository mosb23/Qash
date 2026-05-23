class WalletEntity {
  final String walletId;
  final String name;
  final String currency;
  final double balance;
  final String userId;

  const WalletEntity({
    required this.walletId,
    required this.name,
    required this.currency,
    required this.balance,
    required this.userId,
  });
}
