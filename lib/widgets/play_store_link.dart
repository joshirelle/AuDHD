import 'dart:io';

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

/// Apple ID ng app mula sa App Store Connect.
const String appStoreAppId = '6809516355';

const String _appStoreUrl =
    'https://apps.apple.com/app/id$appStoreAppId?action=write-review';

/// Bubukas ang store ng plataporma; doon mismo magra-rate ang magulang, hindi
/// sa loob ng app. Habang nasa closed testing, pribadong napupunta sa developer
/// ang isinulat nila at hindi ito lumalabas sa publiko.
Future<void> openPlayStoreListing(BuildContext context) async {
  final isApple = Platform.isIOS || Platform.isMacOS;
  // Hindi dumadaan sa canLaunchUrl: nagbabalik ito ng false sa ilang device
  // kahit kayang buksan ang link.
  final isLaunched = await launchUrl(
    Uri.parse(isApple ? _appStoreUrl : playStoreUrl),
    mode: LaunchMode.externalApplication,
  );
  if (isLaunched || !context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        tr(
          'Hindi mabuksan ang store. Subukan ulit mamaya.',
          'Could not open the store. Please try again later.',
        ),
      ),
      backgroundColor: AppColors.danger,
    ),
  );
}
