/// Iisang anyo ng petsa sa buong app: `Agosto 16, 2026`.
class DateFormatter {
  static const List<String> _months = [
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

  static String longDate(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';
}
