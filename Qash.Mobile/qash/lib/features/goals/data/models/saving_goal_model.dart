import '../../domain/entities/saving_goal.dart';

class SavingGoalModel extends SavingGoalEntity {
  const SavingGoalModel({
    required super.savingGoalId,
    required super.name,
    required super.targetAmount,
    required super.currentAmount,
    required super.deadline,
    required super.progressPercent,
    required super.colorHex,
  });

  factory SavingGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingGoalModel(
      savingGoalId: json['savingGoalId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0,
      deadline: _parseDate(json['deadline']),
      progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0,
      colorHex: json['colorHex']?.toString() ?? '',
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
