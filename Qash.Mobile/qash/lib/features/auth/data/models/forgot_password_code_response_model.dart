import '../../domain/entities/forgot_password_code.dart';

class ForgotPasswordCodeResponseModel {
  final String phoneNumber;
  final String verificationCode;
  final String note;

  const ForgotPasswordCodeResponseModel({
    required this.phoneNumber,
    required this.verificationCode,
    required this.note,
  });

  factory ForgotPasswordCodeResponseModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordCodeResponseModel(
      phoneNumber: json['phoneNumber'] as String? ?? '',
      verificationCode: json['verificationCode'] as String? ?? '',
      note: json['note'] as String? ?? '',
    );
  }

  ForgotPasswordCode toDomain() {
    return ForgotPasswordCode(
      phoneNumber: phoneNumber,
      verificationCode: verificationCode,
      note: note,
    );
  }
}
