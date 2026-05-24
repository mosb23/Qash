enum CategoryType { income, expense }

class CategoryEntity {
  final String id;
  final String name;
  final CategoryType type;
  final String? icon;
  final String? color;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
  });
}
