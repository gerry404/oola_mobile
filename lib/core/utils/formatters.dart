import 'package:intl/intl.dart';

/// Formatage des montants en FCFA (franc CFA, XOF), sans decimales.
///
/// Toute la plateforme affiche les prix en FCFA (cahier des charges 4).
/// Exemple : 12500 -> "12 500 FCFA".
final _cfa = NumberFormat.decimalPattern('fr');

String formatCFA(num amount) {
  final rounded = amount.round();
  return '${_cfa.format(rounded)} FCFA';
}

/// Variante compacte pour les grands nombres (ex. soldes) : 1 250 000 -> "1,25 M FCFA".
String formatCFACompact(num amount) {
  if (amount.abs() >= 1000000) {
    final m = amount / 1000000;
    return '${_cfa.format(double.parse(m.toStringAsFixed(2)))} M FCFA';
  }
  if (amount.abs() >= 1000) {
    final k = amount / 1000;
    return '${_cfa.format(double.parse(k.toStringAsFixed(1)))} k FCFA';
  }
  return formatCFA(amount);
}

/// Date lisible en francais : "22 aout 2026".
String formatDateFr(DateTime date) =>
    DateFormat('d MMMM yyyy', 'fr').format(date.toLocal());

/// Date + heure : "22 aout 2026 a 14:05".
String formatDateTimeFr(DateTime date) =>
    DateFormat("d MMMM yyyy 'a' HH:mm", 'fr').format(date.toLocal());
