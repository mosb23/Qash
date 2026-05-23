import '../../domain/entities/dashboard.dart';

class DashboardModel extends DashboardEntity {
  const DashboardModel({
    required super.totalBalance,
    required super.monthlyIncome,
    required super.monthlyExpenses,
    required super.monthlyNet,
    required super.recentTransactions,
    required super.topCategories,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalBalance: (json['totalBalance'] as num?)?.toDouble() ?? 0,
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0,
      monthlyExpenses: (json['monthlyExpenses'] as num?)?.toDouble() ?? 0,
      monthlyNet: (json['monthlyNet'] as num?)?.toDouble() ?? 0,
      recentTransactions: (json['recentTransactions'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                RecentTransactionModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      topCategories: (json['topCategories'] as List<dynamic>? ?? [])
          .map(
            (item) => TopCategoryModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class RecentTransactionModel extends RecentTransactionEntity {
  const RecentTransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.type,
    required super.categoryName,
    required super.walletName,
    required super.transactionDate,
  });

  factory RecentTransactionModel.fromJson(Map<String, dynamic> json) {
    return RecentTransactionModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      type: json['type']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      walletName: json['walletName']?.toString() ?? '',
      transactionDate: _parseDate(json['transactionDate']),
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

class TopCategoryModel extends TopCategoryEntity {
  const TopCategoryModel({
    required super.categoryId,
    required super.categoryName,
    required super.totalAmount,
    required super.percentage,
  });

  factory TopCategoryModel.fromJson(Map<String, dynamic> json) {
    return TopCategoryModel(
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
    );
  }
}
