import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/i18n/language_controller.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/child_photo_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/age_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/child_profile.dart';
import '../../data/services/hive_service.dart';
import '../../widgets/child_avatar.dart';
import '../../widgets/kiko_card.dart';
import '../auth/screens/security_screen.dart';
import 'child_editor_dialog.dart';
import 'widgets/backup_card.dart';
import 'widgets/developer_feedback_card.dart';

enum _PhotoAction { camera, gallery, remove }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ChildProfile? _child;

  @override
  void initState() {
    super.initState();
    _child = HiveService.getChildProfile();
  }

  void _load() {
    setState(() => _child = HiveService.getChildProfile());
  }

  Future<void> _confirmDelete(ChildProfile child) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr('Burahin ang profile?', 'Delete profile?')),
        content: Text(
          tr(
            'Mababura ang pangalan at kaarawan ni ${child.name}.\n\n'
            'Ang mga naitalang behavior log, sensory history, '
            'milestones, at mood ay MANANATILI sa device. Mawawala lang ang '
            'pangalan at edad sa mga PDF report.'
            // Huling pagkakataon niyang malaman ito bago mawala ang litrato.
            '${BackupService.hasBackup ? '' : '\n\nWala ka pang kopya ng datos. '
                'Hindi na maibabalik ang pangalan, kaarawan, at litrato kapag '
                'nabura na ang mga ito.'}',
            'The name and birthday of ${child.name} will be deleted.\n\n'
            'The behavior logs, sensory history, milestones, and mood you '
            'recorded will STAY on the device. Only the name and age will be '
            'gone from the PDF reports.'
            '${BackupService.hasBackup ? '' : '\n\nYou do not have a backup of '
                'your data yet. The name, birthday, and photo can no longer be '
                'brought back once they are deleted.'}',
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
              tr('Burahin', 'Delete'),
              style: const TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      // Kung hindi ito buburahin, mananatili sa device ang litrato ng bata.
      await ChildPhotoService.delete(child.photoFileName);
      await HiveService.deleteChildProfile();
      _load();
    }
  }

  Future<void> _changePhoto(ChildProfile child) async {
    final action = await _askPhotoAction(child.photoFileName != null);
    if (action == null) return;

    String? fileName;
    if (action != _PhotoAction.remove) {
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
      if (fileName == null) return;
    }

    await ChildPhotoService.delete(child.photoFileName);
    await HiveService.saveChildProfile(
      ChildProfile(
        name: child.name,
        birthDate: child.birthDate,
        gender: child.gender,
        nickname: child.nickname,
        photoFileName: fileName,
      ),
    );
    if (mounted) _load();
  }

  Future<_PhotoAction?> _askPhotoAction(bool hasPhoto) {
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
            ListTile(
              leading: const Icon(
                Icons.photo_camera_rounded,
                color: AppColors.logoGreen,
              ),
              title: Text(tr('Kumuha ng litrato', 'Take a photo')),
              onTap: () => Navigator.pop(context, _PhotoAction.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: AppColors.logoGreen,
              ),
              title: Text(tr('Pumili sa gallery', 'Choose from gallery')),
              onTap: () => Navigator.pop(context, _PhotoAction.gallery),
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                ),
                title: Text(tr('Alisin ang litrato', 'Remove photo')),
                onTap: () => Navigator.pop(context, _PhotoAction.remove),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditor({ChildProfile? existing}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => ChildEditorDialog(existing: existing),
    );
    if (saved == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final child = _child;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Profile ng Bata', 'Child Profile')),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (child == null) _buildEmptyState() else _buildProfileSection(child),
          const SizedBox(height: 28),
          _buildSecurityCard(),
          const SizedBox(height: 20),
          BackupCard(onRestored: _load),
          const SizedBox(height: 20),
          const DeveloperFeedbackCard(),
          // Malayo sa "Baguhin ang Detalye" para hindi mapindot nang pagkakamali.
          if (child != null) ...[
            const SizedBox(height: 36),
            _buildDeleteLink(child),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Column(
        children: [
          Icon(Icons.child_care_rounded, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            tr('Wala pang naitalang bata.', 'No child added yet.'),
            style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            tr(
              'Ang pangalan at kaarawan ay lalabas sa PDF report, at gagamitin sa pagkwenta ng edad.',
              'The name and birthday will show up in the PDF report, and will be used to work out the age.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.3),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.logoGreen,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () => _openEditor(),
            icon: const Icon(Icons.add_rounded, color: AppColors.surface),
            label: Text(
              tr('Itala ang Bata', 'Add Your Child'),
              style: const TextStyle(color: AppColors.surface, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(ChildProfile child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KikoCard(
          backgroundColor: AppColors.tintSuccess,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildEditableAvatar(child),
              const SizedBox(height: 14),
              Text(
                child.displayName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              if (child.gender != null) ...[
                const SizedBox(height: 8),
                _buildGenderBadge(child.gender!),
              ],
              const SizedBox(height: 16),
              _infoRow(tr('Pangalan', 'Name'), child.name),
              const SizedBox(height: 8),
              _infoRow(tr('Palayaw', 'Nickname'), child.nickname ?? '—'),
              const SizedBox(height: 8),
              _infoRow(
                tr('Kaarawan', 'Birthday'),
                DateFormatter.longDate(child.birthDate),
              ),
              const SizedBox(height: 8),
              _infoRow(
                tr('Edad', 'Age'),
                AgeFormatter.formatMonths(child.ageInMonthsOn(DateTime.now())),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 12),
              _buildLanguageRow(),
            ],
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            side: const BorderSide(color: AppColors.logoGreen),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () => _openEditor(existing: child),
          icon: const Icon(Icons.edit_rounded, color: AppColors.logoGreen),
          label: Text(
            tr('Baguhin ang Detalye', 'Edit Details'),
            style: const TextStyle(color: AppColors.logoGreen, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableAvatar(ChildProfile child) {
    return Semantics(
      button: true,
      label: tr(
        'Palitan ang litrato ni ${child.name}',
        'Change the photo of ${child.name}',
      ),
      child: GestureDetector(
        onTap: () => _changePhoto(child),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const ChildAvatar(size: 68),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.logoGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  size: 13,
                  color: AppColors.surface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteLink(ChildProfile child) {
    return Center(
      child: TextButton(
        onPressed: () => _confirmDelete(child),
        style: TextButton.styleFrom(foregroundColor: AppColors.danger),
        child: Text(
          tr('Burahin ang profile ng bata', 'Delete the child profile'),
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Nunito',
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityCard() {
    return KikoCard(
      backgroundColor: AppColors.skyBlueLight,
      padding: const EdgeInsets.all(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SecurityScreen()),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.security_rounded,
              color: AppColors.accentBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('PIN at Fingerprint', 'PIN and Fingerprint'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr(
                    'Protektahan ang datos ng bata gamit ang 4-digit PIN o fingerprint.',
                    'Protect your child\'s data with a 4-digit PIN or fingerprint.',
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textDark,
                    height: 1.3,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textDark),
        ],
      ),
    );
  }

  Widget _buildGenderBadge(Gender gender) {
    final isMale = gender == Gender.male;
    final color = isMale ? AppColors.genderBlue : AppColors.genderPink;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMale ? Icons.male_rounded : Icons.female_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            gender.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          tr('Wika', 'Language'),
          style: const TextStyle(fontSize: 13, color: AppColors.textDark),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final lang in AppLanguage.values) ...[
              if (lang != AppLanguage.values.first) const SizedBox(width: 8),
              _languageChip(lang),
            ],
          ],
        ),
      ],
    );
  }

  Widget _languageChip(AppLanguage lang) {
    final isActive = LanguageController.current == lang;
    final label = lang == AppLanguage.filipino ? 'Filipino' : 'English';

    return Semantics(
      selected: isActive,
      button: true,
      child: GestureDetector(
        onTap: () async {
          await LanguageController.set(lang);
          if (mounted) setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.logoGreen : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.surface : AppColors.textMuted,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textDark),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
