class ForgotPasswordCode {
  final String phoneNumber;
  final String verificationCode;
  final String note;

  const ForgotPasswordCode({
    required this.phoneNumber,
    required this.verificationCode,
    required this.note,
  });
}
