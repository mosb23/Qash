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
      if (value.toInt() == 1) {
        return CategoryType.income;
      }
      if (value.toInt() == 2) {
        return CategoryType.expense;
      }
      return CategoryType.transfer;
    }
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'income') {
        return CategoryType.income;
      }
      if (normalized == 'expense') {
        return CategoryType.expense;
      }
      if (normalized == 'transfer') {
        return CategoryType.transfer;
      }
      final asInt = int.tryParse(value);
      if (asInt == 1) {
        return CategoryType.income;
      }
      if (asInt == 2) {
        return CategoryType.expense;
      }
      if (asInt == 3) {
        return CategoryType.transfer;
      }
    }
    return CategoryType.expense;
  }
}
