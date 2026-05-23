import '../../domain/entities/auth_requests.dart';

class ResetForgotPasswordRequestModel {
  final String phoneNumber;
  final String verificationCode;
  final String newPassword;
  final String confirmPassword;

  const ResetForgotPasswordRequestModel({
    required this.phoneNumber,
    required this.verificationCode,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ResetForgotPasswordRequestModel.fromDomain(
    ResetForgotPasswordData data,
  ) {
    return ResetForgotPasswordRequestModel(
      phoneNumber: data.phoneNumber,
      verificationCode: data.verificationCode,
      newPassword: data.newPassword,
      confirmPassword: data.confirmPassword,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'verificationCode': verificationCode,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}
