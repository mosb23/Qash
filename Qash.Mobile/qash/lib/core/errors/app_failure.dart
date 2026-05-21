class AppFailure {
  final String message;
  final List<String> errors;

  const AppFailure({required this.message, this.errors = const []});
}
