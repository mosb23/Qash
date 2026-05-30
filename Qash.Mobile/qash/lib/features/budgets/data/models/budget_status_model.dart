import '../../domain/entities/budget_status.dart';

class BudgetStatusModel extends BudgetStatusEntity {
  const BudgetStatusModel({
    required super.budgetId,
    required super.categoryId,
    required super.categoryName,
    required super.year,
    required super.month,
    required super.budgetAmount,
    required super.spentAmount,
    required super.remainingAmount,
    super.currency,
  });

  factory BudgetStatusModel.fromJson(Map<String, dynamic> json) {
    return BudgetStatusModel(
      budgetId: json['budgetId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      year: json['year'] as int? ?? 0,
      month: json['month'] as int? ?? 0,
      budgetAmount: (json['budgetAmount'] as num?)?.toDouble() ?? 0,
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'USD',
    );
  }
}
