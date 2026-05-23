import '../../../../core/utils/result.dart';
import '../entities/dashboard.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardUseCase {
  final DashboardRepository _repository;

  const GetDashboardUseCase(this._repository);

  Future<Result<DashboardEntity>> call() {
    return _repository.getDashboard();
  }
}
