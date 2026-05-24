import '../../../../core/utils/result.dart';
import '../entities/category.dart';

abstract class CategoriesRepository {
  Future<Result<List<CategoryEntity>>> getCategories();
}
