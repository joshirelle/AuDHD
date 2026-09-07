import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/services/star_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import 'reward_icons.dart';

/// Isang handang pabuya. Pinipili lang, hindi ipinipilit.
class _Suggestion {
  const _Suggestion(this.fil, this.eng, this.iconKey, this.stars);

  final String fil;
  final String eng;
  final String iconKey;
  final int stars;

  String get label => tr(fil, eng);
}

/// Nagbabalik ng bagong pabuya, o `null` kapag kinansela.
class AddRewardDialog extends StatefulWidget {
  const AddRewardDialog({super.key});

  static Future<({String label, int stars, String? iconKey})?> show(
    BuildContext context,
  ) {
    // Bottom sheet at hindi `AlertDialog`: hindi nagsi-scroll ang `content`
    // ng dialog, at umaapaw ito kapag umangat ang keyboard.
    return showModalBottomSheet<({String label, int stars, String? iconKey})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddRewardDialog(),
    );
  }

  @override
  State<AddRewardDialog> createState() => _AddRewardDialogState();
}

class _AddRewardDialogState extends State<AddRewardDialog> {
  /// Mga karaniwan sa bahay na Pilipino. Walang naidadagdag nang kusa \u2014 ang
  /// magulang ang nakakaalam kung ano ang tunay na pabuya sa kanila.
  static const List<_Suggestion> _suggestions = [
    _Suggestion('Sorbetes', 'Ice cream', 'icecream', 10),
    _Suggestion('Paboritong meryenda', 'Favourite snack', 'candy', 5),
    _Suggestion('Panonood ng palabas', 'Watch a show', 'tv', 10),
    _Suggestion('Dagdag na oras sa tablet', 'Extra tablet time', 'tablet', 15),
    _Suggestion('Punta sa parke', 'A trip to the park', 'park', 20),
    _Suggestion('Paglangoy', 'Go swimming', 'swim', 30),
    _Suggestion('Bagong laruan', 'A new toy', 'toy', 50),
    _Suggestion('Bagong libro', 'A new book', 'book', 30),
    _Suggestion('Pagbisita sa kaibigan', 'Visit a friend', 'friends', 20),
    _Suggestion('Sticker', 'A sticker', 'sticker', 5),
    _Suggestion('Maglaro ng bola sa labas', 'Play ball outside', 'ball', 10),
    _Suggestion('Espesyal na yakap at kuwento', 'A hug and a story', 'hug', 5),
  ];

  static const List<int> _starLevels = [5, 10, 15, 20, 30, 50];

  final TextEditingController _labelController = TextEditingController();
  String? _iconKey;
  int _stars = 10;
  bool _showLabelError = false;
  bool _showingSuggestions = true;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _takeSuggestion(_Suggestion suggestion) {
    setState(() {
      _labelController.text = suggestion.label;
      _iconKey = suggestion.iconKey;
      _stars = suggestion.stars;
      _showLabelError = false;
      _showingSuggestions = false;
    });
  }

  void _save() {
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      setState(() {
        _showLabelError = true;
        _showingSuggestions = false;
      });
      return;
    }

