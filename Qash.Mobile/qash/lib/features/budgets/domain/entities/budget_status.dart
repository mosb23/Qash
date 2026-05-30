class BudgetStatusEntity {
  final String budgetId;
  final String categoryId;
  final String categoryName;
  final int year;
  final int month;
  final double budgetAmount;
  final double spentAmount;
  final double remainingAmount;
  final String currency;

  const BudgetStatusEntity({
    required this.budgetId,
    required this.categoryId,
    required this.categoryName,
    required this.year,
    required this.month,
    required this.budgetAmount,
    required this.spentAmount,
    required this.remainingAmount,
    this.currency = 'USD',
  });

  double get progress {
    if (budgetAmount <= 0) {
      return 0;
    }
    return (spentAmount / budgetAmount).clamp(0, 1);
  }

  bool get isOverBudget => spentAmount > budgetAmount;

  bool get isAtOrOverLimit =>
      budgetAmount > 0 && spentAmount >= budgetAmount;
}

class BudgetPeriod {
  final int year;
  final int month;

  const BudgetPeriod({required this.year, required this.month});
}
