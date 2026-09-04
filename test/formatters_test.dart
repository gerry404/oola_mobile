import 'package:flutter_test/flutter_test.dart';
import 'package:oola_mobile/utils/formatters.dart';

/// La locale 'fr' groupe les milliers avec une espace insecable.
String norm(String s) => s.replaceAll(' ', ' ').replaceAll(' ', ' ');

void main() {
  group('formatCFA', () {
    test('formate avec separateur et suffixe FCFA', () {
      expect(norm(formatCFA(12500)), '12 500 FCFA');
    });
    test('arrondit les decimales', () {
      expect(norm(formatCFA(999.6)), '1 000 FCFA');
    });
  });
}
