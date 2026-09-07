import 'package:flutter/material.dart';

import '../../core/i18n/language_controller.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/prep_guide_widget.dart';

/// Gabay bago at habang naghihintay ng konsultasyon.
///
/// Hindi ito nagsasabi kung ano ang kondisyon ng bata. Sinasabi nito kung ano
/// ang dalhin at ano ang aasahan.
///
/// Walang hanay ng tab habang v6: nakatago muna ang `DirectoryShellWidget`
/// hangga't hindi kumpleto ang listahan ng klinika, at ang hanay na iisa lang
/// ang mapipili ay hindi kontrol. Nasa dulo ng gabay ang pasukan sa DSWD.
class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Gabay sa Konsultasyon', 'Consultation Guide')),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: const SafeArea(child: PrepGuideWidget()),
    );
  }
}
