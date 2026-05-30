class SavingGoalContributionData {
  final String savingGoalId;

  /// USD amount added to the goal balance (canonical persisted value).
  final double amountUsd;

  /// Original amount entered by the user (for server audit / validation).
  final double inputAmount;

  /// Currency of [inputAmount].
  final String inputCurrency;

  const SavingGoalContributionData({
    required this.savingGoalId,
    required this.amountUsd,
    required this.inputAmount,
    required this.inputCurrency,
  });
}
