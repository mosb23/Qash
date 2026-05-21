class VerifyPhoneRequest {
  final String phoneNumber;
  final String verificationCode;

  VerifyPhoneRequest({
    required this.phoneNumber,
    required this.verificationCode,
  });

  Map<String, dynamic> toJson() {
    return {'phoneNumber': phoneNumber, 'verificationCode': verificationCode};
  }
}
