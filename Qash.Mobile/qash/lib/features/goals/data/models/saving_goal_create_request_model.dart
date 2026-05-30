import '../../domain/entities/saving_goal_create.dart';

class SavingGoalCreateRequestModel {
  final String name;
  final double targetAmount;
  final DateTime deadline;

  const SavingGoalCreateRequestModel({
    required this.name,
    required this.targetAmount,
    required this.deadline,
  });

  factory SavingGoalCreateRequestModel.fromDomain(SavingGoalCreateData data) {
    return SavingGoalCreateRequestModel(
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
