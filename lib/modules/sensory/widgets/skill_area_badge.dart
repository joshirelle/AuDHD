import 'package:flutter/material.dart';

import '../../../core/enums/skill_area.dart';
import '../../../core/theme/app_theme.dart';

class SkillAreaBadge extends StatelessWidget {
  const SkillAreaBadge(this.area, {super.key});

  final SkillArea area;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: area.ink,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(area.icon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            area.label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}
