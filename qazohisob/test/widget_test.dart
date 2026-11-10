import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qazohisob/app.dart';
import 'package:qazohisob/core/constants/worship_types.dart';
import 'package:qazohisob/core/database/app_database.dart';
import 'package:qazohisob/core/notifications/reminder_scheduler.dart';
import 'package:qazohisob/shared/data/settings_repository.dart';
import 'package:qazohisob/shared/data/worship_repository.dart';
import 'package:qazohisob/shared/providers.dart';

import 'helpers.dart';

final _now = DateTime(2026, 11, 10, 10);

/// Pumps the whole app on an iPhone-sized screen with an in-memory DB.
Future<AppDatabase> pumpApp(
  WidgetTester tester, {
  bool onboarded = true,
  Future<void> Function(WorshipRepository repo)? seed,
  Size size = const Size(1179, 2556), // iPhone 15
  double pixelRatio = 3,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(tester.view.reset);

  final db = memoryDb();
  await tester.runAsync(() async {
    await SettingsRepository(db).setOnboardingCompleted(onboarded);
    if (seed != null) await seed(WorshipRepository(db, now: () => _now));
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        reminderSchedulerProvider.overrideWithValue(NoopReminderScheduler()),
        clockProvider.overrideWithValue(() => _now),
      ],
      child: QazoHisobApp(onboarded: onboarded),
    ),
  );
  await tester.pumpAndSettle();
  return db;
}

/// Unmounts the app and closes the database inside the fake-async zone so
/// drift's pending timers finish before the test ends.
Future<void> disposeApp(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  final closing = db.close();
  await tester.pump(const Duration(seconds: 1));
  await closing;
}

/// testWidgets wrapper that pumps the app, runs [body] and cleans up.
void testApp(
  String description,
  Future<void> Function(WidgetTester tester) body, {
  bool onboarded = true,
  Future<void> Function(WorshipRepository repo)? seed,
  Size size = const Size(1179, 2556),
  double pixelRatio = 3,
}) {
  testWidgets(description, (tester) async {
    final db = await pumpApp(
      tester,
      onboarded: onboarded,
      seed: seed,
      size: size,
      pixelRatio: pixelRatio,
    );
    await body(tester);
    await disposeApp(tester, db);
  });
}

/// The main vertical list of the visible screen.
Finder get mainList => find
    .byWidgetPredicate(
      (w) =>
          w is Scrollable &&
          axisDirectionToAxis(w.axisDirection) == Axis.vertical,
    )
    .first;

/// Scrolls the main list (down, then up) until [finder] is built.
Future<void> reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) return;
  for (final delta in [250.0, -250.0]) {
    try {
      await tester.scrollUntilVisible(
        finder,
        delta,
        scrollable: mainList,
        maxScrolls: 40,
      );
      return;
    } on StateError {
      // Not found in this direction.
    }
  }
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await reveal(tester, finder);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<String> textOf(WidgetTester tester, Finder finder) async {
  await reveal(tester, finder);
  return tester.widget<Text>(finder).data ?? '';
}

Future<void> seedDebts(WorshipRepository repo) async {
  await repo.setInitialDebts(
    prayers: {
      PrayerType.bomdod: 10,
      PrayerType.peshin: 10,
      PrayerType.asr: 10,
      PrayerType.shom: 10,
      PrayerType.xufton: 10,
    },
    fasting: 5,
  );
}

