/// In-memory navigation payload for forgot-password screens.
/// Keeps demo verification codes out of URL query parameters.
class ForgotPasswordFlowPayload {
  const ForgotPasswordFlowPayload({
    required this.phoneNumber,
    this.demoVerificationCode,
    this.verificationCode,
  });

  final String phoneNumber;

  /// Demo-only: code returned by API for coursework (not sent via SMS).
  final String? demoVerificationCode;

  /// User-entered code after verify step (passed to reset screen).
  final String? verificationCode;
}
