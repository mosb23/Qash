class BudgetCreateData {
  final String userId;
  final String categoryId;
  final double amount;
  final int year;
  final int month;

  const BudgetCreateData({
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.year,
    required this.month,
  });
}
