import '../../domain/entities/auth_requests.dart';

class LoginRequestModel {
  final String phoneNumber;
  final String password;

  const LoginRequestModel({
    required this.phoneNumber,
    required this.password,
  });

  factory LoginRequestModel.fromDomain(LoginCredentials credentials) {
    return LoginRequestModel(
      phoneNumber: credentials.phoneNumber,
      password: credentials.password,
    );
  }

  Map<String, dynamic> toJson() {
    return {'phoneNumber': phoneNumber, 'password': password};
  }
}
