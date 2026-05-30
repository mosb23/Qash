class SavingGoalCreateData {
  final String name;
  final double targetAmount;
  final DateTime deadline;
  final String colorHex;
  final String currency;
  final double initialAmount;

  const SavingGoalCreateData({
    required this.name,
    required this.targetAmount,
    required this.deadline,
    required this.colorHex,
    this.currency = '',
    this.initialAmount = 0,
  });
}
