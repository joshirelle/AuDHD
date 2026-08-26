import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

/// Iisang paraan ng pagbukas ng labas ng app, para hindi maulit ang maselang
/// bahagi: ang `try` at ang pagpili ng mode.
class LinkLauncher {
  const LinkLauncher._();

  /// Hindi dumadaan sa `canLaunchUrl`: nagbabalik ito ng `false` sa ilang
  /// device kahit kayang buksan ang link. May `try` naman dahil kapag walang
  /// app na makakabukas, nag-a-throw ito imbes na magbalik ng `false`.
  static Future<bool> tryLaunch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Future<void> open(
    BuildContext context,
    Uri uri,
    String failureMessage,
  ) async {
    if (await tryLaunch(uri)) return;
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(failureMessage),
        backgroundColor: AppColors.danger,
      ),
    );
  }
}
