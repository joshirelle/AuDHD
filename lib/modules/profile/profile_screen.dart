import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/age_formatter.dart';
import '../../data/models/child_profile.dart';
import '../../data/services/hive_service.dart';
import '../../widgets/child_avatar.dart';
import '../../widgets/kiko_card.dart';
import '../auth/screens/security_screen.dart';
import 'child_editor_dialog.dart';

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
          'Ang mga naitalang screening, behavior log, sensory history, '
          'milestones, at mood ay MANANATILI sa device. Mawawala lang ang '
          'pangalan at edad sa mga PDF report.',
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
              style: TextStyle(color: Color(0xFFD9383A), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      await HiveService.deleteChildProfile();
      _load();
    }
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
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.logoGreen, width: 2),
          ),
          child: Column(
            children: [
              const ChildAvatar(size: 68),
              const SizedBox(height: 14),
              Text(
                child.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 16),
              _infoRow(
                'Kaarawan',
                '${child.birthDate.day}/${child.birthDate.month}/${child.birthDate.year}',
              ),
              const SizedBox(height: 8),
              _infoRow(
                'Edad ngayon',
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
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () => _confirmDelete(child),
          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFD9383A)),
          label: const Text(
            'Burahin ang Profile',
            style: TextStyle(color: Color(0xFFD9383A), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityCard() {
    return KikoCard(
      backgroundColor: AppColors.skyBlueLight,
      padding: const EdgeInsets.all(16),
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
              color: Color(0xFF2A80B9),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PIN at Biometric Lock',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Protektahan ang datos ng bata gamit ang 4-digit PIN o Face ID / Fingerprint.',
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
