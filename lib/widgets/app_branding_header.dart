import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Panturo ng bigkas. Nakahiwalay para magamit sa home header kada buksan,
/// hindi lang sa onboarding.
class AppPhoneticBadge extends StatelessWidget {
  const AppPhoneticBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.skyBlueLight,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon sa halip na emoji dahil walang emoji glyph ang Nunito.
          Icon(Icons.volume_up_rounded, size: 14, color: AppColors.accentBlue),
          SizedBox(width: 4),
          Text(
            '/Aw-D-H-D/',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: AppColors.accentBlue,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}

class AppBrandingHeader extends StatelessWidget {
  const AppBrandingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'AuDHD',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.logoGreen,
                fontFamily: 'Fredoka',
              ),
            ),
            SizedBox(width: 10),
            AppPhoneticBadge(),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Araw-araw na gabay para sa bawat batang AuDHD.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
            height: 1.35,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }
}
