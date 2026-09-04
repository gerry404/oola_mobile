import 'package:intl/intl.dart';

final _cfa = NumberFormat.decimalPattern('fr');

/// Montant en FCFA sans decimales : 12500 -> "12 500 FCFA".
String formatCFA(num amount) => '${_cfa.format(amount.round())} FCFA';

/// Variante compacte : 1 250 000 -> "1,25 M FCFA".
String formatCFACompact(num amount) {
  if (amount.abs() >= 1000000) {
    return '${_cfa.format(double.parse((amount / 1000000).toStringAsFixed(2)))} M FCFA';
  }
  if (amount.abs() >= 1000) {
    return '${_cfa.format(double.parse((amount / 1000).toStringAsFixed(1)))} k FCFA';
  }
  return formatCFA(amount);
}

String formatDateFr(DateTime date) =>
    DateFormat('d MMMM yyyy', 'fr').format(date.toLocal());

String formatDateTimeFr(DateTime date) =>
    DateFormat("d MMMM yyyy 'a' HH:mm", 'fr').format(date.toLocal());
