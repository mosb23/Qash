class PasswordPolicyResult {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;

  const PasswordPolicyResult({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
  });

  bool get isValid =>
      hasMinLength && hasUppercase && hasLowercase && hasNumber;

  List<String> get unmetRequirements {
    final messages = <String>[];
    if (!hasMinLength) {
      messages.add('At least 8 characters');
    }
    if (!hasUppercase) {
      messages.add('At least 1 uppercase letter');
    }
    if (!hasLowercase) {
      messages.add('At least 1 lowercase letter');
    }
    if (!hasNumber) {
      messages.add('At least 1 number');
    }
    return messages;
  }
}

PasswordPolicyResult evaluatePasswordPolicy(String password) {
  return PasswordPolicyResult(
    hasMinLength: password.length >= 8,
    hasUppercase: RegExp(r'[A-Z]').hasMatch(password),
    hasLowercase: RegExp(r'[a-z]').hasMatch(password),
    hasNumber: RegExp(r'[0-9]').hasMatch(password),
  );
}
