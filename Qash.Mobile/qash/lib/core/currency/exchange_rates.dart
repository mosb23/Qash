/// Exchange rates as units of each currency per 1 USD.
const Map<String, double> defaultExchangeRates = {
  'USD': 1.00,
  'EGP': 49.50,
  'EUR': 0.86,
  'GBP': 0.74,
  'JPY': 143.20,
};

double convertCurrencyAmount({
  required double amount,
  required String fromCurrency,
  required String toCurrency,
  Map<String, double>? rates,
}) {
  final table = _normalizedRates(rates ?? defaultExchangeRates);
  final from = fromCurrency.trim().toUpperCase();
  final to = toCurrency.trim().toUpperCase();

  if (from == to) {
    return _roundMoney(amount);
  }

  final fromRate = table[from];
  final toRate = table[to];
  if (fromRate == null || toRate == null) {
    throw StateError('Exchange rate is not configured for $from or $to.');
  }

  final amountInUsd = amount / fromRate;
  return _roundMoney(amountInUsd * toRate);
}

Map<String, double> _normalizedRates(Map<String, double> rates) {
  final normalized = <String, double>{};
  rates.forEach((key, value) {
    if (key.trim().isEmpty || value <= 0) {
      return;
    }
    normalized[key.trim().toUpperCase()] = value;
  });
  normalized.putIfAbsent('USD', () => 1.0);
  return normalized;
}

double _roundMoney(double value) {
  return (value * 100).roundToDouble() / 100;
}
