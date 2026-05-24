class MonthlySummaryEntity {
  final double totalIncome;
  final double totalExpenses;
  final double netBalance;
  final int transactionCount;

  const MonthlySummaryEntity({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netBalance,
    required this.transactionCount,
  });
}
