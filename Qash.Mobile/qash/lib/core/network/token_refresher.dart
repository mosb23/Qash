import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';

class TokenRefresher {
  TokenRefresher(this._storage);

  final SecureStorageService _storage;
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['BASE_URL'] ?? '',
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Completer<bool>? _refreshCompleter;

  Future<bool> refresh() async {
    final inFlightRefresh = _refreshCompleter;
    if (inFlightRefresh != null) {
      return inFlightRefresh.future;
    }

    final completer = _refreshCompleter = Completer<bool>();
    try {
      final refreshed = await _performRefresh();
      completer.complete(refreshed);
      return refreshed;
    } catch (_) {
      completer.complete(false);
      return false;
    } finally {
      if (identical(_refreshCompleter, completer)) {
        _refreshCompleter = null;
      }
    }
  }

  Future<bool> _performRefresh() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await _dio.post(
        '/api/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      final body = response.data;
      if (body is! Map<String, dynamic>) {
        await _storage.clearTokens();
        return false;
      }

      if (body['success'] != true) {
        await _storage.clearTokens();
        return false;
      }

      final sessionData = body['data'];
      if (sessionData is! Map<String, dynamic>) {
        await _storage.clearTokens();
        return false;
      }

      final accessToken = sessionData['accessToken']?.toString() ?? '';
      final newRefreshToken = sessionData['refreshToken']?.toString() ?? '';
      final userId = sessionData['userId']?.toString() ?? '';

      if (accessToken.isEmpty || newRefreshToken.isEmpty) {
        await _storage.clearTokens();
        return false;
      }

      if (userId.isNotEmpty) {
        await _storage.saveUserId(userId);
      }
      await _storage.saveAccessToken(accessToken);
      await _storage.saveRefreshToken(newRefreshToken);

      return true;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 400 || statusCode == 401) {
        await _storage.clearTokens();
      }
      return false;
    }
  }
}
