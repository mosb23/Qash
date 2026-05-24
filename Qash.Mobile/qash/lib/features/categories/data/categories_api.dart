import 'package:dio/dio.dart';

import '../../../core/network/api_response.dart';
import 'datasources/categories_remote_data_source.dart';
import 'models/category_model.dart';

class CategoriesApi implements CategoriesRemoteDataSource {
  final Dio _dio;

  const CategoriesApi(this._dio);

  @override
  Future<ApiResponse<List<CategoryModel>>> getCategories() async {
    try {
      final response = await _dio.get('/api/categories');
      final data = response.data as Map<String, dynamic>;
      return ApiResponse<List<CategoryModel>>.fromJson(data, (json) {
        final items = json as List<dynamic>? ?? [];
        return items
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      });
    } on DioException catch (error) {
      return _handleError<List<CategoryModel>>(error);
    }
  }

  ApiResponse<T> _handleError<T>(DioException error) {
    final response = error.response?.data;
    if (response is Map<String, dynamic>) {
      return ApiResponse<T>.fromJson(response, null);
    }
    return ApiResponse<T>.failure('Request failed. Please try again.');
  }
}
