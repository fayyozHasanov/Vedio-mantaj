import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/connection/connection.dart';
import '../theme/app_theme.dart';
import 'islamic_pattern.dart';

/// Shown when the app cannot start (usually because the database could not
/// be opened). Explains what to try and shows technical details that the
/// user can copy and send.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: _StartupErrorScreen(error: error, onRetry: onRetry),
    );
  }
}

class _StartupErrorScreen extends StatefulWidget {
  const _StartupErrorScreen({required this.error, required this.onRetry});

  final Object error;
  final Future<void> Function() onRetry;

  @override
  State<_StartupErrorScreen> createState() => _StartupErrorScreenState();
}

class _StartupErrorScreenState extends State<_StartupErrorScreen> {
  bool _retrying = false;

  String get _details {
    final error = widget.error is TimeoutException
        ? 'Ma’lumotlar bazasi 20 soniyada ochilmadi (timeout).'
        : '${widget.error}';
    return [
      error,
      if (webStorageInfo != null) 'Saqlash: $webStorageInfo',
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(28),
              children: [
                const Center(child: AppMark(size: 84)),
                const SizedBox(height: Gap.xl),
                Text(
                  'Ilovani ishga tushirib bo‘lmadi',
                  textAlign: TextAlign.center,
                  style: context.text.headlineSmall,
                ),
                const SizedBox(height: Gap.md),
                Text(
                  kIsWeb
                      ? 'Brauzer ma’lumotlar bazasini ocha olmadi. Quyidagilarni '
                            'tekshiring:\n'
                            '• Safari “Maxfiy” (Private) rejimida emasligini\n'
                            '• iPadOS yangilanganini (Sozlamalar → Umumiy → '
                            'Dasturiy ta’minot yangilanishi)\n'
                            '• Sahifani qayta yuklab ko‘ring'
                      : 'Ma’lumotlar bazasini ochib bo‘lmadi. Ilovani qayta '
                            'ishga tushirib ko‘ring.',
                  style: context.text.bodyMedium,
                ),
                const SizedBox(height: Gap.lg),
                Container(
                  padding: const EdgeInsets.all(Gap.md),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    _details,
                    key: const Key('startupErrorDetails'),
                    style: context.text.bodySmall,
                  ),
                ),
                const SizedBox(height: Gap.xl),
                FilledButton(
                  key: const Key('startupRetry'),
                  onPressed: _retrying
                      ? null
                      : () async {
                          setState(() => _retrying = true);
                          await widget.onRetry();
                          if (mounted) setState(() => _retrying = false);
                        },
                  child: const Text('Qayta urinish'),
                ),
                TextButton(
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: _details)),
                  child: const Text('Xato matnini nusxalash'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
