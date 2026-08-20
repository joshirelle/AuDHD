import '../i18n/language_controller.dart';

/// Iisang batayan ng edad para hindi magkaiba ang ipinapakita sa app at sa PDF.
class AgeFormatter {
  static String get invalidBirthDate =>
      tr('Hindi wasto ang kaarawan', 'Invalid birthday');

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
    if (years > 0) parts.add(tr('$years taon', '$years yr'));
    if (remainder > 0) parts.add(tr('$remainder buwan', '$remainder mo'));
    if (parts.isEmpty) {
      return tr('Wala pang isang buwan', 'Less than a month');
    }
    return '${parts.join(', ')} ${tr('($months buwan)', '($months months)')}';
  }

  static String formatAge(DateTime birthDate, DateTime asOf) =>
      formatMonths(monthsBetween(birthDate, asOf));
}
