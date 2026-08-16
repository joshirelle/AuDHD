import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../profile/child_editor_dialog.dart';
import '../../../widgets/screening_attribution.dart';
import '../../../widgets/screening_disclaimer.dart';
import 'mchat_age_check_screen.dart';
import 'screening_history_screen.dart';
import 'adhd_screening_screen.dart';

class ScreeningHomeScreen extends StatelessWidget {
  const ScreeningHomeScreen({super.key});

  /// Walang mailalagay na pangalan o edad sa ulat kung walang naitalang bata, kaya rito huminto.
  Future<bool> _ensureChildProfile(BuildContext context) async {
    if (HiveService.getChildProfile() != null) return true;

    final added = await showDialog<bool>(
      context: context,
      builder: (context) => const ChildEditorDialog(),
    );
    return added == true;
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
      // ListView, hindi Column: hindi kasya ang disclaimer at atribusyon
      // kasama ang tatlong card sa maiikling screen.
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const ScreeningDisclaimer(),
          const SizedBox(height: 20),
            // 1. M-CHAT-R Screening Card (dadaan muna sa Age Check)
            _buildOptionCard(
              context,
              title: 'M-CHAT-R Autism Screening',
              subtitle: 'Para sa mga batang 16–30 buwang gulang',
              icon: Icons.child_care_rounded,
              color: AppColors.logoGreen,
              onTap: () async {
                if (!await _ensureChildProfile(context)) return;
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
              color: AppColors.vanderbiltBlue,
              onTap: () async {
                if (!await _ensureChildProfile(context)) return;
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
              color: AppColors.historyPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScreeningHistoryScreen(),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          const ScreeningCopyright(),
        ],
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