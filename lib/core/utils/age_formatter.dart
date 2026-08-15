/// Iisang batayan ng edad para hindi magkaiba ang ipinapakita sa app at sa PDF.
class AgeFormatter {
  static const String invalidBirthDate = 'Hindi wasto ang kaarawan';

  static int monthsBetween(DateTime birthDate, DateTime asOf) {
    int months =
        (asOf.year - birthDate.year) * 12 + asOf.month - birthDate.month;
    if (asOf.day < birthDate.day) months--;
    return months;
  }

  static String formatMonths(int months) {
    if (months < 0) return invalidBirthDate;

    final years = months ~/ 12;
    final remainder = months % 12;
    final parts = <String>[];
    if (years > 0) parts.add('$years taon');
    if (remainder > 0) parts.add('$remainder buwan');
    if (parts.isEmpty) return 'Wala pang isang buwan';
    return '${parts.join(', ')} ($months buwan)';
  }

  static String formatAge(DateTime birthDate, DateTime asOf) =>
      formatMonths(monthsBetween(birthDate, asOf));
}
