/// Conversion between a period (years / months / days) and a number of days.
///
/// One missed day equals one missed prayer of each type, so a period of
/// missed prayers converts to the same number for every prayer. The year
/// length is the user's choice (365 Gregorian or 354 Hijri); a month is
/// counted as 30 days. These are user-selected approximations, not rulings.
library;

const int daysPerMonth = 30;
const int gregorianYearDays = 365;
const int hijriYearDays = 354;

/// A period split into whole years, months and days.
class Period {
  const Period({this.years = 0, this.months = 0, this.days = 0});

  /// Splits [totalDays] into years, months (30 days) and days.
  factory Period.fromDays(int totalDays, {required int yearDays}) {
    final total = totalDays < 0 ? 0 : totalDays;
    final years = total ~/ yearDays;
    final rest = total % yearDays;
    return Period(
      years: years,
      months: rest ~/ daysPerMonth,
      days: rest % daysPerMonth,
    );
  }

  final int years;
  final int months;
  final int days;

  int toDays({required int yearDays}) =>
      years * yearDays + months * daysPerMonth + days;

  bool get isZero => years == 0 && months == 0 && days == 0;

  /// "1 yil 2 oy 5 kun"; zero parts are omitted, an empty period is "0 kun".
  String get label {
    final parts = [
      if (years > 0) '$years yil',
      if (months > 0) '$months oy',
      if (days > 0) '$days kun',
    ];
    return parts.isEmpty ? '0 kun' : parts.join(' ');
  }

  @override
  bool operator ==(Object other) =>
      other is Period &&
      other.years == years &&
      other.months == months &&
      other.days == days;

  @override
  int get hashCode => Object.hash(years, months, days);

  @override
  String toString() => label;
}

/// Human label for a number of days: "≈ 1 yil 2 oy 5 kun".
String formatPeriod(int days, {required int yearDays}) =>
    Period.fromDays(days, yearDays: yearDays).label;

String yearKindLabel(int yearDays) => yearDays == hijriYearDays
    ? 'Hijriy yil (354 kun)'
    : 'Milodiy yil (365 kun)';
