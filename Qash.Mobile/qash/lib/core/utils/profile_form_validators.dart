/// Profile field validation aligned with sign-up and API rules.
class ProfileFormValidators {
  ProfileFormValidators._();

  static const int maxNameLength = 100;

  static String? validateFirstName(String value) {
    final name = value.trim();
    if (name.isEmpty) {
      return 'First name is required.';
    }
    if (name.length > maxNameLength) {
      return 'First name must be at most $maxNameLength characters.';
    }
    return null;
  }

  static String? validateLastName(String value) {
    final name = value.trim();
    if (name.isEmpty) {
      return 'Last name is required.';
    }
    if (name.length > maxNameLength) {
      return 'Last name must be at most $maxNameLength characters.';
    }
    return null;
  }

  static String? validateEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) {
      return 'Email is required.';
    }
    final normalized = email.toLowerCase();
    if (!normalized.contains('@') || !normalized.endsWith('.com')) {
      return 'Email must contain @ and end with .com';
    }
    return null;
  }

  /// Returns the first validation error, or null if all fields are valid.
  static String? validateProfileFields({
    required String firstName,
    required String lastName,
    required String email,
  }) {
    return validateFirstName(firstName) ??
        validateLastName(lastName) ??
        validateEmail(email);
  }
}
