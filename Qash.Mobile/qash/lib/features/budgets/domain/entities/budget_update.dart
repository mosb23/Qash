class BudgetUpdateData {
  final String budgetId;
  final String userId;
  final String categoryId;
  final int year;
  final int month;
  final double amount;

  const BudgetUpdateData({
    required this.budgetId,
    required this.userId,
    required this.categoryId,
    required this.year,
    required this.month,
    required this.amount,
  });
}
