import 'package:flutter_test/flutter_test.dart';
import 'package:oola_mobile/core/utils/formatters.dart';

/// La locale 'fr' groupe les milliers avec une espace insecable ( / ).
/// On normalise en espace simple pour comparer le format de maniere stable.
String norm(String s) => s.replaceAll(' ', ' ').replaceAll(' ', ' ');

void main() {
  group('formatCFA', () {
    test('formate un montant avec separateur de milliers et suffixe FCFA', () {
      expect(norm(formatCFA(12500)), '12 500 FCFA');
    });

    test('arrondit les decimales', () {
      expect(norm(formatCFA(999.6)), '1 000 FCFA');
    });
  });
}
