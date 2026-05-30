import '../../domain/entities/saving_goal_create.dart';
import '../../utils/saving_goal_currency.dart';

class SavingGoalCreateRequestModel {
  final String name;
  final double targetAmount;
  final DateTime deadline;
  final String colorHex;
  final String currency;
  final double initialAmount;

  const SavingGoalCreateRequestModel({
    required this.name,
    required this.targetAmount,
    required this.deadline,
    required this.colorHex,
    required this.currency,
    required this.initialAmount,
  });

  factory SavingGoalCreateRequestModel.fromDomain(SavingGoalCreateData data) {
    return SavingGoalCreateRequestModel(
      name: data.name,
      targetAmount: data.targetAmount,
      deadline: data.deadline,
      colorHex: data.colorHex,
      currency: data.currency,
      initialAmount: data.initialAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'deadline': DateTime(
        deadline.year,
        deadline.month,
        deadline.day,
        23,
        59,
        59,
      ).toUtc().toIso8601String(),
      'colorHex': colorHex,
      'currency': goalBaseCurrency,
      'initialAmount': 0,
      'currentAmount': 0,
    };
  }
}
