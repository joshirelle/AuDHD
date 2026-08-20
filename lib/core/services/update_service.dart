import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

/// Tahimik na pag-update mula sa Play.
///
/// Sinadyang `flexible` at hindi `immediate`: gumagana ang AuDHD nang walang
/// internet, kaya hindi tama na harangan ang magulang na walang koneksyon sa
/// araw na kailangan niya ang iskedyul ng anak niya.
class UpdateService {
  /// Nagda-download sa likod, tapos nagtatanong kung puwede nang mag-restart.
  ///
  /// Tahimik na sumusuko kapag walang Play Store, walang koneksyon, o luma ang
  /// bersyon ng device — hindi dahilan ang update para masira ang app.
  static Future<void> checkAndPrompt(BuildContext context) async {
    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability != UpdateAvailability.updateAvailable) return;
      if (!info.flexibleUpdateAllowed) return;

      // Natatapos lang ito kapag tapos na ang pag-download.
      await InAppUpdate.startFlexibleUpdate();
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Handa na ang bagong bersyon ng AuDHD.',
            style: TextStyle(fontFamily: 'Nunito'),
          ),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'I-restart',
            onPressed: InAppUpdate.completeFlexibleUpdate,
          ),
        ),
      );
    } catch (_) {
      // Walang ipinapakitang error: hindi kasalanan ng magulang kung hindi
      // maabot ang Play, at gumagana pa rin ang buong app kahit lumang bersyon.
    }
  }
}
