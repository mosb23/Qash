class AuthSession {
  final String userId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String accessToken;
  final String refreshToken;

  const AuthSession({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.accessToken,
    required this.refreshToken,
  });
}
