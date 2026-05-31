import 'package:flutter/services.dart';

/// Digits only (OTP codes).
final List<TextInputFormatter> digitsOnlyInputFormatters = [
  FilteringTextInputFormatter.digitsOnly,
];

/// Phone: + and digits.
final List<TextInputFormatter> phoneInputFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'[+0-9]')),
];

/// Digits and optional decimal point (money amounts).
final List<TextInputFormatter> amountInputFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
];

/// Letters and common name punctuation (no digits).
final List<TextInputFormatter> nameInputFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r"[\p{L}\s\-']", unicode: true)),
];

/// Default hint for Egyptian mobile numbers.
const String kPhoneHint = '01*********';
