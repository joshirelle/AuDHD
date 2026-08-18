import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/models/guide_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/kiko_card.dart';
import '../data/guide_cards.dart';
import '../widgets/parent_tip_sheet.dart';

class KnowledgeHubScreen extends StatefulWidget {
  const KnowledgeHubScreen({super.key});

  @override
  State<KnowledgeHubScreen> createState() => _KnowledgeHubScreenState();
}

class _KnowledgeHubScreenState extends State<KnowledgeHubScreen> {
  /// `null` = lahat.
  GuideCategory? _category;
  bool _savedOnly = false;

  List<GuideCard> get _visible {
    if (_savedOnly) {
      return GuideCards.all
          .where((card) => HiveService.isGuideBookmarked(card.id))
          .toList();
    }
    return GuideCards.inCategory(_category);
  }

  void _selectCategory(GuideCategory? category) {
    setState(() {
      _category = category;
      _savedOnly = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gabay sa Pag-unawa'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      // Binabago ng bottom sheet ang bookmark, kaya kailangan ng listener dito.
      body: ValueListenableBuilder(
        valueListenable: HiveService.getGuideBookmarkBox().listenable(),
        builder: (context, _, _) {
          final cards = _visible;
          return Column(
            children: [
              const SizedBox(height: 16),
              _buildNotice(),
              const SizedBox(height: 16),
              _buildFilters(),
              const SizedBox(height: 8),
              Expanded(
                child: cards.isEmpty
                    ? _buildEmptySaved()
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: cards.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              mainAxisExtent: 235,
                            ),
                        itemBuilder: (context, index) =>
                            _buildTile(cards[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Sinasagot ang tatlong tanong ng magulang bago pa siya magbasa: para saan
  /// ito, ano ang hindi nito ginagawa, at paano ito gagamitin. Marami sa mga
  /// gumagamit ay wala pang diagnosis — hindi tayo ang magsasabi noon.
  Widget _buildNotice() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: KikoCard(
        backgroundColor: AppColors.tintBlue,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.accentBlue,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Para saan ito?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tulong ito para maunawaan ang maaaring pinagdadaanan ng '
                    'anak mo. Hindi ito pagsusuri, at hindi nito sinasabi kung '
                    'anong kondisyon mayroon siya.',
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.45,
                      color: AppColors.textDark,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Magkakapatong ang mga karanasan dito — basahin ang naaayon '
                    'sa nakikita mo, laktawan ang hindi.',
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.45,
                      color: AppColors.textDark,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildChip(
            label: 'Lahat',
            selected: !_savedOnly && _category == null,
            onTap: () => _selectCategory(null),
          ),
          _buildChip(
            label: 'Naka-save',
            icon: Icons.bookmark_rounded,
            selected: _savedOnly,
            onTap: () => setState(() {
              _savedOnly = true;
              _category = null;
            }),
          ),
          for (final category in GuideCategory.values)
            _buildChip(
              label: category.label,
              icon: category.icon,
              selected: !_savedOnly && _category == category,
              onTap: () => _selectCategory(category),
            ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.logoGreen : AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected ? AppColors.logoGreen : AppColors.divider,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: selected ? Colors.white : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : AppColors.textDark,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(GuideCard card) {
    final category = card.category;
    final bookmarked = HiveService.isGuideBookmarked(card.id);

    return KikoCard(
      backgroundColor: category.background,
      padding: EdgeInsets.zero,
      onTap: () => showParentTipSheet(context, card),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            card.icon,
                            size: 20,
                            color: category.ink,
                          ),
                        ),
                        const Spacer(),
                        if (bookmarked)
                          const Icon(
                            Icons.bookmark_rounded,
                            size: 18,
                            color: AppColors.starGold,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      card.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: category.ink,
                        height: 1.2,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: Text(
                        card.summary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          height: 1.35,
                          color: AppColors.textDark,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              color: Colors.white.withValues(alpha: 0.55),
              child: Text(
                '"${card.quote}"',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.3,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: category.ink,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySaved() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 56,
              color: AppColors.divider,
            ),
            const SizedBox(height: 14),
            const Text(
              'Wala ka pang naka-save',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Buksan ang isang gabay at pindutin ang bookmark sa itaas '
              'para mabilis mo itong mabalikan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textMuted,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
