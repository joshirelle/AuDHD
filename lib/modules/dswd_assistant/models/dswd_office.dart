import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../core/i18n/language_controller.dart';

/// Mga link at numerong galing mismo sa DSWD.
///
/// Dito lang nakasulat ang bagay na nabuksan at nabasa sa opisyal na pahina.
/// Ang natitira ay nasa asset, kung saan may `verifiedOn`.
class DswdOfficial {
  const DswdOfficial._();

  /// Paliwanag ng AICS sa sariling portal nito.
  static final Uri aicsProgram = Uri.parse(
    'https://aics.dswd.gov.ph/aics-program/',
  );

  /// Opisyal na listahan ng Field Office at SWAD satellite office.
  static final Uri officeList = Uri.parse(
    'https://aics.dswd.gov.ph/list-of-fos-swad-satellite-offices/',
  );

  /// Dito nakasulat ang kinikilalang requirements at processing time. Ito ang
  /// masasandalan ng magulang kapag may hinihinging wala sa listahan.
  static final Uri citizensCharter = Uri.parse(
    'https://www.dswd.gov.ph/quality-policy-and-cc/#cc2025',
  );

  static const String hotline = '(632) 8-931-81-01 to 07';

  /// Ang unang numero lang ng hotline — ito ang maipapasok sa dialer.
  static const String hotlineDialable = '+63289318101';

  static const List<String> mobileNumbers = [
    '0917 110 5686',
    '0917 827 2543',
    '0919 911 6200',
  ];

  static const String email = 'inquiry@dswd.gov.ph';
}

/// Magkaibang bagay ang ipinapakitang numero at ang idi-dial.
///
/// Ganito nakasulat sa opisyal na listahan: `(02) 733-0010 to 18`. Saklaw iyon,
/// hindi iisang numero — kapag inalis ang hindi digit ay nagiging
/// `027330001018`, at wala itong tatawagan.
class DswdPhone {
  const DswdPhone({required this.label, this.dial});

  final String label;

  /// `null` kapag hindi tiyak ang eksaktong idi-dial. Nakikita pa rin ng
  /// magulang ang numero — nababasa niya ito — pero walang pindutan.
  final String? dial;

  bool get isDialable => dial != null;

  static DswdPhone? fromJson(dynamic value) {
    if (value is String) {
      final label = value.trim();
      if (label.isEmpty) return null;
      return DswdPhone(label: label, dial: _dialFrom(label));
    }

    if (value is Map) {
      final label = (value['label'] as String?)?.trim() ?? '';
      if (label.isEmpty) return null;
      final dial = (value['dial'] as String?)?.trim() ?? '';
      return DswdPhone(label: label, dial: dial.isEmpty ? null : dial);
    }

    return null;
  }

  /// Kusang idi-dial lang kapag numero lang ang laman. Ang kahit anong titik —
  /// `Tel:`, `to`, `loc` — ay tanda na may hindi tayo alam.
  static String? _dialFrom(String label) {
    if (RegExp(r'[A-Za-z]').hasMatch(label)) return null;
    final digits = label.replaceAll(RegExp(r'[^\d+]'), '');
    return digits.length < 7 ? null : digits;
  }
}

/// Isang opisina na puwedeng puntahan para sa AICS.
///
/// Nasa asset at hindi sa code, gaya ng `ConsultationCenter`: nagbabago ang
/// satellite office nang hindi naghihintay ng bagong bersyon sa Play Store.
class DswdOffice {
  const DswdOffice({
    required this.id,
    required this.city,
    required this.officeName,
    this.address,
    this.contactNumbers = const [],
    this.email,
    this.contactPerson,
    this.operatingHoursFil,
    this.operatingHoursEn,
    this.notesFil,
    this.notesEn,
    this.officialSourceUrl,
    this.verifiedOn,
  });

  final String id;
  final String city;
  final String officeName;

  /// Lahat ng nasa ibaba ay maaaring wala. Mas mabuting kulang kaysa mali —
  /// may magulang na gagastos ng pamasahe dito, kasama ang bata.
  final String? address;
  final List<DswdPhone> contactNumbers;
  final String? email;
  final String? contactPerson;
  final String? operatingHoursFil;
  final String? operatingHoursEn;
  final String? notesFil;
  final String? notesEn;
  final String? officialSourceUrl;

  /// Kailan huling nakumpirma, sa anyong `YYYY-MM`. Ipinapakita sa magulang
  /// para alam niya kung gaano kasariwa ang nakikita niya.
  final String? verifiedOn;

  String? get operatingHours => _pick(operatingHoursFil, operatingHoursEn);
  String? get notes => _pick(notesFil, notesEn);

  static String? _pick(String? fil, String? en) {
    if (fil == null) return en;
    return tr(fil, en ?? fil);
  }

  static DswdOffice? fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String?)?.trim() ?? '';
    final city = (json['city'] as String?)?.trim() ?? '';
    final officeName = (json['officeName'] as String?)?.trim() ?? '';
    if (id.isEmpty || city.isEmpty || officeName.isEmpty) return null;

    return DswdOffice(
      id: id,
      city: city,
      officeName: officeName,
      address: _clean(json['address']),
      contactNumbers: _phones(json['contactNumbers']),
      email: _clean(json['email']),
      contactPerson: _clean(json['contactPerson']),
      operatingHoursFil: _clean(json['operatingHours']),
      operatingHoursEn: _clean(json['operatingHoursEn']),
      notesFil: _clean(json['notes']),
      notesEn: _clean(json['notesEn']),
      officialSourceUrl: _clean(json['officialSourceUrl']),
      verifiedOn: _clean(json['verifiedOn']),
    );
  }

  static String? _clean(dynamic value) {
    final text = (value as String?)?.trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static List<DswdPhone> _phones(dynamic value) {
    if (value is! List) return const [];
    return value
        .map(DswdPhone.fromJson)
        .whereType<DswdPhone>()
        .toList(growable: false);
  }
}

class DswdOffices {
  const DswdOffices._();

  static const String assetPath = 'assets/data/dswd_offices.json';

  static List<DswdOffice>? _cache;

  /// Blangko hangga't walang napatunayan. Ang blangko ay tapat; ang gawa-gawang
  /// address ay magpapabiyahe ng magulang nang wala namang pupuntahan.
  static Future<List<DswdOffice>> load() async {
    final cached = _cache;
    if (cached != null) return cached;

    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! List) return _cache = const [];

      final offices = decoded
          .whereType<Map<String, dynamic>>()
          .map(DswdOffice.fromJson)
          .whereType<DswdOffice>()
          .toList();

      offices.sort((a, b) {
        final byCity = a.city.toLowerCase().compareTo(b.city.toLowerCase());
        if (byCity != 0) return byCity;
        return a.officeName.toLowerCase().compareTo(b.officeName.toLowerCase());
      });

      return _cache = offices;
    } catch (error) {
      debugPrint('DswdOffices: $error');
      return _cache = const [];
    }
  }

  /// Ang lungsod na may opisina lang ang nagiging chip. Ang labimpitong chip
  /// na pawang walang laman ay hindi pagpipilian — pagkabigo iyon nang
  /// labimpitong beses.
  static List<String> citiesIn(List<DswdOffice> offices) {
    final seen = <String>{for (final office in offices) office.city};
    return seen.toList()..sort();
  }
}
