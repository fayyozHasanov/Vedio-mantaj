import '../../core/constants/worship_types.dart';
import '../../core/database/app_database.dart';
import '../../core/utilities/date_utils.dart';

/// One tasbih of the daily wird.
class ZikrItem {
  const ZikrItem({
    required this.latin,
    required this.arabic,
    this.target = 101,
  });

  final String latin;
  final String arabic;
  final int target;
}

/// Naqshbandiya tariqati vazifasi — as provided by the user: six tasbihs,
/// 101 times each, after Bomdod until sunrise and after Asr until sunset.
abstract final class NaqshbandiyaWird {
  static const title = 'Naqshbandiya tariqati vazifasi';
  static const note =
      '6 tasbih bomdoddan keyin quyosh chiqquncha va asrdan keyin '
      'quyosh botguncha aytiladi.';

  static const items = <ZikrItem>[
    ZikrItem(
      latin: 'La iloha illallohu Muhammadur Rasululloh',
      arabic: 'لَا إِلٰهَ إِلَّا اللّٰهُ مُحَمَّدٌ رَسُولُ اللّٰهِ',
    ),
    ZikrItem(latin: 'Subhonalloh', arabic: 'سُبْحَانَ اللّٰهِ'),
    ZikrItem(latin: 'Alhamdu lilloh', arabic: 'اَلْحَمْدُ لِلّٰهِ'),
    ZikrItem(latin: 'Astaghfirulloh', arabic: 'أَسْتَغْفِرُ اللّٰهَ'),
    ZikrItem(latin: 'Allohu akbar', arabic: 'اَللّٰهُ أَكْبَرُ'),
    ZikrItem(latin: 'Alloh', arabic: 'اَللّٰهُ'),
  ];

  static int get totalPerSession =>
      items.fold(0, (sum, item) => sum + item.target);
}

/// Session that fits the current time of day (before noon → after Bomdod).
ZikrSession sessionFor(DateTime now) =>
    now.hour < 12 ? ZikrSession.morning : ZikrSession.evening;

/// Counts for one session of one day, one entry per tasbih.
class ZikrProgress {
  ZikrProgress(List<int> counts)
    : counts = List.unmodifiable(
        List.generate(
          NaqshbandiyaWird.items.length,
          (i) => i < counts.length ? counts[i] : 0,
        ),
      );

  ZikrProgress.empty() : this(const []);

  final List<int> counts;

  bool itemDone(int i) => counts[i] >= NaqshbandiyaWird.items[i].target;

  int get doneItems =>
      List.generate(counts.length, itemDone).where((d) => d).length;

  bool get isComplete => doneItems == counts.length;

  int get total => counts.fold(0, (a, b) => a + b);

  double get fraction => total / NaqshbandiyaWird.totalPerSession;

  /// First tasbih that is not finished yet (or the last one).
  int get nextItem {
    for (var i = 0; i < counts.length; i++) {
      if (!itemDone(i)) return i;
    }
    return counts.length - 1;
  }
}

/// Both sessions of one day.
class ZikrDay {
  ZikrDay({required this.day, required this.sessions});

  final DateTime day;
  final Map<ZikrSession, ZikrProgress> sessions;

  ZikrProgress operator [](ZikrSession s) =>
      sessions[s] ?? ZikrProgress.empty();

  bool get isComplete => ZikrSession.values.every((s) => this[s].isComplete);
}

/// Groups stored rows by day.
Map<DateTime, ZikrDay> groupZikr(Iterable<ZikrCount> rows) {
  final raw = <DateTime, Map<ZikrSession, List<int>>>{};
  for (final r in rows) {
    if (r.item < 0 || r.item >= NaqshbandiyaWird.items.length) continue;
    final day = dateOnly(r.day);
    final sessions = raw.putIfAbsent(day, () => {});
    final counts = sessions.putIfAbsent(
      r.session,
      () => List.filled(NaqshbandiyaWird.items.length, 0),
    );
    counts[r.item] = r.count;
  }
  return {
    for (final e in raw.entries)
      e.key: ZikrDay(
        day: e.key,
        sessions: {
          for (final s in e.value.entries) s.key: ZikrProgress(s.value),
        },
      ),
  };
}

/// Consecutive days (ending today, or yesterday if today is not finished
/// yet) on which both sessions were completed.
int zikrStreak(Map<DateTime, ZikrDay> days, {required DateTime today}) {
  var day = dateOnly(today);
  if (!(days[day]?.isComplete ?? false)) {
    day = DateTime(day.year, day.month, day.day - 1);
  }
  var streak = 0;
  while (days[day]?.isComplete ?? false) {
    streak++;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return streak;
}
