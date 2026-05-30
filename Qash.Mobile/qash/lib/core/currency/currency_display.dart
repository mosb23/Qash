import 'currency_conversion_service.dart';
import 'currency_format.dart';

/// Formats a monetary value with optional converted display for cross-currency views.
class CurrencyDisplay {
  const CurrencyDisplay({
    required this.originalAmount,
    required this.originalCurrency,
    this.convertedAmount,
    this.convertedCurrency,
    this.exchangeRateUsed,
  });

  final double originalAmount;
  final String originalCurrency;
  final double? convertedAmount;
  final String? convertedCurrency;
  final double? exchangeRateUsed;

  bool get hasConversion =>
      convertedAmount != null &&
      convertedCurrency != null &&
      convertedCurrency!.toUpperCase() != originalCurrency.toUpperCase();

  String formatOriginal() =>
      formatMoney(originalAmount, originalCurrency);

  String formatConverted() {
    if (!hasConversion) {
      return formatOriginal();
    }
    return formatMoney(convertedAmount!, convertedCurrency!);
  }

  String formatDual() {
    if (!hasConversion) {
      return formatOriginal();
    }
    return '${formatOriginal()} (${formatConverted()})';
  }
}

CurrencyDisplay buildCurrencyDisplay({
  required double originalAmount,
  required String originalCurrency,
  required String displayCurrency,
  required CurrencyConversionService conversion,
  double? convertedAmount,
  String? convertedCurrency,
  double? exchangeRateUsed,
}) {
  final normalizedOriginal = originalCurrency.trim().toUpperCase();
  final normalizedDisplay = displayCurrency.trim().toUpperCase();

  if (convertedAmount != null &&
      convertedCurrency != null &&
      convertedCurrency.trim().toUpperCase() != normalizedOriginal) {
    return CurrencyDisplay(
      originalAmount: originalAmount,
      originalCurrency: normalizedOriginal,
      convertedAmount: convertedAmount,
      convertedCurrency: convertedCurrency.trim().toUpperCase(),
      exchangeRateUsed: exchangeRateUsed,
    );
  }

  if (normalizedOriginal == normalizedDisplay) {
    return CurrencyDisplay(
      originalAmount: originalAmount,
      originalCurrency: normalizedOriginal,
    );
  }

  return CurrencyDisplay(
    originalAmount: originalAmount,
    originalCurrency: normalizedOriginal,
    convertedAmount: conversion.convert(
      amount: originalAmount,
      fromCurrency: normalizedOriginal,
      toCurrency: normalizedDisplay,
    ),
    convertedCurrency: normalizedDisplay,
    exchangeRateUsed: conversion.effectiveRate(
      normalizedOriginal,
      normalizedDisplay,
    ),
  );
}
