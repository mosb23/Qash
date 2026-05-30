import '../../domain/entities/budget_update.dart';

class BudgetUpdateRequestModel {
  final String userId;
  final String categoryId;
  final int year;
  final int month;
  final double amount;

  const BudgetUpdateRequestModel({
    required this.userId,
    required this.categoryId,
    required this.year,
    required this.month,
    required this.amount,
  });

  factory BudgetUpdateRequestModel.fromDomain(BudgetUpdateData data) {
    return BudgetUpdateRequestModel(
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
