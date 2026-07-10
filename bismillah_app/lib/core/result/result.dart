import 'package:bismillah_app/core/errors/app_failure.dart';

/// Domain/data sınırında istisna yerine kullanılan sonuç tipi.
///
/// Use case'ler ve repository'ler istisna fırlatmak yerine [Result] döner;
/// presentation katmanı yalnız [AppFailure] görür (06_FLUTTER_ARCHITECTURE §22).
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(AppFailure failure) = FailureResult<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  /// Sonucu tek noktadan dallandırır.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppFailure failure) onFailure,
  }) {
    final self = this;
    return switch (self) {
      Success<T>(:final value) => onSuccess(value),
      FailureResult<T>(:final failure) => onFailure(failure),
    };
  }

  /// Başarı değerini dönüştürür; hata aynen taşınır.
  Result<R> map<R>(R Function(T value) transform) {
    return fold(
      onSuccess: (value) => Result.success(transform(value)),
      onFailure: Result<R>.failure,
    );
  }

  T? get valueOrNull => fold(onSuccess: (v) => v, onFailure: (_) => null);

  AppFailure? get failureOrNull =>
      fold(onSuccess: (_) => null, onFailure: (f) => f);
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final AppFailure failure;
}
