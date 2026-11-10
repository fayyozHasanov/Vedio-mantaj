import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_texts.dart';
import 'core/constants/worship_types.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/providers.dart';

class QazoHisobApp extends ConsumerStatefulWidget {
  const QazoHisobApp({super.key, required this.onboarded});

  /// Whether onboarding was already completed when the app started.
  final bool onboarded;

  @override
  ConsumerState<QazoHisobApp> createState() => _QazoHisobAppState();
}

class _QazoHisobAppState extends ConsumerState<QazoHisobApp> {
  late final GoRouter _router = createRouter(onboarded: widget.onboarded);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        ref.watch(settingsProvider).value?.theme ?? AppThemeMode.system;
    return MaterialApp.router(
      title: AppTexts.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (theme) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      locale: const Locale('uz'),
      supportedLocales: const [Locale('uz'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
