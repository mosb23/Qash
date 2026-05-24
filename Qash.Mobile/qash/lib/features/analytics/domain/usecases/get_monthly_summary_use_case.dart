import '../../../../core/utils/result.dart';
import '../entities/monthly_summary.dart';
import '../repositories/analytics_repository.dart';

class GetMonthlySummaryUseCase {
  final AnalyticsRepository _repository;

  const GetMonthlySummaryUseCase(this._repository);

  Future<Result<MonthlySummaryEntity>> call(int year, int month) {
    return _repository.getMonthlySummary(year, month);
  }
}
