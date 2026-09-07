import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';

/// Pangkat ng larawan ng pabuya. Kulay kada pangkat, hindi kada larawan.
enum RewardIconGroup {
  treats(AppColors.butterInk),
  outings(AppColors.mintInk),
  screen(AppColors.skyInk),
  play(AppColors.coralInk),
  together(AppColors.autismPurple);

  const RewardIconGroup(this.ink);

  final Color ink;

  String get label => switch (this) {
    RewardIconGroup.treats => tr('Pagkain', 'Treats'),
    RewardIconGroup.outings => tr('Labas', 'Going Out'),
    RewardIconGroup.screen => tr('Panonood', 'Screen Time'),
    RewardIconGroup.play => tr('Laruan at Laro', 'Toys and Games'),
    RewardIconGroup.together => tr('Magkasama', 'Together'),
  };
}

/// Nakatalang `const IconData` na naka-index sa pangalan.
///
/// Susi ang iniimbak sa Hive, hindi `codePoint`: inaalis ng
/// `--tree-shake-icons` sa release build ang icon na walang const na
/// sanggunian, kaya mababakante ang icon na binuo mula sa naka-save na numero.
class RewardIcons {
  const RewardIcons._();

  /// Ang lumang pabuyang walang napiling larawan. Bituin ito — iyon din ang
  /// ipinapanalo ng bata.
  static const IconData fallback = Icons.star_rounded;

  static const Map<String, IconData> all = {
    'icecream': Icons.icecream_rounded,
    'cake': Icons.cake_rounded,
    'candy': Icons.cookie_rounded,
    'drink': Icons.local_drink_rounded,
    'fastfood': Icons.fastfood_rounded,
    'park': Icons.park_rounded,
    'beach': Icons.beach_access_rounded,
    'store': Icons.storefront_rounded,
    'ride': Icons.directions_bus_rounded,
    'swim': Icons.pool_rounded,
    'tv': Icons.tv_rounded,
    'tablet': Icons.tablet_android_rounded,
    'music': Icons.music_note_rounded,
    'photo': Icons.photo_camera_rounded,
    'toy': Icons.smart_toy_rounded,
    'ball': Icons.sports_soccer_rounded,
    'game': Icons.sports_esports_rounded,
    'blocks': Icons.extension_rounded,
    'bike': Icons.pedal_bike_rounded,
    'draw': Icons.palette_rounded,
    'book': Icons.menu_book_rounded,
    'hug': Icons.favorite_rounded,
    'friends': Icons.groups_rounded,
    'sticker': Icons.auto_awesome_rounded,
  };

  /// Bawat susi sa `all` ay minsan lang dapat lumitaw dito — may test.
  static const Map<RewardIconGroup, List<String>> grouped = {
    RewardIconGroup.treats: ['icecream', 'cake', 'candy', 'drink', 'fastfood'],
    RewardIconGroup.outings: ['park', 'beach', 'store', 'ride', 'swim'],
    RewardIconGroup.screen: ['tv', 'tablet', 'music', 'photo'],
    RewardIconGroup.play: ['toy', 'ball', 'game', 'blocks', 'bike', 'draw'],
    RewardIconGroup.together: ['book', 'hug', 'friends', 'sticker'],
  };

  static IconData of(String? key) => all[key] ?? fallback;

  /// `starGold` kapag walang pangkat: iyon ang kulay ng `fallback`.
  static Color inkOf(String? key) {
    for (final entry in grouped.entries) {
      if (entry.value.contains(key)) return entry.key.ink;
    }
    return AppColors.starGold;
  }
}
