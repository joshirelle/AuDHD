import '../i18n/language_controller.dart';

/// Ingles ang naka-imbak sa Hive, ang nasa ulat ng doktor, at ang binabasa ng
/// `SensoryRecommendationService.normalizeProfile`. Ito ang bersyong nakikita ng
/// magulang — dito lang magsalin, huwag sa pinagmulan.
///
/// Susi ang mga key ng mapa. Ang halaga lang ang isinasalin.
class SensoryLabels {
  const SensoryLabels._();

  static const Map<String, String> _domains = {
    'Auditory': 'Pandinig',
    'Visual': 'Paningin',
    'Tactile': 'Paghipo',
    'Vestibular': 'Balanse',
    'Proprioceptive': 'Lakas at presyon',
  };

  static const Map<String, String> _domainsEnglish = {
    'Auditory': 'Hearing',
    'Visual': 'Sight',
    'Tactile': 'Touch',
    'Vestibular': 'Balance',
    'Proprioceptive': 'Pressure and force',
  };

  static const Map<String, String> _statuses = {
    'Seeking': 'Naghahanap',
    'Avoiding': 'Umiiwas',
    'Mixed': 'Halo',
    'Typical': 'Karaniwan',
  };

  static const Map<String, String> _statusesEnglish = {
    'Seeking': 'Seeking',
    'Avoiding': 'Avoiding',
    'Mixed': 'Mixed',
    'Typical': 'Typical',
  };

  static const Map<String, String> _profiles = {
    'Typical / Balanced Processing': 'Balanse ang pandama',
    'Mixed Profile (Seeking & Sensitive)':
        'Halo - may hinahanap, may iniiwasan',
    'Sensory Seeking (High Movement / Input Need)':
        'Naghahanap ng pandama - mahilig gumalaw at humipo',
    'Sensory Avoiding (Hyper-sensitive / Sensitive)':
        'Umiiwas sa pandama - madaling madaig ng paligid',
  };

  static const Map<String, String> _profilesEnglish = {
    'Typical / Balanced Processing': 'Balanced senses',
    'Mixed Profile (Seeking & Sensitive)':
        'Mixed - seeks some, avoids others',
    'Sensory Seeking (High Movement / Input Need)':
        'Seeking - enjoys moving and touching',
    'Sensory Avoiding (Hyper-sensitive / Sensitive)':
        'Avoiding - easily overwhelmed by the surroundings',
  };

  static String domain(String key) =>
      tr(_domains[key] ?? key, _domainsEnglish[key] ?? key);

  static String status(String key) =>
      tr(_statuses[key] ?? key, _statusesEnglish[key] ?? key);

  static String profile(String key) =>
      tr(_profiles[key] ?? key, _profilesEnglish[key] ?? key);
}
