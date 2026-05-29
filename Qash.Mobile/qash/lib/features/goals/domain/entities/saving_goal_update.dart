class SavingGoalUpdateData {
  final String savingGoalId;
  final String name;
  final double targetAmount;
  final DateTime deadline;

  const SavingGoalUpdateData({
    required this.savingGoalId,
    required this.name,
    required this.targetAmount,
    required this.deadline,
  });
}
