import 'package:flutter/foundation.dart';

import '../../data/services/hive_service.dart';

enum AppLanguage {
  filipino('fil'),
  english('eng');

  const AppLanguage(this.code);

  final String code;
}

/// Piniling wika ng magulang.
///
/// May magulang na nagsabing Ingles lang ang naiintindihan ng anak nila, kaya
/// hindi ito kagustuhan lang sa hitsura — nakadepende rito kung magagamit ba
/// ng bata ang app.
class LanguageController {
  static const String _key = 'selected_language';

  static final ValueNotifier<AppLanguage> notifier = ValueNotifier(_read());

  static AppLanguage get current => notifier.value;
  static bool get isEnglish => notifier.value == AppLanguage.english;

  static AppLanguage _read() {
    // Hindi dapat bumagsak ang app kung hindi pa bukas ang Hive, halimbawa
    // sa widget test — Filipino ang bumabagsak na sagot.
    Object? saved;
    try {
      saved = HiveService.getPrefsBox().get(_key);
    } catch (_) {
      return AppLanguage.filipino;
    }
    for (final lang in AppLanguage.values) {
      if (lang.code == saved) return lang;
    }
    return AppLanguage.filipino;
  }

  static Future<void> set(AppLanguage lang) async {
    if (lang == notifier.value) return;
    await HiveService.getPrefsBox().put(_key, lang.code);
    notifier.value = lang;
  }

  /// Kailangan matapos ang pagbalik ng datos: nasa Hive na ang bagong wika
  /// pero luma pa ang hawak sa memorya.
  static void refreshFromStorage() => notifier.value = _read();
}

/// Pumipili ng teksto ayon sa wika.
///
/// Magkasama ang dalawang salin sa mismong pinaggagamitan para walang susing
/// maiiwang walang kapares, at para makita agad sa diff kung alin ang naisalin
/// na. Ang hindi pa nadadaanang screen ay nananatiling Filipino.
String tr(String fil, String eng) => LanguageController.isEnglish ? eng : fil;
