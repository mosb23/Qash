class LoginCredentials {
  final String phoneNumber;
  final String password;

  const LoginCredentials({
    required this.phoneNumber,
    required this.password,
  });
}

class RegistrationData {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;

  const RegistrationData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
  });
}

class PhoneVerificationData {
  final String phoneNumber;
  final String verificationCode;

  const PhoneVerificationData({
    required this.phoneNumber,
    required this.verificationCode,
  });
}
