import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/kiko_card.dart';
import '../../schedule/screens/visual_schedule_screen.dart';

class VisualScheduleCard extends StatelessWidget {
  const VisualScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<int>>(
      // Kailangan ng listener para sumabay ang bilang pagbalik mula sa iskedyul.
      valueListenable: HiveService.getScheduleDoneBox().listenable(),
      builder: (context, box, _) => _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final today = DateTime.now();
    final tasks = HiveService.getScheduleTasks();
    final doneCount = HiveService.countScheduleDoneOn(
      today,
      tasks.map((task) => task.id).toList(),
    );

    return KikoCard(
      backgroundColor: AppColors.tintGold,
      borderColor: AppColors.starGold.withValues(alpha: 0.35),
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const VisualScheduleScreen()),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.starGold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.route_rounded,
              color: AppColors.starGold,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aking Iskedyul',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$doneCount sa ${tasks.length} na gawain ang tapos ngayong araw.',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.starGold),
        ],
      ),
    );
  }
}
