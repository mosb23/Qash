import '../errors/app_failure.dart';

class Result<T> {
  final T? data;
  final AppFailure? failure;

  const Result._({this.data, this.failure});

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;

  String get message => failure?.message ?? '';
  List<String> get errors => failure?.errors ?? const [];

  factory Result.success(T data) {
    return Result._(data: data);
  }

  factory Result.failure(AppFailure failure) {
    return Result._(failure: failure);
  }
}
