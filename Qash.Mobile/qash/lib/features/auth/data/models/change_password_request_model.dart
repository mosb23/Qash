import '../../domain/entities/auth_requests.dart';

class ChangePasswordRequestModel {
  final String userId;
  final String oldPassword;
  final String verificationCode;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequestModel({
    required this.userId,
    required this.oldPassword,
    required this.verificationCode,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ChangePasswordRequestModel.fromDomain(ChangePasswordData data) {
    return ChangePasswordRequestModel(
      userId: data.userId,
      oldPassword: data.oldPassword,
      verificationCode: data.verificationCode,
      newPassword: data.newPassword,
      confirmPassword: data.confirmPassword,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'oldPassword': oldPassword,
      'verificationCode': verificationCode,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}