    Navigator.pop(context, (label: label, stars: _stars, iconKey: _iconKey));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  tr('Bagong Pabuya', 'New Reward'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _buildModeTabs(),
              const SizedBox(height: 16),
              if (_showingSuggestions)
                _buildSuggestions()
              else ...[
                _buildPreview(),
                const SizedBox(height: 20),
                _buildSectionLabel(
                  tr('ANO ANG PABUYA?', 'WHAT IS THE REWARD?'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _labelController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 60,
                  onChanged: (_) => setState(() => _showLabelError = false),
                  decoration: InputDecoration(
                    hintText: tr(
                      'Halimbawa: Manood ng paboritong palabas',
                      'Example: Watch a favourite show',
                    ),
                    counterText: '',
                    errorText: _showLabelError
                        ? tr(
                            'Kailangan ang pangalan ng pabuya.',
                            'Please enter a reward name.',
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionLabel(tr('PUMILI NG LARAWAN', 'PICK A PICTURE')),
                const SizedBox(height: 4),
                _buildHint(
                  tr(
                    'Ito ang makikita ng anak mo. Marami sa mga batang ito ang '
                        'hindi pa nakakabasa.',
                    'This is what your child sees. Many of these children '
                        'cannot read yet.',
                  ),
                ),
                const SizedBox(height: 12),
                _buildIconPicker(),
                const SizedBox(height: 20),
                _buildSectionLabel(tr('ILANG BITUIN?', 'HOW MANY STARS?')),
                const SizedBox(height: 10),
                _buildStarPicker(),
                const SizedBox(height: 24),
                _buildActions(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeTabs() {
    return Row(
      children: [
        _buildModeTab(
          label: tr('Mungkahi', 'Suggestions'),
          icon: Icons.lightbulb_outline_rounded,
          isActive: _showingSuggestions,
          onTap: () => setState(() => _showingSuggestions = true),
        ),
        const SizedBox(width: 10),
        _buildModeTab(
          label: tr('Sarili kong pabuya', 'My own reward'),
          icon: Icons.edit_rounded,
          isActive: !_showingSuggestions,
          onTap: () => setState(() => _showingSuggestions = false),
        ),
      ],
    );
  }

  Widget _buildModeTab({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isActive ? AppColors.logoGreen : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(
              color: isActive ? AppColors.logoGreen : AppColors.divider,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? AppColors.surface : AppColors.textMuted,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                    color: isActive ? AppColors.surface : AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHint(
          tr(
            'Pindutin ang isa para punan ang form, saka mo puwedeng baguhin.',
            'Tap one to fill in the form, then change whatever you like.',
          ),
        ),
        const SizedBox(height: 12),
        for (final suggestion in _suggestions) ...[
          _buildSuggestionRow(suggestion),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildSuggestionRow(_Suggestion suggestion) {
    return GestureDetector(
      onTap: () => _takeSuggestion(suggestion),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                RewardIcons.of(suggestion.iconKey),
                size: 21,
                color: RewardIcons.inkOf(suggestion.iconKey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion.label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildStarBadge(suggestion.stars),
          ],
        ),
      ),
    );
  }

  Widget _buildStarBadge(int stars) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.tintGold,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: AppColors.starGold),
          const SizedBox(width: 4),
          Text(
            '$stars',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  /// Ito mismo ang hitsura ng pabuya sa listahang titingnan ng bata.
  Widget _buildPreview() {
    final label = _labelController.text.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tintGold,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              RewardIcons.of(_iconKey),
              size: 27,
              color: RewardIcons.inkOf(_iconKey),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.isEmpty
                      ? tr('Pangalan ng pabuya', 'Reward name')
                      : label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                    color: label.isEmpty
                        ? AppColors.textMuted
                        : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                _buildStarBadge(_stars),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in RewardIconGroup.values) ...[
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: group.ink,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                group.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                  fontFamily: 'Nunito',
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final key in RewardIcons.grouped[group] ?? const [])
                _buildIconTile(key),
            ],
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildIconTile(String key) {
    final isSelected = _iconKey == key;

    return Semantics(
      selected: isSelected,
      child: GestureDetector(
        onTap: () => setState(() => _iconKey = isSelected ? null : key),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.tintGold : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.starGold : AppColors.divider,
              width: 2,
            ),
          ),
          child: Icon(
            RewardIcons.of(key),
            size: 22,
            color: RewardIcons.inkOf(key),
          ),
        ),
      ),
    );
  }

  Widget _buildStarPicker() {
    final total = StarService.totalStars();
    final name = HiveService.getActiveChild()?.displayName.trim();
    final hasName = name != null && name.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final level in _starLevels) _buildStarLevel(level)],
        ),
        const SizedBox(height: 12),
        // Walang batayan ang magulang kung ano ang ibig sabihin ng "30 bituin"
        // kung hindi niya nakikita kung ilan na ang naipon ng bata.
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 16, color: AppColors.starGold),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasName
                    ? tr(
                        'May $total bituin na si $name ngayon.',
                        '$name has $total stars right now.',
                      )
                    : tr(
                        'May $total bituin na ngayon.',
                        'There are $total stars right now.',
                      ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _buildHint(
          total >= _stars
              ? tr(
                  'Kaya na niya ito ngayon din.',
                  'They can have this right now.',
                )
              : tr(
                  '${_stars - total} bituin pa ang kailangan.',
                  '${_stars - total} more stars to go.',
                ),
        ),
      ],
    );
  }

  Widget _buildStarLevel(int level) {
    final isSelected = _stars == level;

    return GestureDetector(
      onTap: () => setState(() => _stars = level),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.starGold : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(
            color: isSelected ? AppColors.starGold : AppColors.divider,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_rounded,
              size: 15,
              color: isSelected ? AppColors.surface : AppColors.starGold,
            ),
            const SizedBox(width: 5),
            Text(
              '$level',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
                color: isSelected ? AppColors.surface : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              tr('Kanselahin', 'Cancel'),
              style: const TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.logoGreen,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            child: Text(
              tr('Idagdag', 'Add'),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.6,
        fontFamily: 'Nunito',
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _buildHint(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11.5,
        height: 1.4,
        color: AppColors.textMuted,
        fontFamily: 'Nunito',
      ),
    );
  }
}
