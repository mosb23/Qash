class DashboardEntity {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpenses;
  final double monthlyNet;
  final List<RecentTransactionEntity> recentTransactions;
  final List<TopCategoryEntity> topCategories;

  const DashboardEntity({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.monthlyNet,
    required this.recentTransactions,
    required this.topCategories,
  });
}

class RecentTransactionEntity {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String categoryName;
  final String walletName;
  final DateTime transactionDate;

  const RecentTransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryName,
    required this.walletName,
    required this.transactionDate,
  });

  bool get isIncome => type.toLowerCase() == 'income';
}

class TopCategoryEntity {
  final String categoryId;
  final String categoryName;
  final double totalAmount;
  final double percentage;

  const TopCategoryEntity({
    required this.categoryId,
    required this.categoryName,
    required this.totalAmount,
    required this.percentage,
  });
}
