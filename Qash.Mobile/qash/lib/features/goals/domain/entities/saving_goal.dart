class SavingGoalEntity {
  final String savingGoalId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final double progressPercent;

  const SavingGoalEntity({
    required this.savingGoalId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.progressPercent,
  });

  double get progress => (progressPercent / 100).clamp(0, 1);
}
