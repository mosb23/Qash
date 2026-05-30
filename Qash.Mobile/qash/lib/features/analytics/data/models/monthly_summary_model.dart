import '../../domain/entities/monthly_summary.dart';

class MonthlySummaryModel extends MonthlySummaryEntity {
  const MonthlySummaryModel({
    required super.totalIncome,
    required super.totalExpenses,
    required super.netBalance,
    required super.transactionCount,
    super.baseCurrency,
    super.displayCurrency,
  });

  factory MonthlySummaryModel.fromJson(Map<String, dynamic> json) {
    return MonthlySummaryModel(
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0,
      netBalance: (json['netBalance'] as num?)?.toDouble() ?? 0,
      transactionCount: json['transactionCount'] as int? ?? 0,
      baseCurrency: json['baseCurrency']?.toString() ?? 'USD',
      displayCurrency: json['displayCurrency']?.toString() ?? 'USD',
    );
  }
}
