import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/providers.dart';
import '../data/dashboard_api.dart';
import '../data/datasources/dashboard_remote_data_source.dart';
import '../data/repositories/dashboard_repository_impl.dart';
import '../domain/entities/dashboard.dart';
import '../domain/repositories/dashboard_repository.dart';
import '../domain/usecases/get_dashboard_use_case.dart';
import '../../../core/utils/result.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((
  ref,
) {
  return DashboardApi(ref.read(dioProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.read(dashboardRemoteDataSourceProvider));
});

final getDashboardUseCaseProvider = Provider<GetDashboardUseCase>((ref) {
  return GetDashboardUseCase(ref.read(dashboardRepositoryProvider));
});

final dashboardProvider = FutureProvider<Result<DashboardEntity>>((ref) async {
  final useCase = ref.read(getDashboardUseCaseProvider);
  return useCase();
});
