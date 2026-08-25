import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Donnees de locale pour le formatage des dates en francais.
  await initializeDateFormatting('fr');

  runApp(const ProviderScope(child: OolaApp()));
}
