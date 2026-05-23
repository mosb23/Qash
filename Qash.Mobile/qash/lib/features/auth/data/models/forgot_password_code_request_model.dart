import '../../domain/entities/auth_requests.dart';

class ForgotPasswordCodeRequestModel {
  final String phoneNumber;

  const ForgotPasswordCodeRequestModel({required this.phoneNumber});

  factory ForgotPasswordCodeRequestModel.fromDomain(
    ForgotPasswordCodeRequestData data,
  ) {
    return ForgotPasswordCodeRequestModel(phoneNumber: data.phoneNumber);
  }

  Map<String, dynamic> toJson() {
    return {'phoneNumber': phoneNumber};
  }
}
