class LoginCredentials {
  final String phoneNumber;
  final String password;

  const LoginCredentials({required this.phoneNumber, required this.password});
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

class ForgotPasswordCodeRequestData {
  final String phoneNumber;

  const ForgotPasswordCodeRequestData({required this.phoneNumber});
}

class ResetForgotPasswordData {
  final String phoneNumber;
  final String verificationCode;
  final String newPassword;
  final String confirmPassword;

  const ResetForgotPasswordData({
    required this.phoneNumber,
    required this.verificationCode,
    required this.newPassword,
    required this.confirmPassword,
  });
}

class ChangePasswordData {
  final String userId;
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordData({
    required this.userId,
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });
}
