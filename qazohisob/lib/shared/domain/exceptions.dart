/// Base class for errors the user should see as a friendly message.
class WorshipException implements Exception {
  const WorshipException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Thrown when completing more than is owed without explicit confirmation.
class ExceedsDebtException extends WorshipException {
  const ExceedsDebtException({required this.remaining, required this.requested})
    : super('Kiritilgan miqdor qolgan qarzdan ko‘p.');

  final int remaining;
  final int requested;

  int get excess => requested - remaining;
}

/// Thrown when an operation would make the remaining debt negative or the
/// input is invalid.
class DebtValidationException extends WorshipException {
  const DebtValidationException(super.message);
}

/// Thrown when a backup file cannot be read.
class BackupFormatException extends WorshipException {
  const BackupFormatException(super.message);
}
