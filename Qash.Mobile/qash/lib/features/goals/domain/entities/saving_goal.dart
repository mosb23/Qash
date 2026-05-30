class SavingGoalEntity {
  final String savingGoalId;
  final String name;

  /// Stored in USD (base currency).
  final double targetAmount;

  /// Stored in USD (base currency).
  final double currentAmount;
  final DateTime deadline;
  final double progressPercent;
  final String colorHex;
  /// Always USD for new goals; legacy field from older builds.
  final String currency;

  const SavingGoalEntity({
    required this.savingGoalId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.progressPercent,
    required this.colorHex,
    this.currency = '',
  });

  double get progress => (progressPercent / 100).clamp(0, 1);
}
