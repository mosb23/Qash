import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';
import 'dio_provider.dart';

/// Refreshes tokens using a plain Dio client (no auth interceptor).
Future<bool> tryRefreshTokens(SecureStorageService storage) async {
  final refreshToken = await storage.getRefreshToken();
  if (refreshToken == null || refreshToken.isEmpty) {
    return false;
  }

  try {
    final dio = Dio(DioProvider.dio.options);
    final response = await dio.post(
      '/api/auth/refresh-token',
      data: {'refreshToken': refreshToken},
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      return false;
    }
    if (data['success'] != true) {
      return false;
    }
    final payload = data['data'];
    if (payload is! Map<String, dynamic>) {
      return false;
    }

    final accessToken = payload['accessToken']?.toString() ?? '';
    final newRefresh = payload['refreshToken']?.toString() ?? '';
    final userId = payload['userId']?.toString() ?? '';

    if (accessToken.isEmpty) {
      return false;
    }

    await storage.saveAccessToken(accessToken);
    if (newRefresh.isNotEmpty) {
      await storage.saveRefreshToken(newRefresh);
    }
    if (userId.isNotEmpty) {
      await storage.saveUserId(userId);
    }
    return true;
  } catch (_) {
    return false;
  }
}
