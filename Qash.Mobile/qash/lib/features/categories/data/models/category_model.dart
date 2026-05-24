import '../../domain/entities/category.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.type,
    super.icon,
    super.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: _parseCategoryType(json['type']),
      icon: json['icon']?.toString(),
      color: json['color']?.toString(),
    );
  }

  static CategoryType _parseCategoryType(dynamic value) {
    if (value is num) {
      return value.toInt() == 1 ? CategoryType.income : CategoryType.expense;
    }
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'income') {
        return CategoryType.income;
      }
      if (normalized == 'expense') {
        return CategoryType.expense;
      }
      final asInt = int.tryParse(value);
      if (asInt == 1) {
        return CategoryType.income;
      }
    }
    return CategoryType.expense;
  }
}
