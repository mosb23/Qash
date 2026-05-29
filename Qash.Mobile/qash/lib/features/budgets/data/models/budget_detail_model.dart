import '../../domain/entities/budget_detail.dart';

class BudgetDetailModel extends BudgetDetailEntity {
  const BudgetDetailModel({
    required super.budgetId,
    required super.categoryId,
    required super.categoryName,
    required super.year,
    required super.month,
    required super.amount,
  });

  factory BudgetDetailModel.fromJson(Map<String, dynamic> json) {
    return BudgetDetailModel(
      budgetId: json['budgetId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      year: json['year'] as int? ?? 0,
      month: json['month'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
    );
  }
}
