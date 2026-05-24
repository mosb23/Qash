import '../../domain/entities/date_range_summary.dart';

class DateRangeSummaryModel extends DateRangeSummaryEntity {
  const DateRangeSummaryModel({
    required super.fromUtc,
    required super.toUtcExclusive,
    required super.totalIncome,
    required super.totalExpenses,
    required super.net,
    required super.transactionCount,
  });

  factory DateRangeSummaryModel.fromJson(Map<String, dynamic> json) {
    return DateRangeSummaryModel(
      fromUtc: _parseDate(json['fromUtc']),
      toUtcExclusive: _parseDate(json['toUtcExclusive']),
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0,
      net: (json['net'] as num?)?.toDouble() ?? 0,
      transactionCount: json['transactionCount'] as int? ?? 0,
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
