import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'core/providers.dart';
import 'core/storage/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Donnees de locale pour le formatage des dates en francais.
  await initializeDateFormatting('fr');

  // Ouvre le stockage local (panier, favoris, cache) avant de demarrer l'app.
  final localStore = await LocalStore.open();

  runApp(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(localStore),
      ],
      child: const OolaApp(),
    ),
  );
}
