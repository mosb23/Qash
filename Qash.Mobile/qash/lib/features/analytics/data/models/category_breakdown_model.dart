import '../../domain/entities/category_breakdown.dart';

class CategoryBreakdownModel extends CategoryBreakdownEntity {
  const CategoryBreakdownModel({
    required super.categoryId,
    required super.totalAmount,
  });

  factory CategoryBreakdownModel.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownModel(
      categoryId: json['categoryId']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
    );
  }
}
