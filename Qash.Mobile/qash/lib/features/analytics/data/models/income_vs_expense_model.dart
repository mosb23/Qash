import '../../domain/entities/income_vs_expense.dart';

class IncomeVsExpenseModel extends IncomeVsExpenseEntity {
  const IncomeVsExpenseModel({
    required super.month,
    required super.income,
    required super.expenses,
  });

  factory IncomeVsExpenseModel.fromJson(Map<String, dynamic> json) {
    return IncomeVsExpenseModel(
      month: json['month'] as int? ?? 0,
      income: (json['income'] as num?)?.toDouble() ?? 0,
      expenses: (json['expenses'] as num?)?.toDouble() ?? 0,
    );
  }
}
