import '../../../../core/network/api_response.dart';
import '../models/category_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<ApiResponse<List<CategoryModel>>> getCategories();
}
