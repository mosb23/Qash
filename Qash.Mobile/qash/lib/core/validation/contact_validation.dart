String? validateEmailAddress(String email) {
  final value = email.trim();
  if (value.isEmpty) {
    return 'Email is required.';
  }

  if (value.contains('..')) {
    return 'Please enter a valid email address.';
  }

  final emailRegex = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
  );

  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email address.';
  }

  return null;
}

String? validatePhoneNumber11Digits(String phone) {
  final value = phone.trim();
  if (value.isEmpty) {
    return 'Phone number is required.';
  }
  if (!RegExp(r'^\d+$').hasMatch(value)) {
    return 'Phone number must contain digits only.';
  }
  if (value.length < 11) {
    return 'Phone number must contain 11 digits.';
  }
  if (value.length > 11) {
    return 'Phone number cannot exceed 11 digits.';
  }
  return null;
}
