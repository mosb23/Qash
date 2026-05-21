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
      errors:
          (json['errors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  factory ApiResponse.failure(String message, [List<String>? errors]) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors ?? const [],
    );
  }
}
