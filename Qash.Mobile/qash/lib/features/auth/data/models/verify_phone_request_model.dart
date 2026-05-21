import '../../domain/entities/auth_requests.dart';

class VerifyPhoneRequestModel {
  final String phoneNumber;
  final String verificationCode;

  const VerifyPhoneRequestModel({
    required this.phoneNumber,
    required this.verificationCode,
  });

  factory VerifyPhoneRequestModel.fromDomain(PhoneVerificationData data) {
    return VerifyPhoneRequestModel(
      phoneNumber: data.phoneNumber,
      verificationCode: data.verificationCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {'phoneNumber': phoneNumber, 'verificationCode': verificationCode};
  }
}
