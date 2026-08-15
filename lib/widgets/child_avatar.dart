import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Iisang mukha ng bata sa home header at sa profile screen.
class ChildAvatar extends StatelessWidget {
  final double size;

  const ChildAvatar({super.key, this.size = 42});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.skyBlueLight,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/kiko_waving.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.child_care_rounded,
            size: size * 0.6,
            color: AppColors.logoGreen,
          ),
        ),
      ),
    );
  }
}
