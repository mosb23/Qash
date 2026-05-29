/// Called when refresh fails or session is invalid (401).
typedef SessionExpiredCallback = Future<void> Function();

SessionExpiredCallback? globalSessionExpiredHandler;
