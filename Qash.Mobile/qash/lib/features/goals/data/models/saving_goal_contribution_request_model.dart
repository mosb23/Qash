import '../../domain/entities/saving_goal_contribution.dart';

class SavingGoalContributionRequestModel {
  final double amount;

  const SavingGoalContributionRequestModel({required this.amount});

  factory SavingGoalContributionRequestModel.fromDomain(
    SavingGoalContributionData data,
  ) {
    return SavingGoalContributionRequestModel(amount: data.amount);
  }

  Map<String, dynamic> toJson() {
    return {'amount': amount};
  }
}
