import '../../domain/entities/auth_session.dart';

class AuthResponseModel extends AuthSession {
  const AuthResponseModel({
    required super.userId,
    required super.firstName,
    required super.lastName,
    required super.fullName,
    required super.email,
    required super.phoneNumber,
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      userId: json['userId']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
    );
  }
}
