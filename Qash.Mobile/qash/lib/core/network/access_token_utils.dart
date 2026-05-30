import 'dart:convert';

/// Returns true when the JWT access token is missing, malformed, or expired.
bool isAccessTokenExpired(
  String token, {
  Duration refreshBuffer = const Duration(minutes: 1),
}) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) {
      return true;
    }

    final normalized = base64Url.normalize(parts[1]);
    final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
    if (payload is! Map<String, dynamic>) {
      return true;
    }

    final exp = payload['exp'];
    if (exp is! num) {
      return true;
    }

    final expiry = DateTime.fromMillisecondsSinceEpoch(
      exp.toInt() * 1000,
      isUtc: true,
    );
    return DateTime.now().toUtc().add(refreshBuffer).isAfter(expiry);
  } catch (_) {
    return true;
  }
}

bool isProtectedApiPath(String path) {
  return path.startsWith('/api/') &&
      !path.startsWith('/api/auth/login') &&
      !path.startsWith('/api/auth/register') &&
      !path.startsWith('/api/auth/refresh-token') &&
      !path.startsWith('/api/auth/logout') &&
      !path.startsWith('/api/auth/verify-phone') &&
      !path.startsWith('/api/auth/forgot-password/');
}
