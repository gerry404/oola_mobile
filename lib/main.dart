import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'config/dependencies.dart';
import 'data/repositories/auth/auth_repository.dart';
import 'data/services/local_store_service.dart';
import 'routing/router.dart';
import 'ui/core/themes/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr');

  if (Logger.root.level == Level.INFO) {
    Logger.root.level = Level.WARNING;
  }

  final localStore = await LocalStoreService.open();

  runApp(
    MultiProvider(
      providers: providers(localStore),
      child: const OolaApp(),
    ),
  );
}

class OolaApp extends StatelessWidget {
  const OolaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OOLAshop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter(context.read<AuthRepository>()),
    );
  }
}
