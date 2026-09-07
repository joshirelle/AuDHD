import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Tatlong hugis na ginagamit ng bawat listahan ng lugar sa app.
///
/// Nandito sila para iisa ang hitsura ng address at numero saanman sila
/// lumabas: ang magulang na natutong pindutin ang address sa isang listahan
/// ay hindi na dapat mag-aral muli sa kasunod.

/// Ang datos mismo ang pinipindot — address, numero.
///
/// May salungguhit dahil hindi sapat ang kulay: may hindi nakakakita ng
/// pagkakaiba ng asul at itim.
class ContactLinkRow extends StatelessWidget {
  const ContactLinkRow({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.accentBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.bold,
                color: AppColors.accentBlue,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.accentBlue,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nababasa lang, walang pinupuntahan.
class ContactInfoRow extends StatelessWidget {
  const ContactInfoRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ],
    );
  }
}

/// Paalis ng app — Facebook page, opisyal na website.
///
/// `textDark` ang titik at hindi `accentBlue`: nasa gilid lang ng 4.5:1 ang
/// asul sa `tintBlue`, at maliit na titik ito. Nasa icon na lang ang kulay.
class ContactPill extends StatelessWidget {
  const ContactPill({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.showsExternalMark = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Tanda na may bubuksang ibang app. Walang tanda ang dialer at ang mapa:
  /// alam na ng magulang kung saan siya pupunta doon.
  final bool showsExternalMark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.tintBlue,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.accentBlue),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            if (showsExternalMark) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.open_in_new_rounded,
                size: 12,
                color: AppColors.accentBlue,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
