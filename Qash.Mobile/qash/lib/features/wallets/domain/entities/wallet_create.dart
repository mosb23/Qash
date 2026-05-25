class WalletCreateData {
  final String name;
  final String currency;
  final double initialBalance;

  const WalletCreateData({
    required this.name,
    required this.currency,
    required this.initialBalance,
  });
}
