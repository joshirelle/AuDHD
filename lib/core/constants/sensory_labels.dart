/// Ingles ang naka-imbak sa Hive, ang nasa ulat ng doktor, at ang binabasa ng
/// `SensoryRecommendationService.normalizeProfile`. Ito ang bersyong nakikita ng
/// magulang — dito lang magsalin, huwag sa pinagmulan.
class SensoryLabels {
  const SensoryLabels._();

  static const Map<String, String> _domains = {
    'Auditory': 'Pandinig',
    'Visual': 'Paningin',
    'Tactile': 'Paghipo',
    'Vestibular': 'Balanse',
    'Proprioceptive': 'Lakas at presyon',
  };

  static const Map<String, String> _statuses = {
    'Seeking': 'Naghahanap',
    'Avoiding': 'Umiiwas',
    'Mixed': 'Halo',
    'Typical': 'Karaniwan',
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

  static String domain(String key) => _domains[key] ?? key;

  static String status(String key) => _statuses[key] ?? key;

  static String profile(String key) => _profiles[key] ?? key;
}
