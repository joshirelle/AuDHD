import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';

/// Nagbabalik ng bagong pabuya, o `null` kapag kinansela.
class AddRewardDialog extends StatefulWidget {
  const AddRewardDialog({super.key});

  static Future<({String label, int stars})?> show(BuildContext context) {
    return showDialog<({String label, int stars})>(
      context: context,
      builder: (context) => const AddRewardDialog(),
    );
  }

  @override
  State<AddRewardDialog> createState() => _AddRewardDialogState();
}

class _AddRewardDialogState extends State<AddRewardDialog> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _starsController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _labelController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  void _save() {
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      setState(
        () => _error = tr(
          'Kailangan ang pangalan ng pabuya.',
          'Please enter a reward name.',
        ),
      );
      return;
    }

    final stars = int.tryParse(_starsController.text.trim());
    if (stars == null || stars < 1) {
      setState(
        () => _error = tr(
          'Kailangan ng bilang ng bituin, hindi bababa sa 1.',
          'Enter how many stars, at least 1.',
        ),
      );
      return;
    }

    Navigator.pop(context, (label: label, stars: stars));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      title: Text(
        tr('Bagong Pabuya', 'New Reward'),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Nunito',
          color: AppColors.textDark,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _labelController,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 60,
            decoration: InputDecoration(
              labelText: tr('Pabuya', 'Reward'),
              hintText: tr(
                'Halimbawa: Manood ng paboritong palabas',
                'Example: Watch a favorite show',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          TextField(
            controller: _starsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 3,
            decoration: InputDecoration(
              labelText: tr('Kailangang bituin', 'Stars needed'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          if (_error != null)
            Text(
              _error!,
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: 12,
                fontFamily: 'Nunito',
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            tr('Kanselahin', 'Cancel'),
            style: const TextStyle(
              fontFamily: 'Nunito',
              color: AppColors.textDark,
            ),
          ),
        ),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.logoGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
          ),
          child: Text(
            tr('I-dagdag', 'Add'),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
