import '../../../../core/utils/result.dart';
import '../entities/dashboard.dart';

abstract class DashboardRepository {
  Future<Result<DashboardEntity>> getDashboard();
}
