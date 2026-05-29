class BudgetDetailEntity {
  final String budgetId;
  final String categoryId;
  final String categoryName;
  final int year;
  final int month;
  final double amount;

  const BudgetDetailEntity({
    required this.budgetId,
    required this.categoryId,
    required this.categoryName,
    required this.year,
    required this.month,
    required this.amount,
  });
}
