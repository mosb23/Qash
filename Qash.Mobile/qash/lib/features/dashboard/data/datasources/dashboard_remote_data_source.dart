import '../../../../core/network/api_response.dart';
import '../models/dashboard_model.dart';

abstract class DashboardRemoteDataSource {
  Future<ApiResponse<DashboardModel>> getDashboard();
}
