import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../core/i18n/language_controller.dart';

enum CenterType {
  public,
  private;

  String get label => switch (this) {
    CenterType.public => tr('Pampubliko', 'Public'),
    CenterType.private => tr('Pribado', 'Private'),
  };
}

/// Magkaibang pangangailangan ang dalawa, kaya hindi sila dapat pinagsasama.
/// Ang therapy ay sesyon, minsan o dalawang beses sa isang linggo. Ang paaralan
/// ay pinapasukan araw-araw. Ang magulang na naghahanap ng sesyon at nakakuha
/// ng enrollment ay nasayang ang tawag.
enum CenterKind {
  therapy,
  school;

  String get label => switch (this) {
    CenterKind.therapy => tr('Therapy', 'Therapy'),
    CenterKind.school => tr('Paaralan', 'School'),
  };

  String get description => switch (this) {
    CenterKind.therapy => tr(
      'Sesyon ng OT, speech, o ABA',
      'OT, speech, or ABA sessions',
    ),
    CenterKind.school => tr(
      'Pinapasukan araw-araw',
      'Attended every school day',
    ),
  };
}

/// Isang lugar na mapagpapatingnan.
///
/// Nasa asset at hindi sa code para mapalitan ang listahan nang hindi
/// naghihintay ng bagong bersyon sa Play Store.
class ConsultationCenter {
  const ConsultationCenter({
    required this.id,
    required this.name,
    required this.kind,
    required this.type,
    required this.region,
    required this.address,
    this.contactNumber,
    this.scheduleFil,
    this.scheduleEn,
    this.closedOnFil,
    this.closedOnEn,
    this.facebookUrl,
    this.notesFil,
    this.notesEn,
    this.verifiedOn,
  });

  final String id;
  final String name;
  final CenterKind kind;
  final CenterType type;
  final String region;
  final String address;

  /// Maaaring wala. Mas mabuting walang numero kaysa maling numero — may
  /// magulang na tatawag dito, gagastos ng pamasahe, at magdadala ng bata.
  final String? contactNumber;

  /// Oras ng bukas. Nakakatipid ito ng tawag na hindi sasagutin.
  final String? scheduleFil;
  final String? scheduleEn;

  /// Bukod sa `schedule` para hindi na kailangang hanapin ang salitang
  /// "Sarado" sa loob ng pangungusap — iba ang salitang iyon kada wika.
  final String? closedOnFil;
  final String? closedOnEn;

  /// Mas mabuting palatandaan ito kaysa numero: kung tahimik ang page nang
  /// matagal, malamang sarado na sila. Nakikita iyon ng magulang bago pa siya
  /// bumiyahe.
  final String? facebookUrl;

  final String? notesFil;
  final String? notesEn;

  /// Kailan huling natawagan at nakumpirma, sa anyong `YYYY-MM`. Nakikita ng
  /// magulang para alam niya kung gaano kasariwa ang impormasyon.
  final String? verifiedOn;

  /// Pinipili sa oras ng pagguhit at hindi sa `fromJson`: naka-cache ang
  /// listahan, kaya hindi na ito babasahin ulit kapag nagpalit ng wika.
  String? get schedule => _pick(scheduleFil, scheduleEn);
  String? get closedOn => _pick(closedOnFil, closedOnEn);
  String? get notes => _pick(notesFil, notesEn);

  /// Ang Filipino ang kapalit kapag walang salin — mas mabuting may nabasa
  /// ang magulang kaysa blangko.
  static String? _pick(String? fil, String? en) {
    if (fil == null) return en;
    return tr(fil, en ?? fil);
  }

  static ConsultationCenter? fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String?)?.trim() ?? '';
    final name = (json['name'] as String?)?.trim() ?? '';
    if (id.isEmpty || name.isEmpty) return null;

    return ConsultationCenter(
      id: id,
      name: name,
      kind: json['kind'] == 'school' ? CenterKind.school : CenterKind.therapy,
      type: json['type'] == 'private' ? CenterType.private : CenterType.public,
      region: (json['region'] as String?)?.trim() ?? '',
      address: (json['address'] as String?)?.trim() ?? '',
      contactNumber: _clean(json['contactNumber']),
      scheduleFil: _clean(json['schedule']),
      scheduleEn: _clean(json['scheduleEn']),
      closedOnFil: _clean(json['closedOn']),
      closedOnEn: _clean(json['closedOnEn']),
      facebookUrl: _clean(json['facebookUrl']),
      notesFil: _clean(json['notes']),
      notesEn: _clean(json['notesEn']),
      verifiedOn: _clean(json['verifiedOn']),
    );
  }

  static String? _clean(dynamic value) {
    final text = (value as String?)?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}

class ConsultationCenters {
  const ConsultationCenters._();

  static const String assetPath = 'assets/data/verified_centers.json';

  static List<ConsultationCenter>? _cache;

  /// Blangko ang listahan hangga't walang napatunayang datos. Ang blangko ay
  /// tapat; ang gawa-gawang listahan ay magpapabiyahe ng magulang nang wala
  /// namang pupuntahan.
  static Future<List<ConsultationCenter>> load() async {
    final cached = _cache;
    if (cached != null) return cached;

    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! List) return _cache = const [];

      final centers = decoded
          .whereType<Map<String, dynamic>>()
          .map(ConsultationCenter.fromJson)
          .whereType<ConsultationCenter>()
          .toList();

      // Dito inaayos at hindi sa asset: hindi na kailangang hanapin ang tamang
      // puwesto tuwing may idadagdag na bagong sentro.
      centers.sort((a, b) {
        final byRegion = a.region.toLowerCase().compareTo(
          b.region.toLowerCase(),
        );
        if (byRegion != 0) return byRegion;

        final byKind = a.kind.index.compareTo(b.kind.index);
        if (byKind != 0) return byKind;

        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return _cache = centers;
    } catch (error) {
      debugPrint('ConsultationCenters: $error');
      return _cache = const [];
    }
  }
}
