import '../../../../core/utils/result.dart';
import '../entities/category_breakdown.dart';
import '../repositories/analytics_repository.dart';

class GetCategoryBreakdownUseCase {
  final AnalyticsRepository _repository;

  const GetCategoryBreakdownUseCase(this._repository);

  Future<Result<List<CategoryBreakdownEntity>>> call(int year, int month) {
    return _repository.getCategoryBreakdown(year, month);
  }
}
