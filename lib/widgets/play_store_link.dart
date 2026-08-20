import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/i18n/language_controller.dart';
import '../core/theme/app_theme.dart';

/// Play Store listing ng AuDHD.
///
/// Ginagamit ang `https` na anyo at hindi `market://` para sakop na ito ng
/// `<queries>` na nasa manifest — walang kailangang idagdag doon.
const String playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.audhd.app';

/// Bubukas ang Play Store; doon mismo magra-rate ang magulang, hindi sa loob
/// ng app. Habang nasa closed testing, pribadong napupunta sa developer ang
/// isinulat nila at hindi ito lumalabas sa publiko.
Future<void> openPlayStoreListing(BuildContext context) async {
  // Hindi dumadaan sa canLaunchUrl: nagbabalik ito ng false sa ilang device
  // kahit kayang buksan ang link.
  final isLaunched = await launchUrl(
    Uri.parse(playStoreUrl),
    mode: LaunchMode.externalApplication,
  );
  if (isLaunched || !context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        tr(
          'Hindi mabuksan ang Play Store. Subukan ulit mamaya.',
          'Could not open the Play Store. Please try again later.',
        ),
      ),
      backgroundColor: AppColors.danger,
    ),
  );
}
