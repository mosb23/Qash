import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/app_constants.dart';

class DioProvider {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['BASE_URL'] ?? '',
      connectTimeout:
          AppConstants.connectTimeout,
      receiveTimeout:
          AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );
}
