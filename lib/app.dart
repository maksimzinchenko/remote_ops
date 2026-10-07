// Материальная оболочка приложения. Навигатор нужен диалогу host key.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/generated/app_localizations.dart';
import 'presentation/app_scope.dart';
import 'presentation/screens/servers_screen.dart';

class RemoteOpsApp extends StatelessWidget {
  const RemoteOpsApp({super.key, required this.scope});

  final AppScope scope;

  @override
  Widget build(BuildContext context) {
    return scope;
  }
}

class RemoteOpsMaterialApp extends StatelessWidget {
  const RemoteOpsMaterialApp({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF1F6F5B);
    return MaterialApp(
      navigatorKey: navigatorKey,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      // locale не задаём: Flutter берёт язык системы и сверяет его с supportedLocales.
      localeResolutionCallback: (locale, supported) {
        if (locale == null) return const Locale('en');
        for (final item in supported) {
          if (item.languageCode == locale.languageCode) return item;
        }
        return const Locale('en');
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seed), useMaterial3: true),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const ServersScreen(),
    );
  }
}
