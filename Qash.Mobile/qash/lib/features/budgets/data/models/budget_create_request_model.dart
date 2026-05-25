import '../../domain/entities/budget_create.dart';

class BudgetCreateRequestModel {
  final String userId;
  final String categoryId;
  final int year;
  final int month;
  final double amount;

  const BudgetCreateRequestModel({
    required this.userId,
    required this.categoryId,
    required this.year,
    required this.month,
    required this.amount,
  });

  factory BudgetCreateRequestModel.fromDomain(BudgetCreateData data) {
    return BudgetCreateRequestModel(
      userId: data.userId,
      categoryId: data.categoryId,
      year: data.year,
      month: data.month,
      amount: data.amount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'categoryId': categoryId,
      'year': year,
      'month': month,
      'amount': amount,
    };
  }
}
