import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/services/child_photo_service.dart';
import '../core/theme/app_theme.dart';
import '../data/services/hive_service.dart';

/// Iisang mukha ng bata sa home header at sa profile screen.
class ChildAvatar extends StatelessWidget {
  final double size;

  const ChildAvatar({super.key, this.size = 42});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      // Kung hindi ito nakikinig, luma ang mukha pagkatapos magpalit ng litrato.
      valueListenable: HiveService.getProfileBox().listenable(),
      builder: (context, box, _) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.skyBlueLight,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: ClipOval(
            child: _buildImage(HiveService.getChildProfile()?.photoFileName),
          ),
        );
      },
    );
  }

  Widget _buildImage(String? photoFileName) {
    if (photoFileName == null) return _buildMascot();

    return Image.file(
      ChildPhotoService.fileFor(photoFileName),
      fit: BoxFit.cover,
      width: size,
      height: size,
      // Nabura na ang file pero nasa Hive pa ang pangalan.
      errorBuilder: (context, error, stackTrace) => _buildMascot(),
    );
  }

  Widget _buildMascot() {
    return Image.asset(
      'assets/images/kiko_waving.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.child_care_rounded,
        size: size * 0.6,
        color: AppColors.logoGreen,
      ),
    );
  }
}
