import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/child_profile.dart';
import '../../data/services/hive_service.dart';
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
    _load();
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
          'Buburahin si ${child.name}. Mananatili ang mga naitalang screening result, '
          'ngunit mawawala ang pangalan at edad sa mga PDF report.',
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
        actions: [
          IconButton(
            tooltip: 'Seguridad',
            icon: const Icon(Icons.lock_outline_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SecurityScreen(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: child == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
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
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: AppColors.mintGreen,
                        child: const Icon(Icons.child_care_rounded, size: 38, color: AppColors.logoGreen),
                      ),
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
                      _infoRow('Edad ngayon', _ageLabel(child.ageInMonthsOn(DateTime.now()))),
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
            ),
    );
  }

  static String _ageLabel(int months) {
    final years = months ~/ 12;
    final remainder = months % 12;
    final parts = <String>[];
    if (years > 0) parts.add('$years taon');
    if (remainder > 0) parts.add('$remainder buwan');
    if (parts.isEmpty) return 'Wala pang isang buwan';
    return '${parts.join(', ')} ($months buwan)';
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

