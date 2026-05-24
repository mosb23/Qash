class DateRangeSummaryEntity {
  final DateTime fromUtc;
  final DateTime toUtcExclusive;
  final double totalIncome;
  final double totalExpenses;
  final double net;
  final int transactionCount;

  const DateRangeSummaryEntity({
    required this.fromUtc,
    required this.toUtcExclusive,
    required this.totalIncome,
    required this.totalExpenses,
    required this.net,
    required this.transactionCount,
  });
}
