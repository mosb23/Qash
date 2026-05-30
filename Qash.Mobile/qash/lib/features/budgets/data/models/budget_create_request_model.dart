import '../../domain/entities/budget_create.dart';

class BudgetCreateRequestModel {
  final String categoryId;
  final int year;
  final int month;
  final double amount;
  final String currency;

  const BudgetCreateRequestModel({
    required this.categoryId,
    required this.year,
    required this.month,
    required this.amount,
    required this.currency,
  });

  factory BudgetCreateRequestModel.fromDomain(BudgetCreateData data) {
    return BudgetCreateRequestModel(
      categoryId: data.categoryId,
      year: data.year,
      month: data.month,
      amount: data.amount,
      currency: data.currency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'year': year,
      'month': month,
      'amount': amount,
      'currency': currency,
    };
  }
}
