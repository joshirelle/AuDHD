import 'package:flutter/material.dart';
import '../core/i18n/language_controller.dart';
import '../core/theme/app_theme.dart';

/// Walang callback: minamarkahan ng `main.dart` ang buong puno kapag nagpalit
/// ng wika, kaya kusa nang muling iginuguhit ang tumatawag dito.
class LanguageChips extends StatelessWidget {
  const LanguageChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final lang in AppLanguage.values) ...[
          if (lang != AppLanguage.values.first) const SizedBox(width: 8),
          _LanguageChip(lang: lang),
        ],
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final AppLanguage lang;

  const _LanguageChip({required this.lang});

  @override
  Widget build(BuildContext context) {
    final isActive = LanguageController.current == lang;
    // Hindi isinasalin: ang pangalan ng wika ay dapat mabasa ng naghahanap
    // nito, kahit hindi niya naiintindihan ang kasalukuyang wika ng app.
    final label = lang == AppLanguage.filipino ? 'Filipino' : 'English';

    return Semantics(
      selected: isActive,
      button: true,
      child: GestureDetector(
        onTap: () => LanguageController.set(lang),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.logoGreen : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.surface : AppColors.textMuted,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ),
    );
  }
}
