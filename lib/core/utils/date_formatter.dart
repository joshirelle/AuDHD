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

  /// Buwan at taon lang, mula sa `YYYY-MM`. Nakaimbak nang ganito sa asset
  /// para hindi na kailangang isulat nang dalawang beses sa bawat entry.
  /// Ibinabalik ang mismong `raw` kapag hindi mabasa — mas mabuting makita
  /// ang mali kaysa mawala ang petsa.
  static String monthYear(String raw) {
    final parts = raw.split('-');
    final month = parts.length == 2 ? int.tryParse(parts[1]) : null;
    if (month == null || month < 1 || month > 12) return raw;

    final months = LanguageController.isEnglish ? _monthsEng : _monthsFil;
    return '${months[month - 1]} ${parts[0]}';
  }

  /// Bati ayon sa oras. Ang gabi ay umaabot hanggang madaling-araw dahil
  /// karaniwang gising pa ang magulang sa mga oras na iyon.
  static String timeGreeting(DateTime now) {
    final hour = now.hour;
    if (hour >= 5 && hour < 12) return tr('Magandang umaga', 'Good morning');
    if (hour >= 12 && hour < 18) return tr('Magandang hapon', 'Good afternoon');
    return tr('Magandang gabi', 'Good evening');
  }
}
