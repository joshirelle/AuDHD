import 'package:flutter/material.dart';
import '../../core/i18n/language_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
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
  late final TextEditingController _nicknameController;
  DateTime? _birthDate;
  Gender? _gender;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _nicknameController = TextEditingController(
      text: widget.existing?.nickname ?? '',
    );
    _birthDate = widget.existing?.birthDate;
    _gender = widget.existing?.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 2, now.month, now.day),
      firstDate: DateTime(now.year - 18),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(
        () => _error = tr('Kailangan ang pangalan.', 'The name is needed.'),
      );
      return;
    }
    if (_birthDate == null) {
      setState(
        () => _error = tr('Kailangan ang kaarawan.', 'The birthday is needed.'),
      );
      return;
    }

    final nickname = _nicknameController.text.trim();
    final profile = ChildProfile(
      name: name,
      birthDate: _birthDate!,
      gender: _gender,
      nickname: nickname.isEmpty ? null : nickname,
      // Wala nito sa form; kung hindi dadalhin, mabubura ang litrato tuwing
      // babaguhin ang pangalan.
      photoFileName: widget.existing?.photoFileName,
    );
    await HiveService.saveChildProfile(profile);

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final birthText = _birthDate == null
        ? tr('Pumili ng kaarawan', 'Choose a birthday')
        : DateFormatter.longDate(_birthDate!);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.existing == null
            ? tr('Bagong Bata', 'New Child')
            : tr('Baguhin ang Profile', 'Edit Profile'),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: tr('Pangalan ng bata', 'Name of the child'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nicknameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: tr('Palayaw (opsyonal)', 'Nickname (optional)'),
              border: const OutlineInputBorder(),
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
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildGenderOption(
                  Gender.male,
                  Icons.male_rounded,
                  AppColors.genderBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenderOption(
                  Gender.female,
                  Icons.female_rounded,
                  AppColors.genderPink,
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.danger, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(tr('Kanselahin', 'Cancel')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.logoGreen),
          onPressed: _save,
          child: Text(
            tr('I-save', 'Save'),
            style: const TextStyle(color: AppColors.surface, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption(Gender gender, IconData icon, Color color) {
    final isSelected = _gender == gender;

    return InkWell(
      // Muling pagpindot ay nagbubura, dahil opsyonal ang kasarian.
      onTap: () => setState(() => _gender = isSelected ? null : gender),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          size: 32,
          color: isSelected ? color : AppColors.textMuted,
        ),
      ),
    );
  }
}
