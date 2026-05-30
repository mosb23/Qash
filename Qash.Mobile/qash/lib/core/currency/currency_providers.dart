import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/providers/profile_providers.dart';
import '../../features/transactions/providers/transactions_providers.dart';
import 'currency_conversion_service.dart';

final currencyConversionServiceProvider = Provider<CurrencyConversionService>((
  ref,
) {
  final rates = ref.watch(exchangeRatesProvider).maybeWhen(
        data: (rates) => rates,
        orElse: () => kDefaultExchangeRates,
      );
  return CurrencyConversionService(rates);
});

/// User's selected display currency (from profile, default USD).
final displayCurrencyProvider = Provider<String>((ref) {
  final profile = ref.watch(profileProvider);
  return profile.maybeWhen(
    data: (result) {
      if (result.isSuccess && result.data != null) {
        final preferred = result.data!.preferredCurrency.trim().toUpperCase();
        if (preferred.isNotEmpty && kSupportedCurrencies.contains(preferred)) {
          return preferred;
        }
      }
      return kBaseCurrency;
    },
    orElse: () => kBaseCurrency,
  );
});

/// Selected currency override for screens with a currency picker (home, wallets).
final selectedDisplayCurrencyProvider = StateProvider<String?>((ref) => null);

/// Effective currency for display: picker override or profile preference.
final effectiveDisplayCurrencyProvider = Provider<String>((ref) {
  final override = ref.watch(selectedDisplayCurrencyProvider);
  if (override != null && override.isNotEmpty) {
    return override.toUpperCase();
  }
  return ref.watch(displayCurrencyProvider);
});
