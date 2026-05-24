import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/categories_repository.dart';
import '../datasources/categories_remote_data_source.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource _remoteDataSource;

  const CategoriesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<CategoryEntity>>> getCategories() async {
    final response = await _remoteDataSource.getCategories();

    if (response.success && response.data != null) {
      return Result.success(response.data!);
    }

    return Result.failure(
      AppFailure(message: response.message, errors: response.errors),
    );
  }
}
