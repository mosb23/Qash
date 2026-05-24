import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/providers.dart';
import '../../../core/utils/result.dart';
import '../data/categories_api.dart';
import '../data/datasources/categories_remote_data_source.dart';
import '../data/repositories/categories_repository_impl.dart';
import '../domain/entities/category.dart';
import '../domain/repositories/categories_repository.dart';
import '../domain/usecases/get_categories_use_case.dart';

final categoriesRemoteDataSourceProvider = Provider<CategoriesRemoteDataSource>(
  (ref) {
    return CategoriesApi(ref.read(dioProvider));
  },
);

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepositoryImpl(ref.read(categoriesRemoteDataSourceProvider));
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.read(categoriesRepositoryProvider));
});

final categoriesProvider = FutureProvider<Result<List<CategoryEntity>>>((
  ref,
) async {
  final useCase = ref.read(getCategoriesUseCaseProvider);
  return useCase();
});
