import 'package:dio/dio.dart';

import '../../../core/currency/exchange_rates.dart';
import '../../../core/network/api_response.dart';

class ExchangeRatesApi {
  final Dio _dio;

  const ExchangeRatesApi(this._dio);

  Future<Map<String, double>> fetchRates() async {
    try {
      final response = await _dio.get('/api/exchange-rates');
      final data = response.data as Map<String, dynamic>;
      final parsed = ApiResponse<Map<String, double>>.fromJson(data, (json) {
        final map = json as Map<String, dynamic>? ?? {};
        return map.map(
          (key, value) => MapEntry(
            key.toString().toUpperCase(),
            (value as num).toDouble(),
          ),
        );
      });
      if (parsed.success && parsed.data != null && parsed.data!.isNotEmpty) {
        return parsed.data!;
      }
    } catch (_) {
      // Fall back to bundled defaults when the API is unavailable.
    }
    return Map<String, double>.from(defaultExchangeRates);
  }
}
