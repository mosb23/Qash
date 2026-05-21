import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/auth_interceptor.dart';
import '../core/network/dio_provider.dart';
import '../core/storage/secure_storage_service.dart';

final appInitializationProvider = FutureProvider<void>((ref) async {});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = DioProvider.dio;
  final storage = ref.read(secureStorageProvider);
  final hasInterceptor = dio.interceptors.any(
    (element) => element is AuthInterceptor,
  );
  if (!hasInterceptor) {
    dio.interceptors.add(AuthInterceptor(storage));
  }
  return dio;
});
