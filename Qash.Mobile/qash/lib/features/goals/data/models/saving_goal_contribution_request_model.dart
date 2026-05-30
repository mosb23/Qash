import '../../domain/entities/saving_goal_contribution.dart';

class SavingGoalContributionRequestModel {
  final double amountUsd;
  final double inputAmount;
  final String inputCurrency;

  const SavingGoalContributionRequestModel({
    required this.amountUsd,
    required this.inputAmount,
    required this.inputCurrency,
  });

  factory SavingGoalContributionRequestModel.fromDomain(
    SavingGoalContributionData data,
  ) {
    return SavingGoalContributionRequestModel(
      amountUsd: data.amountUsd,
      inputAmount: data.inputAmount,
      inputCurrency: data.inputCurrency,
    );
  }

  Map<String, dynamic> toJson() {
    final currency = inputCurrency.trim().toUpperCase();
    return {
      // Legacy fields: amount is always USD to persist.
      'amount': amountUsd,
      'currency': currency,
      'amountInBaseCurrency': amountUsd,
      'inputAmount': inputAmount,
      'inputCurrency': currency,
    };
  }
}
