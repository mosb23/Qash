import '../../../../core/utils/result.dart';
import '../entities/spending_trend.dart';
import '../repositories/analytics_repository.dart';

class GetSpendingTrendUseCase {
  final AnalyticsRepository _repository;

  const GetSpendingTrendUseCase(this._repository);

  Future<Result<List<SpendingTrendEntity>>> call(int days) {
    return _repository.getSpendingTrend(days);
  }
}
