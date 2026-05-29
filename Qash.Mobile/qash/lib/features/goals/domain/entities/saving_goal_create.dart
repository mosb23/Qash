class SavingGoalCreateData {
  final String name;
  final double targetAmount;
  final DateTime deadline;

  const SavingGoalCreateData({
    required this.name,
    required this.targetAmount,
    required this.deadline,
  });
}
