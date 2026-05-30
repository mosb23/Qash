import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';
import 'access_token_utils.dart';
import 'token_refresher.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._dio, this._tokenRefresher);

  final SecureStorageService _storage;
  final Dio _dio;
  final TokenRefresher _tokenRefresher;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.uri.path;

    if (isProtectedApiPath(path)) {
      var token = await _storage.getAccessToken();

      if (token != null &&
          token.isNotEmpty &&
          isAccessTokenExpired(token)) {
        await _tokenRefresher.refresh();
        token = await _storage.getAccessToken();
      }

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldAttemptRefresh(err)) {
      handler.next(err);
      return;
    }

    final refreshed = await _tokenRefresher.refresh();
    if (!refreshed) {
      handler.next(err);
      return;
    }

    try {
      final token = await _storage.getAccessToken();
      final options = err.requestOptions;
      options.extra['retriedAfterRefresh'] = true;
      options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.fetch(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _shouldAttemptRefresh(DioException err) {
    if (err.response?.statusCode != 401) {
      return false;
    }

    if (err.requestOptions.extra['retriedAfterRefresh'] == true) {
      return false;
    }

    return isProtectedApiPath(err.requestOptions.uri.path);
  }
}
