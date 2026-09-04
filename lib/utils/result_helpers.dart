import 'result.dart';

/// Transforme la valeur d'un [Result] reussi, en propageant l'erreur telle
/// quelle. Evite de repeter le switch Ok/Error dans chaque repository.
Result<R> mapResult<R>(
  Result<dynamic> res,
  R Function(dynamic value) transform,
) {
  return switch (res) {
    Ok(:final value) => Result.ok(transform(value)),
    Error(:final error) => Result.error(error),
  };
}
