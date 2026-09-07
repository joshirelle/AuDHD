import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/i18n/language_controller.dart';
import '../../core/services/child_photo_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/age_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/child_profile.dart';
import '../../data/services/hive_service.dart';
import 'widgets/birthday_picker_sheet.dart';

enum _PhotoAction { camera, gallery, remove }

/// Ibinabalik ang `true` kapag may na-save na profile.
///
/// Bottom sheet at hindi `AlertDialog`: hindi nagsi-scroll ang `content` ng
/// `AlertDialog`, at umaapaw ang form na ito kapag umangat ang keyboard.
class ChildEditorDialog extends StatefulWidget {
  final ChildProfile? existing;

  const ChildEditorDialog({super.key, this.existing});

  static Future<bool?> show(BuildContext context, {ChildProfile? existing}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChildEditorDialog(existing: existing),
    );
  }

  @override
  State<ChildEditorDialog> createState() => _ChildEditorDialogState();
}

class _ChildEditorDialogState extends State<ChildEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _nicknameController;
  DateTime? _birthDate;
  Gender? _gender;
  final Set<SupportFocus> _focus = {};
  String? _photoFileName;

  /// Mga litratong nakuha sa sesyong ito. Kung hindi na-save, basura sila sa
  /// disk na walang nakakaalam — kaya sinusundan sila hanggang sa dulo.
  final List<String> _pickedThisSession = [];

  bool _showNameError = false;
  bool _showBirthError = false;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _nicknameController = TextEditingController(
      text: widget.existing?.nickname ?? '',
    );
    _birthDate = widget.existing?.birthDate;
    _gender = widget.existing?.gender;
    _photoFileName = widget.existing?.photoFileName;
    _focus.addAll(widget.existing?.supportFocus ?? const []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showBirthdayPicker(context, _birthDate);
    if (picked == null) return;
    setState(() {
      _birthDate = picked;
      _showBirthError = false;
    });
  }

  Future<void> _changePhoto() async {
    final action = await _askPhotoAction();
    if (action == null) return;

    if (action == _PhotoAction.remove) {
      setState(() => _photoFileName = null);
      return;
    }

    String? fileName;
    try {
      fileName = await ChildPhotoService.pick(
        action == _PhotoAction.camera
            ? ImageSource.camera
            : ImageSource.gallery,
      );
    } catch (error) {
      debugPrint('ChildPhotoService: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Hindi mabuksan ang litrato. Tingnan ang pahintulot ng app.',
              'The photo cannot be opened. Check the app permission.',
            ),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (fileName == null || !mounted) return;
    _pickedThisSession.add(fileName);
    setState(() => _photoFileName = fileName);
  }

  Future<_PhotoAction?> _askPhotoAction() {
    return showModalBottomSheet<_PhotoAction>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _buildPhotoAction(
              context,
              Icons.photo_camera_rounded,
              tr('Kumuha ng litrato', 'Take a photo'),
              _PhotoAction.camera,
            ),
            _buildPhotoAction(
              context,
              Icons.photo_library_rounded,
              tr('Pumili sa gallery', 'Choose from the gallery'),
              _PhotoAction.gallery,
            ),
            if (_photoFileName != null)
              _buildPhotoAction(
                context,
                Icons.delete_outline_rounded,
                tr('Alisin ang litrato', 'Remove the photo'),
                _PhotoAction.remove,
                isDanger: true,
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoAction(
    BuildContext context,
    IconData icon,
    String label,
    _PhotoAction action, {
    bool isDanger = false,
  }) {
    final color = isDanger ? AppColors.danger : AppColors.textDark;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: color,
        ),
      ),
      onTap: () => Navigator.pop(context, action),
    );
  }

  /// Binubura ang naiwang litrato: ang kuhang hindi napiling itago at, kapag
  /// pinalitan, ang luma. Kung hindi, mananatili sila sa disk magpakailanman.
  Future<void> _cleanUpPhotos({required bool saved}) async {
    for (final fileName in _pickedThisSession) {
      if (saved && fileName == _photoFileName) continue;
      await ChildPhotoService.delete(fileName);
    }

    final original = widget.existing?.photoFileName;
    if (saved && original != null && original != _photoFileName) {
      await ChildPhotoService.delete(original);
    }
  }

  Future<void> _cancel() async {
    await _cleanUpPhotos(saved: false);
    if (mounted) Navigator.pop(context, false);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final hasName = name.isNotEmpty;
    final hasBirth = _birthDate != null;

    if (!hasName || !hasBirth) {
      setState(() {
        _showNameError = !hasName;
        _showBirthError = !hasBirth;
      });
      return;
    }

    setState(() => _isSaving = true);
    await _cleanUpPhotos(saved: true);

    final nickname = _nicknameController.text.trim();
    await HiveService.saveChildProfile(
      ChildProfile(
        id: widget.existing?.id ?? const Uuid().v4(),
        name: name,
        birthDate: _birthDate!,
        gender: _gender,
        nickname: nickname.isEmpty ? null : nickname,
        photoFileName: _photoFileName,
        supportFocus: SupportFocus.values
            .where(_focus.contains)
            .toList(growable: false),
      ),
    );

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  _isEditing
                      ? tr('Baguhin ang Profile', 'Edit Profile')
                      : tr('Bagong Bata', 'New Child'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(child: _buildPhoto()),
              const SizedBox(height: 22),
              _buildSectionLabel(
                tr(
                  'ANO ANG ITATAWAG NATIN SA KANYA?',
                  'WHAT SHOULD WE CALL THEM?',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) {
                  if (_showNameError) setState(() => _showNameError = false);
                },
                decoration: InputDecoration(
                  hintText: tr('Pangalan ng bata', 'The child\'s name'),
                  prefixIcon: const Icon(
                    Icons.person_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  errorText: _showNameError
                      ? tr('Kailangan ang pangalan.', 'The name is needed.')
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nicknameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: tr('Palayaw (opsyonal)', 'Nickname (optional)'),
                  prefixIcon: const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildHint(
                tr(
                  'Ang palayaw ang ipapakita sa buong app kung mayroon nito.',
                  'The nickname is what the app shows if you give one.',
                ),
              ),
              const SizedBox(height: 22),
              _buildSectionLabel(
                tr('KAILAN SIYA IPINANGANAK?', 'WHEN WERE THEY BORN?'),
              ),
              const SizedBox(height: 10),
              _buildBirthdayField(),
              const SizedBox(height: 22),
              _buildSectionLabel(tr('KASARIAN', 'SEX')),
              const SizedBox(height: 10),
              Row(
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
              const SizedBox(height: 8),
              _buildHint(
                tr(
                  'Opsyonal ito. Pindutin muli ang napili para alisin.',
                  'This is optional. Tap the chosen one again to clear it.',
                ),
              ),
              const SizedBox(height: 22),
              _buildFocusSection(),
              const SizedBox(height: 24),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto() {
    final fileName = _photoFileName;

    return GestureDetector(
      onTap: _changePhoto,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 92,
                height: 92,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.tintTeal,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.skyBlue, width: 3),
                ),
                child: fileName == null
                    ? const Icon(
                        Icons.child_care_rounded,
                        size: 42,
                        color: AppColors.skyInk,
                      )
                    : Image.file(
                        ChildPhotoService.fileFor(fileName),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.child_care_rounded,
                          size: 42,
                          color: AppColors.skyInk,
                        ),
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.logoGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  size: 15,
                  color: AppColors.surface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            fileName == null
                ? tr('Magdagdag ng litrato', 'Add a photo')
                : tr('Palitan ang litrato', 'Change the photo'),
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: AppColors.logoGreen,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 3),
          Text(
            tr(
              'Nasa telepono lang ito. Hindi ito umaalis ng app.',
              'It stays on this phone. It never leaves the app.',
            ),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthdayField() {
    final birthDate = _birthDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickDate,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _showBirthError
                    ? AppColors.danger
                    : birthDate == null
                    ? AppColors.divider
                    : AppColors.logoGreen,
                width: _showBirthError || birthDate != null ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.cake_rounded,
                  size: 20,
                  color: AppColors.logoGreen,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    birthDate == null
                        ? tr('Pumili ng kaarawan', 'Choose a birthday')
                        : DateFormatter.longDate(birthDate),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      color: birthDate == null
                          ? AppColors.textMuted
                          : AppColors.textDark,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
        if (_showBirthError) ...[
          const SizedBox(height: 6),
          Text(
            tr('Kailangan ang kaarawan.', 'The birthday is needed.'),
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.danger,
              fontFamily: 'Nunito',
            ),
          ),
        ],
        if (birthDate != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 15,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AgeFormatter.formatAge(birthDate, DateTime.now()),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        _buildHint(
          tr(
            'Dito nakabatay ang mga milestone na ipapakita at ang edad na '
                'makikita mo sa buong app.',
            'The milestones you are shown and the age across the app both come '
                'from this.',
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isSaving ? null : _cancel,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              tr('Kanselahin', 'Cancel'),
              style: const TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: _isSaving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.logoGreen,
              disabledBackgroundColor: AppColors.divider,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            child: Text(
              _isEditing ? tr('I-save', 'Save') : tr('Idagdag', 'Add'),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.6,
        fontFamily: 'Nunito',
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _buildHint(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11.5,
        height: 1.4,
        color: AppColors.textMuted,
        fontFamily: 'Nunito',
      ),
    );
  }

  Widget _buildFocusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(tr('POKUS NG SUPORTA', 'SUPPORT FOCUS')),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final focus in SupportFocus.values) _buildFocusChip(focus),
          ],
        ),
        const SizedBox(height: 12),
        _buildHint(
          tr(
            'Opsyonal ito at hindi ito diagnosis. Ang ginagawa lang nito ay '
                'iuna ang bahagi ng Gabay sa Pag-unawa, ng Laro, at ng mga '
                'mungkahi sa Iskedyul na bagay sa anak mo. Nakikita mo pa rin '
                'ang lahat.',
            'This is optional and it is not a diagnosis. All it does is bring '
                'the parts of the Understanding Guide, Play, and the schedule '
                'suggestions that suit your child to the front. You still see '
                'everything.',
          ),
        ),
      ],
    );
  }

  Widget _buildFocusChip(SupportFocus focus) {
    final isSelected = _focus.contains(focus);

    return Semantics(
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: () => setState(() {
          isSelected ? _focus.remove(focus) : _focus.add(focus);
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.logoGreen : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(
              color: isSelected ? AppColors.logoGreen : AppColors.divider,
              width: 2,
            ),
          ),
          child: Text(
            focus.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.surface : AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(Gender gender, IconData icon, Color color) {
    final isSelected = _gender == gender;

    return GestureDetector(
      // Muling pagpindot ay nagbubura, dahil opsyonal ang kasarian.
      onTap: () => setState(() => _gender = isSelected ? null : gender),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 30,
              color: isSelected ? color : AppColors.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              gender.label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
                color: isSelected ? AppColors.textDark : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
