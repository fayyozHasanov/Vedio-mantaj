import '../../core/database/app_database.dart';
import 'settings_repository.dart';
import 'worship_repository.dart';

/// Whether the app should open on the dashboard instead of the welcome flow.
///
/// True once the user has entered their name, finished onboarding, or has
/// any data — so the welcome flow never starts over for an existing user,
/// even if onboarding was interrupted. Repairs the stored flag when needed.
Future<bool> isOnboarded(AppDatabase db) async {
  final settingsRepo = SettingsRepository(db);
  final settings = await settingsRepo.load();
  if (settings.onboardingCompleted) return true;
  final snapshot = await WorshipRepository(db).loadSnapshot();
  final hasData =
      snapshot.records.isNotEmpty ||
      snapshot.fasting.totalDebt > 0 ||
      snapshot.prayers.values.any((p) => p.totalDebt > 0);
  if (settings.firstName.isNotEmpty || hasData) {
    await settingsRepo.setOnboardingCompleted(true);
    return true;
  }
  return false;
}
