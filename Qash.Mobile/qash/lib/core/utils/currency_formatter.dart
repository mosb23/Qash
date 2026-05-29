import 'package:intl/intl.dart';

/// Supported display / wallet currency codes.
const supportedCurrencies = ['USD', 'EGP', 'EUR', 'GBP', 'JPY'];

class CurrencyFormatter {
  CurrencyFormatter._();

  static String symbolFor(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return r'$';
      case 'EGP':
        return 'E£';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      default:
        return currencyCode.toUpperCase();
    }
  }

  /// Short label for circular wallet badges (symbol, not a single letter of the code).
  static String badgeLabel(String currencyCode) {
    final code = currencyCode.toUpperCase();
    if (code.length <= 3 && symbolFor(code) != code) {
      return symbolFor(code);
    }
    return code.length > 3 ? code.substring(0, 3) : code;
  }

  static String format(double amount, String currencyCode) {
    final code = currencyCode.toUpperCase();
    final symbol = symbolFor(code);
    if (supportedCurrencies.contains(code)) {
      return NumberFormat.currency(symbol: symbol, decimalDigits: 2).format(amount);
    }
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String formatHidden() => '••••••';
}
