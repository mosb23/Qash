import '../../../../core/utils/result.dart';
import '../entities/date_range_summary.dart';
import '../repositories/analytics_repository.dart';

class GetDateRangeSummaryUseCase {
  final AnalyticsRepository _repository;

  const GetDateRangeSummaryUseCase(this._repository);

  Future<Result<DateRangeSummaryEntity>> call(
    DateTime fromUtc,
    DateTime toUtc,
  ) {
    return _repository.getDateRangeSummary(fromUtc, toUtc);
  }
}
