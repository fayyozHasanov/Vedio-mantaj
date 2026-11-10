/// Date helpers with Uzbek (Latin) wording. Kept dependency-free so that
/// formatting works offline and without locale initialisation.
library;

const List<String> uzMonths = [
  'Yanvar',
  'Fevral',
  'Mart',
  'Aprel',
  'May',
  'Iyun',
  'Iyul',
  'Avgust',
  'Sentabr',
  'Oktabr',
  'Noyabr',
  'Dekabr',
];

const List<String> uzMonthsShort = [
  'Yan',
  'Fev',
  'Mar',
  'Apr',
  'May',
  'Iyn',
  'Iyl',
  'Avg',
  'Sen',
  'Okt',
  'Noy',
  'Dek',
];

/// Monday-first weekday names.
const List<String> uzWeekdaysShort = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
const List<String> uzWeekdays = [
  'Dushanba',
  'Seshanba',
  'Chorshanba',
  'Payshanba',
  'Juma',
  'Shanba',
  'Yakshanba',
];

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String two(int v) => v.toString().padLeft(2, '0');

/// 10 Noyabr 2026
String formatDate(DateTime d) => '${d.day} ${uzMonths[d.month - 1]} ${d.year}';

/// 10 Noy
String formatDateShort(DateTime d) => '${d.day} ${uzMonthsShort[d.month - 1]}';

/// 10 Noyabr 2026, 14:05
String formatDateTime(DateTime d) =>
    '${formatDate(d)}, ${two(d.hour)}:${two(d.minute)}';

/// Seshanba, 10 Noyabr
String formatWeekdayDate(DateTime d) =>
    '${uzWeekdays[d.weekday - 1]}, ${d.day} ${uzMonths[d.month - 1]}';

/// Minutes since midnight -> "20:30".
String formatMinutes(int minutes) =>
    '${two(minutes ~/ 60)}:${two(minutes % 60)}';

/// 12345 -> "12 345".
String formatCount(int value) {
  final s = value.abs().toString();
  final buf = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// 0.4567 -> "46%"
String formatPercent(double fraction) => '${(fraction * 100).round()}%';
