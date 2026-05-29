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

  Future<void> bootstrap() async {
    final token = await _storage.getAccessToken();
    state = token != null && token.isNotEmpty
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
