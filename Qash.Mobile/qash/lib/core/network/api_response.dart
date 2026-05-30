class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<String> errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    List<String>? errors,
  }) : errors = errors ?? const [];

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? parseData,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: parseData != null ? parseData(json['data']) : null,
      errors: _parseErrors(json['errors']),
    );
  }

  static List<String> _parseErrors(dynamic errors) {
    if (errors == null) {
      return const [];
    }
    if (errors is List) {
      return errors.map((e) => e.toString()).toList();
    }
    if (errors is Map) {
      final messages = <String>[];
      for (final entry in errors.entries) {
        final value = entry.value;
        if (value is List) {
          for (final item in value) {
            messages.add(item.toString());
          }
        } else {
          messages.add(value.toString());
        }
      }
      return messages;
    }
    return [errors.toString()];
  }

  factory ApiResponse.failure(String message, [List<String>? errors]) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors ?? const [],
    );
  }
}
