// Architecture de reference : flutter/samples > compass_app.
// Type Result pour encapsuler succes/erreur sans exceptions non gerees.

/// Encapsule le resultat d'une operation : [Ok] ou [Error].
///
/// Evaluation par switch :
/// ```dart
/// switch (result) {
///   case Ok(): print(result.value);
///   case Error(): print(result.error);
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Resultat reussi.
  const factory Result.ok(T value) = Ok._;

  /// Resultat en erreur.
  const factory Result.error(Exception error) = Error._;
}

/// Resultat reussi contenant [value].
final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// Resultat en erreur contenant [error].
final class Error<T> extends Result<T> {
  const Error._(this.error);

  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';
}
