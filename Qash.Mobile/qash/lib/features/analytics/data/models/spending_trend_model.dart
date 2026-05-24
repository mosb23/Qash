import '../../domain/entities/spending_trend.dart';

class SpendingTrendModel extends SpendingTrendEntity {
  const SpendingTrendModel({required super.date, required super.totalExpenses});

  factory SpendingTrendModel.fromJson(Map<String, dynamic> json) {
    return SpendingTrendModel(
      date: _parseDate(json['date']),
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0,
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
