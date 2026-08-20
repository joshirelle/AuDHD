import '../i18n/language_controller.dart';

/// Iisang anyo ng petsa sa buong app: `Agosto 16, 2026`.
class DateFormatter {
  static const List<String> _monthsFil = [
    'Enero',
    'Pebrero',
    'Marso',
    'Abril',
    'Mayo',
    'Hunyo',
    'Hulyo',
    'Agosto',
    'Setyembre',
    'Oktubre',
    'Nobyembre',
    'Disyembre',
  ];

  static const List<String> _monthsEng = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String longDate(DateTime date) {
    final months = LanguageController.isEnglish ? _monthsEng : _monthsFil;
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
