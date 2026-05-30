/// Hardcoded exchange rates as units of each currency per 1 USD.
const Map<String, double> kDefaultExchangeRates = {
  'USD': 1.00,
  'EGP': 49.50,
  'EUR': 0.86,
  'GBP': 0.74,
  'JPY': 143.20,
};

const String kBaseCurrency = 'USD';

const List<String> kSupportedCurrencies = [
  'USD',
  'EGP',
  'EUR',
  'GBP',
  'JPY',
];

/// Centralized currency conversion used across the entire app.
class CurrencyConversionService {
  CurrencyConversionService([Map<String, double>? rates])
      : _rates = _normalizeRates(rates ?? kDefaultExchangeRates);

  final Map<String, double> _rates;

  String get baseCurrency => kBaseCurrency;

  Map<String, double> get rates => Map.unmodifiable(_rates);

  double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    return convertFromBase(
      convertToBase(amount, fromCurrency),
      toCurrency,
    );
  }

  double convertToBase(double amount, String fromCurrency) {
    final from = _normalizeCurrency(fromCurrency);
    if (from == baseCurrency) {
      return _roundMoney(amount);
    }

    final fromRate = _rateFor(from);
    return _roundMoney(amount / fromRate);
  }

  double convertFromBase(double amountInBase, String toCurrency) {
    final to = _normalizeCurrency(toCurrency);
    if (to == baseCurrency) {
      return _roundMoney(amountInBase);
    }

    return _roundMoney(amountInBase * _rateFor(to));
  }

  double effectiveRate(String fromCurrency, String toCurrency) {
    final from = _normalizeCurrency(fromCurrency);
    final to = _normalizeCurrency(toCurrency);
    if (from == to) {
      return 1;
    }

    return _roundMoney(_rateFor(to) / _rateFor(from));
  }

  double transferCreditAmount({
    required double sourceAmount,
    required String sourceCurrency,
    required String targetCurrency,
  }) {
    return convert(
      amount: sourceAmount,
      fromCurrency: sourceCurrency,
      toCurrency: targetCurrency,
    );
  }

  double _rateFor(String currency) {
    final rate = _rates[currency];
    if (rate == null || rate <= 0) {
      throw StateError('Exchange rate is not configured for $currency.');
    }
    return rate;
  }

  static Map<String, double> _normalizeRates(Map<String, double> rates) {
    final normalized = <String, double>{};
    rates.forEach((key, value) {
      if (key.trim().isEmpty || value <= 0) {
        return;
      }
      normalized[key.trim().toUpperCase()] = value;
    });
    normalized.putIfAbsent(kBaseCurrency, () => 1.0);
    return normalized;
  }

  static String _normalizeCurrency(String currency) {
    final normalized = currency.trim().toUpperCase();
    if (normalized.isEmpty) {
      return kBaseCurrency;
    }
    return normalized;
  }

  static double _roundMoney(double value) {
    return (value * 100).roundToDouble() / 100;
  }
}

/// @deprecated Use [CurrencyConversionService] via [currencyConversionServiceProvider].
double convertCurrencyAmount({
  required double amount,
  required String fromCurrency,
  required String toCurrency,
  Map<String, double>? rates,
}) {
  return CurrencyConversionService(rates ?? kDefaultExchangeRates).convert(
    amount: amount,
    fromCurrency: fromCurrency,
    toCurrency: toCurrency,
  );
}

Map<String, double> defaultRatesOr(Map<String, double>? rates) {
  return rates ?? kDefaultExchangeRates;
}

/// Backward-compatible alias.
const Map<String, double> defaultExchangeRates = kDefaultExchangeRates;
