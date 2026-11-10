/// Types of prayers tracked by the app.
///
/// [vitr] is optional and only counted when enabled in settings, because
/// scholars differ on its status.
enum PrayerType {
  bomdod('Bomdod'),
  peshin('Peshin'),
  asr('Asr'),
  shom('Shom'),
  xufton('Xufton'),
  vitr('Vitr');

  const PrayerType(this.label);

  final String label;

  /// The five daily obligatory prayers.
  static const List<PrayerType> fard = [bomdod, peshin, asr, shom, xufton];

  /// Prayers that are visible given the user's Vitr preference.
  static List<PrayerType> visible({required bool vitrEnabled}) =>
      vitrEnabled ? values : fard;
}

/// The kind of act of worship a record belongs to.
enum WorshipKind { prayer, fast }

/// What a history record represents.
enum RecordAction {
  /// Additional missed acts were added to the debt.
  debtAdded,

  /// Missed acts were made up (qazo performed).
  completed,

  /// Audit entry written whenever the initial estimate is changed.
  /// [quantity] holds the new value and the note the previous one.
  /// It never takes part in calculations.
  initialSet,
}

enum AppThemeMode { system, light, dark }
