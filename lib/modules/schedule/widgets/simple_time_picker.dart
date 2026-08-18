import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Payak na pagpili ng oras.
///
/// Hindi ginagamit ang `showTimePicker` ng Material: pumapalya ito ng
/// `BoxConstraints has non-normalized height constraints` kapag binuksan ang
/// keyboard mode sa kulang na taas. Dropdown lang ito, kaya walang ganoong
/// panganib — at kamukha ng iba pang bahagi ng app.
Future<TimeOfDay?> showSimpleTimePicker(
  BuildContext context,
  TimeOfDay? initial,
) {
  return showDialog<TimeOfDay>(
    context: context,
    builder: (context) => _SimpleTimePickerDialog(initial: initial),
  );
}

class _SimpleTimePickerDialog extends StatefulWidget {
  const _SimpleTimePickerDialog({this.initial});

  final TimeOfDay? initial;

  @override
  State<_SimpleTimePickerDialog> createState() =>
      _SimpleTimePickerDialogState();
}

class _SimpleTimePickerDialogState extends State<_SimpleTimePickerDialog> {
  late int _hour12;
  late int _minute;
  late bool _isMorning;

  @override
  void initState() {
    super.initState();
    final start = widget.initial ?? const TimeOfDay(hour: 7, minute: 0);
    _hour12 = start.hour % 12 == 0 ? 12 : start.hour % 12;
    _minute = start.minute;
    _isMorning = start.hour < 12;
  }

  TimeOfDay get _value {
    final base = _hour12 % 12;
    return TimeOfDay(hour: _isMorning ? base : base + 12, minute: _minute);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      title: const Text(
        'Anong oras ito ginagawa?',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          fontFamily: 'Nunito',
          color: AppColors.textDark,
        ),
      ),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: _buildDropdown<int>(
              value: _hour12,
              items: List.generate(12, (index) => index + 1),
              label: (hour) => '$hour',
              onChanged: (value) => setState(() => _hour12 = value),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
                color: AppColors.textDark,
              ),
            ),
          ),
          Expanded(
            child: _buildDropdown<int>(
              value: _minute,
              items: List.generate(60, (index) => index),
              label: (minute) => minute.toString().padLeft(2, '0'),
              onChanged: (value) => setState(() => _minute = value),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildDropdown<bool>(
              value: _isMorning,
              items: const [true, false],
              label: (isMorning) => isMorning ? 'AM' : 'PM',
              onChanged: (value) => setState(() => _isMorning = value),
            ),
          ),
        ],
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
          onPressed: () => Navigator.pop(context, _value),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.logoGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
          ),
          child: const Text(
            'Piliin',
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T value) label,
    required ValueChanged<T> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: [
        for (final item in items)
          DropdownMenuItem<T>(
            value: item,
            child: Text(
              label(item),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
                color: AppColors.textDark,
              ),
            ),
          ),
      ],
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
    );
  }
}