void main() {
  testApp('home dashboard shows greeting and totals', (tester) async {
    expect(find.text('Assalomu alaykum!'), findsOneWidget);
    expect(find.text('Namoz qarzi'), findsOneWidget);
    expect(find.text('50'), findsWidgets); // remaining prayers
    expect(await textOf(tester, find.byKey(const Key('overallPercent'))), '0%');
  }, seed: seedDebts);

  testApp('quick +1 on home updates dashboard and can be undone', (
    tester,
  ) async {
    await tapAndSettle(tester, find.byKey(const Key('homeQuick_bomdod')));
    expect(find.text('Bomdod: 1 ta ado qilindi'), findsOneWidget);
    expect(find.text('9 qoldi'), findsOneWidget);

    // Undo from the snackbar asks for confirmation first.
    await tester.tap(find.text('Bekor qilish').last);
    await tester.pumpAndSettle();
    expect(find.text('Yozuvni bekor qilasizmi?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Bekor qilish'));
    await tester.pumpAndSettle();
    expect(find.text('10 qoldi'), findsNWidgets(5));
  }, seed: seedDebts);

  testApp('prayer tracker: +1 and multiple completions', (tester) async {
    await tapAndSettle(tester, find.text('Namoz qazolari'));
    expect(await textOf(tester, find.byKey(const Key('remaining_asr'))), '10');

    await tapAndSettle(tester, find.byKey(const Key('quick_asr')));
    expect(await textOf(tester, find.byKey(const Key('remaining_asr'))), '9');

    await tapAndSettle(tester, find.byKey(const Key('many_asr')));
    await tester.enterText(find.byKey(const Key('quantityField')), '4');
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.byKey(const Key('quantityConfirm')));
    expect(await textOf(tester, find.byKey(const Key('remaining_asr'))), '5');
    expect(
      await textOf(tester, find.byKey(const Key('prayerTotalRemaining'))),
      '45',
    );
  }, seed: seedDebts);

  testApp('completing more than owed asks for confirmation', (tester) async {
    await tapAndSettle(tester, find.text('Namoz qazolari'));
    await tapAndSettle(tester, find.byKey(const Key('quick_shom')));
    expect(find.text('Qarzdan ortiq miqdor'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Bekor qilish'));
    await tester.pumpAndSettle();
    expect(await textOf(tester, find.byKey(const Key('remaining_shom'))), '0');
    expect(find.text('Ado: 0 / 0'), findsWidgets);
  });

  testApp('prayer detail shows history after adding debt', (tester) async {
    await tapAndSettle(tester, find.text('Namoz qazolari'));
    await tapAndSettle(tester, find.byKey(const Key('addDebt_xufton')));
    await tester.enterText(find.byKey(const Key('quantityField')), '3');
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.byKey(const Key('quantityConfirm')));
    expect(
      await textOf(tester, find.byKey(const Key('remaining_xufton'))),
      '13',
    );

    await tapAndSettle(tester, find.byKey(const Key('prayerCard_xufton')));
    expect(find.text('Xufton namozi'), findsOneWidget);
    expect(find.text('Xufton: +3 ta qarz qo‘shildi'), findsOneWidget);
    expect(find.text('Xufton: boshlang‘ich qarz 10 ta'), findsOneWidget);
  }, seed: seedDebts);

  testApp('fasting tracker reduces debt by exactly one day', (tester) async {
    await tapAndSettle(tester, find.text('Ro‘za qazolari'));
    await tapAndSettle(tester, find.byKey(const Key('fastComplete')));
    expect(find.text('Ro‘za tutdim'), findsWidgets);
    await tapAndSettle(tester, find.byKey(const Key('quantityConfirm')));
    expect(find.text('Qazo ro‘za: 1 kun tutildi'), findsOneWidget);
    final remaining = tester.widget<Text>(
      find.byKey(const Key('remainingValue')),
    );
    expect(remaining.textSpan!.toPlainText(), '4 kun');
  }, seed: seedDebts);

  testApp('onboarding saves initial debts and opens the dashboard', (
    tester,
  ) async {
    expect(find.text('QazoHisob’ga\nxush kelibsiz'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tapAndSettle(tester, find.byKey(const Key('onboardingNext')));
    }
    expect(find.text('Boshlang‘ich qarzlar'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('fillDaysField')), '20');
    await tapAndSettle(tester, find.byKey(const Key('fillAllButton')));
    await tester.enterText(find.byKey(const Key('initial_fast')), '7');
    await tapAndSettle(tester, find.byKey(const Key('saveInitial')));
    expect(find.text('Hammasi tayyor'), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const Key('onboardingNext')));
    expect(find.text('Assalomu alaykum!'), findsOneWidget);
    expect(find.text('100'), findsWidgets); // 5 prayers x 20
    expect(find.text('7 kun'), findsOneWidget);
  }, onboarded: false);

  testApp('onboarding debt entry can be skipped', (tester) async {
    await tapAndSettle(tester, find.byKey(const Key('skipOnboarding')));
    await tapAndSettle(tester, find.byKey(const Key('skipDebt')));
    await tapAndSettle(tester, find.byKey(const Key('onboardingNext')));
    expect(find.text('Qarzlaringizni kiritib boshlang'), findsOneWidget);
  }, onboarded: false);

  testApp(
    'reports show statistics and a navigable calendar',
    (tester) async {
      await tapAndSettle(tester, find.text('Hisobot'));
      // 6 completed out of 55 total.
      expect(
        await textOf(tester, find.byKey(const Key('statsOverall'))),
        '11%',
      );
      expect(find.text('Haftalik'.toUpperCase()), findsOneWidget);

      await tapAndSettle(tester, find.text('Kalendar'));
      expect(
        await textOf(tester, find.byKey(const Key('monthTitle'))),
        'Noyabr 2026',
      );
      expect(find.text('Bomdod: 5 ta ado qilindi'), findsOneWidget);

      await tapAndSettle(tester, find.byKey(const Key('day_3')));
      expect(find.text('Qazo ro‘za: 1 kun tutildi'), findsOneWidget);

      await tapAndSettle(tester, find.byKey(const Key('nextMonth')));
      expect(
        await textOf(tester, find.byKey(const Key('monthTitle'))),
        'Dekabr 2026',
      );
    },
    seed: (repo) async {
      await seedDebts(repo);
      await repo.completePrayer(PrayerType.bomdod, 5, date: _now);
      await repo.completeFast(date: DateTime(2026, 11, 3));
    },
  );

  testApp('settings: Vitr toggle, theme and reset with confirmation', (
    tester,
  ) async {
    await tapAndSettle(tester, find.byKey(const Key('settingsButton')));
    expect(find.text('Sozlamalar'), findsOneWidget);

    await tapAndSettle(tester, find.text('Qorong‘i'));
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);

    await tapAndSettle(tester, find.byKey(const Key('settingsVitr')));
    await tapAndSettle(tester, find.byType(BackButton));
    await tapAndSettle(tester, find.text('Namoz qazolari'));
    await reveal(tester, find.byKey(const Key('prayerCard_vitr')));
    expect(find.byKey(const Key('prayerCard_vitr')), findsOneWidget);

    await tapAndSettle(tester, find.text('Bosh sahifa'));
    await tapAndSettle(tester, find.byKey(const Key('settingsButton')));
    await tapAndSettle(tester, find.byKey(const Key('resetData')));
    await tapAndSettle(tester, find.text('Davom etish'));
    await tapAndSettle(tester, find.text('Ha, o‘chirish'));
    expect(find.text('QazoHisob’ga\nxush kelibsiz'), findsOneWidget);
  }, seed: seedDebts);

  // iPad Pro 11" in landscape (1194 x 834 points).
  const ipadLandscape = Size(2388, 1668);

  testApp(
    'iPad: content is centred with a readable width',
    (tester) async {
      expect(find.text('Assalomu alaykum!'), findsOneWidget);
      final card = tester.getRect(find.byKey(const Key('settingsButton')));
      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      // Content column is centred and no wider than the max content width.
      final hero = tester.getRect(find.text('Assalomu alaykum!'));
      expect(hero.left, greaterThan((screen.width - 680) / 2 - 1));
      expect(card.right, lessThan((screen.width + 680) / 2 + 1));

      for (final tab in ['Namoz qazolari', 'Ro‘za qazolari', 'Hisobot']) {
        await tapAndSettle(tester, find.text(tab));
      }
      await tapAndSettle(tester, find.text('Kalendar'));
      expect(
        await textOf(tester, find.byKey(const Key('monthTitle'))),
        'Noyabr 2026',
      );
    },
    seed: seedDebts,
    size: ipadLandscape,
    pixelRatio: 2,
  );

  testApp(
    'iPad: onboarding fits in portrait',
    (tester) async {
      await tapAndSettle(tester, find.byKey(const Key('skipOnboarding')));
      expect(find.text('Boshlang‘ich qarzlar'), findsOneWidget);
    },
    onboarded: false,
    size: const Size(1668, 2388),
    pixelRatio: 2,
  );
}
