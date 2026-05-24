import '../../../../core/utils/result.dart';
import '../entities/category.dart';
import '../repositories/categories_repository.dart';

class GetCategoriesUseCase {
  final CategoriesRepository _repository;

  const GetCategoriesUseCase(this._repository);

  Future<Result<List<CategoryEntity>>> call() {
    return _repository.getCategories();
  }
}
