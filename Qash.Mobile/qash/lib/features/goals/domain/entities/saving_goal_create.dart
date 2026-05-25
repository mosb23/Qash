class SavingGoalCreateData {
  final String name;
  final double targetAmount;
  final DateTime deadline;
  final String colorHex;

  const SavingGoalCreateData({
    required this.name,
    required this.targetAmount,
    required this.deadline,
    required this.colorHex,
  });
}
