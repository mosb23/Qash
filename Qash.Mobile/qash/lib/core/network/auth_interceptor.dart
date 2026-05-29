import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';
import 'dio_provider.dart';
import 'session_expired_handler.dart';

typedef RefreshSessionCallback = Future<bool> Function();

class AuthInterceptor extends Interceptor {
  AuthInterceptor(
    this._storage, {
    required this.onRefreshSession,
  });

  final SecureStorageService _storage;
  final RefreshSessionCallback onRefreshSession;

  Future<bool>? _refreshInFlight;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final path = err.requestOptions.path;
    if (path.contains('/api/auth/login') ||
        path.contains('/api/auth/register') ||
        path.contains('/api/auth/refresh-token') ||
        path.contains('/api/auth/verify-phone')) {
      handler.next(err);
      return;
    }

    try {
      final refreshed = await _refreshSessionOnce();
      if (!refreshed) {
        await _handleSessionExpired();
        handler.next(err);
        return;
      }

      final token = await _storage.getAccessToken();
      final retryOptions = err.requestOptions;
      if (token != null && token.isNotEmpty) {
        retryOptions.headers['Authorization'] = 'Bearer $token';
      }

      final client = Dio(DioProvider.dio.options);
      final retryResponse = await client.fetch(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      await _handleSessionExpired();
      handler.next(err);
    }
  }

  Future<bool> _refreshSessionOnce() {
    if (_refreshInFlight != null) {
      return _refreshInFlight!;
    }

    _refreshInFlight = onRefreshSession();
    return _refreshInFlight!.whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<void> _handleSessionExpired() async {
    await _storage.clearTokens();
    final callback = globalSessionExpiredHandler;
    if (callback != null) {
      await callback();
    }
  }
}
