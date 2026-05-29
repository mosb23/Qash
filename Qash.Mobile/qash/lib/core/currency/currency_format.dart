import 'package:intl/intl.dart';

String currencySymbol(String currencyCode) {
  switch (currencyCode.toUpperCase()) {
    case 'USD':
      return '\$';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    case 'EGP':
      return 'E£';
    case 'JPY':
      return '¥';
    default:
      final code = currencyCode.trim().toUpperCase();
      return code.isNotEmpty ? code : '\$';
  }
}

String formatMoney(double value, String currencyCode) {
  return NumberFormat.currency(symbol: currencySymbol(currencyCode)).format(value);
}
