import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/services/child_photo_service.dart';
import '../core/theme/app_theme.dart';
import '../data/services/hive_service.dart';

/// Iisang mukha ng bata sa home header at sa profile screen.
class ChildAvatar extends StatelessWidget {
  final double size;

  const ChildAvatar({super.key, this.size = 42});

  /// Nakabatay sa pangalan, hindi random, para hindi magbago ang kulay tuwing
  /// bubuksan ang app. Lahat ng pares ay pasado sa 4.5:1.
  static const List<_AvatarTone> _tones = [
    _AvatarTone(AppColors.mintGreen, AppColors.mintInk),
    _AvatarTone(AppColors.skyBlue, AppColors.skyInk),
    _AvatarTone(AppColors.butterYellow, AppColors.butterInk),
    _AvatarTone(AppColors.coralPeach, AppColors.coralInk),
    _AvatarTone(AppColors.lavender, AppColors.textDark),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      // Kung hindi ito nakikinig, luma ang mukha pagkatapos magpalit ng litrato.
      valueListenable: HiveService.getProfileBox().listenable(),
      builder: (context, box, _) {
        final profile = HiveService.getChildProfile();
        final initial = _initialOf(profile?.displayName);
        final tone = _toneFor(initial);

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tone.background,
            border: Border.all(color: AppColors.surface, width: 2),
          ),
          child: ClipOval(
            child: _buildImage(profile?.photoFileName, initial, tone),
          ),
        );
      },
    );
  }

  Widget _buildImage(String? photoFileName, String? initial, _AvatarTone tone) {
    if (photoFileName == null) return _buildInitial(initial, tone);

    return Image.file(
      ChildPhotoService.fileFor(photoFileName),
      fit: BoxFit.cover,
      width: size,
      height: size,
      // Nabura na ang file pero nasa Hive pa ang pangalan.
      errorBuilder: (context, error, stackTrace) =>
          _buildInitial(initial, tone),
    );
  }

  Widget _buildInitial(String? initial, _AvatarTone tone) {
    if (initial == null) {
      return Icon(Icons.person_rounded, size: size * 0.55, color: tone.ink);
    }

    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.44,
          fontWeight: FontWeight.bold,
          color: tone.ink,
          fontFamily: 'Nunito',
          height: 1,
        ),
      ),
    );
  }

  static String? _initialOf(String? name) {
    final trimmed = name?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed[0].toUpperCase();
  }

  static _AvatarTone _toneFor(String? initial) {
    if (initial == null) return _tones.first;
    return _tones[initial.codeUnitAt(0) % _tones.length];
  }
}

class _AvatarTone {
  const _AvatarTone(this.background, this.ink);

  final Color background;
  final Color ink;
}
