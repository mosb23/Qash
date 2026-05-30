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
    super.currency,
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
      currency: _readCurrency(json),
    );
  }

  static String _readCurrency(Map<String, dynamic> json) {
    final raw = json['currency'] ?? json['Currency'];
    if (raw == null) {
      return '';
    }
    return raw.toString().trim().toUpperCase();
  }

  /// Normalizes API deadlines to the user's local calendar date (midnight).
  static DateTime _parseDate(dynamic value) {
    DateTime? parsed;
    if (value is DateTime) {
      parsed = value;
    } else if (value is String) {
      parsed = DateTime.tryParse(value);
    }
    parsed ??= DateTime.now();
    final local = parsed.isUtc ? parsed.toLocal() : parsed;
    return DateTime(local.year, local.month, local.day);
  }
}
