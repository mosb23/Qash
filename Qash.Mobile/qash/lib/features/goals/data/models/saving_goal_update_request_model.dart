import '../../domain/entities/saving_goal_update.dart';

class SavingGoalUpdateRequestModel {
  final String name;
  final double targetAmount;
  final DateTime deadline;

  const SavingGoalUpdateRequestModel({
    required this.name,
    required this.targetAmount,
    required this.deadline,
  });

  factory SavingGoalUpdateRequestModel.fromDomain(SavingGoalUpdateData data) {
    return SavingGoalUpdateRequestModel(
      name: data.name,
      targetAmount: data.targetAmount,
      deadline: data.deadline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'deadline': deadline.toUtc().toIso8601String(),
    };
  }
}
