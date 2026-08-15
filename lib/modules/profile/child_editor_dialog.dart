import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/child_profile.dart';
import '../../data/services/hive_service.dart';

/// Ibinabalik ang `true` kapag may na-save na profile.
class ChildEditorDialog extends StatefulWidget {
  final ChildProfile? existing;

  const ChildEditorDialog({super.key, this.existing});

  @override
  State<ChildEditorDialog> createState() => _ChildEditorDialogState();
}

class _ChildEditorDialogState extends State<ChildEditorDialog> {
  late final TextEditingController _nameController;
  DateTime? _birthDate;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _birthDate = widget.existing?.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 2, now.month, now.day),
      firstDate: DateTime(now.year - 18),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.logoGreen),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Kailangan ang pangalan.');
      return;
    }
    if (_birthDate == null) {
      setState(() => _error = 'Kailangan ang kaarawan.');
      return;
    }

    final profile = ChildProfile(
      id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      birthDate: _birthDate!,
    );
    await HiveService.saveChildProfile(profile);

    // Kapag ito ang unang bata, gawin nang aktibo agad para may magamit ang screening.
    if (HiveService.getActiveChildId() == null) {
      await HiveService.setActiveChildId(profile.id);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final birthText = _birthDate == null
        ? 'Pumili ng kaarawan'
        : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.existing == null ? 'Bagong Bata' : 'Baguhin ang Profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Pangalan ng bata',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: AppColors.logoGreen),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _pickDate,
            icon: const Icon(Icons.cake_rounded, color: AppColors.logoGreen),
            label: Text(
              birthText,
              style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(color: Color(0xFFD9383A), fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Kanselahin'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.logoGreen),
          onPressed: _save,
          child: const Text(
            'I-save',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
