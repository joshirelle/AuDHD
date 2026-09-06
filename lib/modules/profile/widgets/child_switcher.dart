import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/child_profile.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/child_avatar.dart';

/// Pahalang na hanay ng mga bata, may guhit sa aktibo.
///
/// Pahalang at hindi nakapirming hanay dahil walang limitasyon sa bilang ng
/// maidadagdag ng magulang.
class ChildSwitcher extends StatelessWidget {
  /// Nagtatago kapag iisa lang ang bata. Para sa Home: ang switcher na walang
  /// mapipilian ay pindutang walang silbi.
  final bool hideWhenAlone;

  /// Wala nito sa Home — doon ay paglipat lang, hindi pamamahala.
  final VoidCallback? onAdd;

  /// Tinatawag pagkatapos lumipat, para makapag-reload ang screen.
  final VoidCallback? onSwitched;

  const ChildSwitcher({
    super.key,
    this.hideWhenAlone = false,
    this.onAdd,
    this.onSwitched,
  });

  static const double _itemWidth = 76;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: HiveService.getProfilesBox().listenable(),
      builder: (context, box, _) {
        final children = HiveService.getChildProfiles();
        if (hideWhenAlone && children.length < 2) {
          return const SizedBox.shrink();
        }

        final activeId = HiveService.getActiveChild()?.id;

        return SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            children: [
              for (final child in children)
                _buildChild(child, child.id == activeId),
              if (onAdd != null) _buildAdd(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChild(ChildProfile child, bool isActive) {
    return Semantics(
      selected: isActive,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isActive
            ? null
            : () async {
                await HiveService.setActiveChild(child.id);
                onSwitched?.call();
              },
        child: SizedBox(
          width: _itemWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              ChildAvatar(size: 46, child: child),
              const SizedBox(height: 6),
              Text(
                child.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? AppColors.textDark : AppColors.textMuted,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 5),
              Container(
                height: 3,
                width: 26,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.logoGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdd() {
    return Semantics(
      button: true,
      label: tr('Magdagdag ng bata', 'Add a child'),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onAdd,
        child: SizedBox(
          width: _itemWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                  border: Border.all(color: AppColors.divider, width: 2),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 22,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                tr('Bata', 'Child'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
