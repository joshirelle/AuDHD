import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/kiko_card.dart';

/// Pag-save ng lahat ng datos sa isang file, at pagbalik nito.
///
/// Nasa telepono lang ang datos ng app. Kapag nasira o nawala ang telepono,
/// wala nang mababalikan — ito ang tanging paraan para hindi ito mangyari.
class BackupCard extends StatefulWidget {
  const BackupCard({super.key, this.onRestored});

  /// Kailangan para mag-refresh ang screen matapos mapalitan ang datos.
  final VoidCallback? onRestored;

  @override
  State<BackupCard> createState() => _BackupCardState();
}

class _BackupCardState extends State<BackupCard> {
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    final result = await BackupService.exportToFile();
    if (!mounted) return;
    setState(() => _busy = false);
    reportBackupResult(context, result);
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    final restored = await showRestoreFlow(context);
    if (!mounted) return;
    setState(() => _busy = false);
    if (restored) widget.onRestored?.call();
  }

  @override
  Widget build(BuildContext context) {
    final lastBackup = BackupService.lastBackupAt();

    return KikoCard(
      backgroundColor: AppColors.tintGold,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.butterInk.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.save_rounded,
                  color: AppColors.butterInk,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  tr('Kopya ng Datos', 'Data Backup'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tr(
              'Hindi na mababalik ang mga naitala mo kapag nasira, nawala, o '
              'na-format ang telepono. Gumawa ng kopya paminsan-minsan.',
              'What you have recorded can no longer be brought back if the '
              'phone breaks, gets lost, or is formatted. Make a backup once in '
              'a while.',
            ),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textDark,
              height: 1.4,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                tr('Huling kopya: ', 'Last backup: '),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontFamily: 'Nunito',
                ),
              ),
              Text(
                lastBackup == null
                    ? tr('Wala pa', 'None yet')
                    : DateFormatter.longDate(lastBackup),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: lastBackup == null
                      ? AppColors.danger
                      : AppColors.textDark,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _busy ? null : _export,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.logoGreen,
                    disabledBackgroundColor: AppColors.divider,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    tr('Gumawa ng kopya', 'Make a backup'),
                    style: const TextStyle(
                      color: AppColors.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : _import,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.butterInk,
                    side: const BorderSide(color: AppColors.butterInk),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    tr('Ibalik', 'Restore'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ibinabalik ang datos mula sa isang file na pipiliin ng magulang.
///
/// Nagtatanong muna kapag may datos na sa app — pinapatungan ito ng laman ng
/// file at wala nang paraan para maibalik ang naunang laman.
///
/// Nagbabalik ng `true` kapag napalitan ang datos, para makapag-refresh ang
/// screen na tumawag.
Future<bool> showRestoreFlow(BuildContext context) async {
  final hasExistingData =
      HiveService.getChildProfile() != null ||
      HiveService.getBehaviorBox().isNotEmpty ||
      HiveService.getSensoryBox().isNotEmpty;

  if (hasExistingData) {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr('Papalitan ang datos?', 'Replace the data?')),
        content: Text(
          tr(
            'Papalitan ng laman ng file ang lahat ng nasa app ngayon — '
            'mga behavior log, sensory history, milestone, at mood.\n\n'
            'Hindi na maibabalik ang kasalukuyang laman.',
            'The contents of the file will replace everything in the app right '
            'now — the behavior logs, sensory history, milestones, and mood.'
            '\n\n'
            'The current contents can no longer be brought back.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('Kanselahin', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              tr('Ipagpatuloy', 'Continue'),
              style: const TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (proceed != true) return false;
  }

  final result = await BackupService.importFromFile();
  if (!context.mounted) return result.isSuccess;
  reportBackupResult(context, result);
  return result.isSuccess;
}

/// Walang ipinapakitang mensahe kapag ang magulang mismo ang umatras.
void reportBackupResult(BuildContext context, BackupResult result) {
  if (result.isCancelled) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(result.message),
      backgroundColor: result.isSuccess ? AppColors.success : AppColors.danger,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
