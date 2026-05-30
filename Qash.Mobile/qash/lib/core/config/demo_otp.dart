/// University/demo OTP — must match API `DemoOtp:VerificationCode` (default 00000).
/// Not used for production SMS flows.
abstract final class DemoOtp {
  static const defaultCode = '00000';
}
