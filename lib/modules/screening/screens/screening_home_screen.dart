import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../profile/child_editor_dialog.dart';
import 'mchat_age_check_screen.dart';
import 'screening_history_screen.dart';
import 'adhd_screening_screen.dart';

class ScreeningHomeScreen extends StatelessWidget {
  const ScreeningHomeScreen({super.key});

  /// Walang paraan para iugnay ang resulta sa isang bata kung walang aktibo, kaya rito huminto.
  Future<bool> _ensureActiveChild(BuildContext context) async {
    if (HiveService.getActiveChild() != null) return true;

    final children = HiveService.getAllChildProfiles();
    if (children.isEmpty) {
      final added = await showDialog<bool>(
        context: context,
        builder: (context) => const ChildEditorDialog(),
      );
      return added == true;
    }

    final chosenId = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sino ang susuriin?'),
        children: [
          for (final child in children)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, child.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  child.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );

    if (chosenId == null) return false;
    await HiveService.setActiveChildId(chosenId);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mga Pagsusuri'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. M-CHAT-R Screening Card (dadaan muna sa Age Check)
            _buildOptionCard(
              context,
              title: 'M-CHAT-R Autism Screening',
              subtitle: 'Para sa mga batang 16–30 buwang gulang',
              icon: Icons.child_care_rounded,
              color: AppColors.logoGreen,
              onTap: () async {
                if (!await _ensureActiveChild(context)) return;
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MChatAgeCheckScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // 2. Vanderbilt ADHD Screening Card
            _buildOptionCard(
              context,
              title: 'Vanderbilt ADHD Screening',
              subtitle: 'Para sa mga batang 4 na taon pataas',
              icon: Icons.psychology_rounded,
              color: const Color(0xFF3B82F6),
              onTap: () async {
                if (!await _ensureActiveChild(context)) return;
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ADHDScreeningScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // 3. Screening History Card
            _buildOptionCard(
              context,
              title: 'Tala ng mga Nakaraang Test',
              subtitle: 'Tingnan ang nakalipas na M-CHAT scores sa Hive',
              icon: Icons.history_rounded,
              color: const Color(0xFF8B5CF6),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScreeningHistoryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}