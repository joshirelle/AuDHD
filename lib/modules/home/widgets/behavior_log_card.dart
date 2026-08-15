import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/kiko_card.dart';
import '../../behavior/screens/behavior_history_screen.dart';

class BehaviorLogCard extends StatelessWidget {
  const BehaviorLogCard({super.key});

  @override
  Widget build(BuildContext context) {
    return KikoCard(
      backgroundColor: const Color(0xFFFFF7ED), // Soft pastel orange/amber
      borderColor: Colors.orange.shade200,
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BehaviorHistoryScreen(),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.assignment_outlined,
              color: Colors.orange.shade800,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tala ng Ugali (ABC Log)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Mag-tala ng Antecedent, Behavior, at Consequence para sa OT/ABA.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.orange.shade800,
          ),
        ],
      ),
    );
  }
}
