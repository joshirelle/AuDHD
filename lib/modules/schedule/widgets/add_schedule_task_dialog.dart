import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/schedule_task.dart';
import '../../../core/theme/app_theme.dart';
import 'schedule_style.dart';

/// Nagbabalik ng bagong `ScheduleTask`, o `null` kapag kinansela.
class AddScheduleTaskDialog extends StatefulWidget {
  const AddScheduleTaskDialog({super.key});

  static Future<ScheduleTask?> show(BuildContext context) {
    return showDialog<ScheduleTask>(
      context: context,
      builder: (context) => const AddScheduleTaskDialog(),
    );
  }

  @override
  State<AddScheduleTaskDialog> createState() => _AddScheduleTaskDialogState();
}

class _AddScheduleTaskDialogState extends State<AddScheduleTaskDialog> {
  final TextEditingController _nameController = TextEditingController();
  String _iconKey = ScheduleIcons.pickerKeys.first;
  ScheduleTimeOfDay _timeOfDay = ScheduleTimeOfDay.morning;
  bool _showNameError = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _showNameError = true);
      return;
    }

    Navigator.pop(
      context,
      ScheduleTask(
        id: const Uuid().v4(),
        titleTagalog: name,
        iconKey: _iconKey,
        timeOfDay: _timeOfDay,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      title: const Text(
        'Bagong Gawain',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Nunito',
          color: AppColors.textDark,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 30,
              onChanged: (_) {
                if (_showNameError) setState(() => _showNameError = false);
              },
              decoration: InputDecoration(
                hintText: 'Halimbawa: Pag-iinom ng gamot',
                errorText: _showNameError ? 'Kailangan ng pangalan.' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildLabel('Kailan?'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final time in ScheduleTimeOfDay.values)
                  _buildTimeChip(time),
              ],
            ),
            const SizedBox(height: 18),
            _buildLabel('Pumili ng icon'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final key in ScheduleIcons.pickerKeys) _buildIconTile(key),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Kanselahin',
            style: TextStyle(fontFamily: 'Nunito', color: Colors.grey),
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
          child: const Text(
            'I-dagdag',
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        fontFamily: 'Nunito',
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildTimeChip(ScheduleTimeOfDay time) {
    final style = ScheduleTimeStyle.of(time);
    final isSelected = _timeOfDay == time;

    return GestureDetector(
      onTap: () => setState(() => _timeOfDay = time),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? style.accent : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(
            color: isSelected ? style.accent : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              style.icon,
              size: 15,
              color: isSelected ? Colors.white : style.accent,
            ),
            const SizedBox(width: 5),
            Text(
              time.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconTile(String key) {
    final isSelected = _iconKey == key;

    return Semantics(
      selected: isSelected,
      child: GestureDetector(
        onTap: () => setState(() => _iconKey = key),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.mintGreen : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.logoGreen : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Icon(
            ScheduleIcons.of(key),
            size: 22,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
