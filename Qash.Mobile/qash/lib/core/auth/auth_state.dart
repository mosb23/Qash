import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/providers.dart';
import '../storage/secure_storage_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

final authStatusProvider =
    StateNotifierProvider<AuthStatusNotifier, AuthStatus>((ref) {
  return AuthStatusNotifier(ref.read(secureStorageProvider));
});

class AuthStatusNotifier extends StateNotifier<AuthStatus> {
  AuthStatusNotifier(this._storage) : super(AuthStatus.unknown);

  final SecureStorageService _storage;

  /// Restores session from secure storage. When a refresh token exists,
  /// attempts refresh so expired access tokens recover on cold start.
  Future<void> bootstrap({Future<bool> Function()? tryRefreshSession}) async {
    final accessToken = await _storage.getAccessToken();
    final refreshToken = await _storage.getRefreshToken();

    if (accessToken == null || accessToken.isEmpty) {
      state = AuthStatus.unauthenticated;
      return;
    }

    if (tryRefreshSession != null &&
        refreshToken != null &&
        refreshToken.isNotEmpty) {
      final refreshed = await tryRefreshSession();
      if (!refreshed) {
        await _storage.clearTokens();
        state = AuthStatus.unauthenticated;
        return;
      }
    }

    final tokenAfterRefresh = await _storage.getAccessToken();
    state = tokenAfterRefresh != null && tokenAfterRefresh.isNotEmpty
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
  }

  void setAuthenticated() {
    state = AuthStatus.authenticated;
  }

  void setUnauthenticated() {
    state = AuthStatus.unauthenticated;
  }

  Future<bool> hasValidSession() async {
    final token = await _storage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

/// Notifies [GoRouter] when auth status changes.
final authRefreshListenableProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier(0);
  ref.listen<AuthStatus>(authStatusProvider, (_, _) {
    notifier.value++;
  });
  return notifier;
});
