import '../core/i18n/language_controller.dart';

/// Apat na kundisyon ng CDC sa paggamit ng nilalaman nila: atribusyon,
/// paunawang walang endorso, walang logo, at pagsasabing libre ito sa kanila.
/// Iisang pinagmumulan para hindi mabago ang isa nang hindi ang iba.
class CdcAttribution {
  const CdcAttribution._();

  /// Salita mismo ng CDC, hindi salin ko. May sarili silang Tagalog nito sa
  /// paanan ng bawat checklist, kaya iyon ang ginamit.
  static String get notice => tr(
    'Ang checklist ng milestone na ito ay hindi pamalit sa nakabatay sa '
        'pamantayan, naberipika na kasangkapan sa pagsusuri ng paglaki. Ang mga '
        'milestone na ito ay karaniwang magagawa ng karamihan sa mga bata '
        '(75% o higit pa) sa bawat edad. Pinili ng mga eksperto sa paksa ang mga '
        'milestone na ito batay sa available na data at pinagkasunduan ng '
        'eksperto.',
    'Developmental milestones are things most children (75% or more) can do '
        'by a certain age. Learn the Signs. Act Early. materials are not a '
        'substitute for standardized, validated developmental screening tools.',
  );

  /// Eksaktong pananalitang ipinabigay ng CDC sa email nila, hindi salin.
  /// Sipi ito, kaya nananatiling Ingles kahit anong wika ang piliin — at
  /// dito lang sa loob ng kahon ng sanggunian nakasulat ang "CDC", ayon sa
  /// hiling nilang huwag itong ikalat sa buong app.
  static const String citation =
      'Developmental milestone content adapted from the U.S. Centers for '
      'Disease Control and Prevention, Learn the Signs. Act Early. program '
      '(www.cdc.gov/ActEarly; accessed August 26, 2026).';

  static const String linkLabel = 'cdc.gov/ActEarly';

  /// Hinihikayat nilang mag-link imbes na kumopya. Hindi natin kayang sundin
  /// iyon nang buo dahil offline ang app, kaya ito ang kapalit.
  static final Uri linkUri = Uri.parse('https://www.cdc.gov/ActEarly');

  static String get endorsement => tr(
    'Ang paggamit natin nito ay hindi nangangahulugang inendorso tayo ng '
        'CDC, ATSDR, HHS, o ng pamahalaan ng Estados Unidos.',
    'Our use of this material does not imply endorsement by CDC, ATSDR, HHS, '
        'or the United States Government.',
  );

  static String get free => tr(
    'Libreng makukuha ang materyal na ito sa website nila.',
    'This material is otherwise available on the agency website for no '
        'charge.',
  );
}
