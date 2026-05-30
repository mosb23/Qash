import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_state.dart';
import '../core/network/auth_interceptor.dart';
import '../core/network/dio_provider.dart';
import '../core/network/session_expired_handler.dart';
import '../core/storage/secure_storage_service.dart';
import '../core/network/token_refresh_service.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final appInitializationProvider = FutureProvider<void>((ref) async {
  globalSessionExpiredHandler = () async {
    ref.read(authStatusProvider.notifier).setUnauthenticated();
  };
  final storage = ref.read(secureStorageProvider);
  await ref.read(authStatusProvider.notifier).bootstrap(
        tryRefreshSession: () => tryRefreshTokens(storage),
      );
});

final dioProvider = Provider<Dio>((ref) {
  final dio = DioProvider.dio;
  final storage = ref.read(secureStorageProvider);
  final hasInterceptor = dio.interceptors.any(
    (element) => element is AuthInterceptor,
  );
  if (!hasInterceptor) {
    dio.interceptors.add(
      AuthInterceptor(
        storage,
        onRefreshSession: () => tryRefreshTokens(storage),
      ),
    );
  }
  return dio;
});
