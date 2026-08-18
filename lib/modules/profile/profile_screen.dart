import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/child_photo_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/age_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/child_profile.dart';
import '../../data/services/hive_service.dart';
import '../../widgets/child_avatar.dart';
import '../../widgets/community_link.dart';
import '../../widgets/kiko_card.dart';
import '../home/widgets/whats_new_sheet.dart';
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
        title: const Text('Burahin ang profile?'),
        content: Text(
          'Mababura ang pangalan at kaarawan ni ${child.name}.\n\n'
          'Ang mga naitalang behavior log, sensory history, '
          'milestones, at mood ay MANANATILI sa device. Mawawala lang ang '
          'pangalan at edad sa mga PDF report.'
          // Huling pagkakataon niyang malaman ito bago mawala ang litrato.
          '${BackupService.hasBackup ? '' : '\n\nWala ka pang kopya ng datos. '
              'Hindi na maibabalik ang pangalan, kaarawan, at litrato kapag '
              'nabura na ang mga ito.'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kanselahin'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Burahin',
              style: TextStyle(
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
          const SnackBar(
            content: Text(
              'Hindi mabuksan ang litrato. Tingnan ang pahintulot ng app.',
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
              title: const Text('Kumuha ng litrato'),
              onTap: () => Navigator.pop(context, _PhotoAction.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: AppColors.logoGreen,
              ),
              title: const Text('Pumili sa gallery'),
              onTap: () => Navigator.pop(context, _PhotoAction.gallery),
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                ),
                title: const Text('Alisin ang litrato'),
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
        title: const Text('Profile ng Bata'),
        backgroundColor: Colors.white,
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
          const CommunityCard(),
          const SizedBox(height: 20),
          _buildWhatsNewCard(),
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
          Icon(Icons.child_care_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Wala pang naitalang bata.',
            style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Ang pangalan at kaarawan ay lalabas sa PDF report, at gagamitin sa pagkwenta ng edad.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.logoGreen,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () => _openEditor(),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Itala ang Bata',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          backgroundColor: Colors.white,
          borderColor: AppColors.logoGreen,
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
              _infoRow('Pangalan', child.name),
              const SizedBox(height: 8),
              _infoRow('Palayaw', child.nickname ?? '—'),
              const SizedBox(height: 8),
              _infoRow('Kaarawan', DateFormatter.longDate(child.birthDate)),
              const SizedBox(height: 8),
              _infoRow(
                'Edad',
                AgeFormatter.formatMonths(child.ageInMonthsOn(DateTime.now())),
              ),
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
          label: const Text(
            'Baguhin ang Detalye',
            style: TextStyle(color: AppColors.logoGreen, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableAvatar(ChildProfile child) {
    return Semantics(
      button: true,
      label: 'Palitan ang litrato ni ${child.name}',
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
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  size: 13,
                  color: Colors.white,
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
        child: const Text(
          'Burahin ang profile ng bata',
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Nunito',
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsNewCard() {
    return KikoCard(
      backgroundColor: AppColors.tintSuccess,
      padding: const EdgeInsets.all(18),
      onTap: () => WhatsNewSheet.show(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.logoGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Ano ang bago sa AuDHD',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontFamily: 'Nunito',
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textDark),
        ],
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
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.security_rounded,
              color: AppColors.accentBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PIN at Fingerprint',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Protektahan ang datos ng bata gamit ang 4-digit PIN o fingerprint.',
                  style: TextStyle(
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

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
