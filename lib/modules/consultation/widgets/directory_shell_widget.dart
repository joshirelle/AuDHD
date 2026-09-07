import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/link_launcher.dart';
import '../../../widgets/contact_rows.dart';
import '../../../widgets/kiko_card.dart';
import '../models/consultation_center.dart';

/// Listahan ng mapagpapatingnan.
///
/// HINDI ITO PATAY NA CODE. Sinasadyang hindi nakakabit habang v6 — kulang pa
/// ang datos sa `assets/data/verified_centers.json`: walang numero at magaspang
/// ang address ng karamihan. Ibabalik ito sa `ConsultationScreen` kapag
/// kumpleto na. Huwag burahin kasama nito ang asset.
class DirectoryShellWidget extends StatefulWidget {
  const DirectoryShellWidget({super.key});

  @override
  State<DirectoryShellWidget> createState() => _DirectoryShellWidgetState();
}

class _DirectoryShellWidgetState extends State<DirectoryShellWidget> {
  late Future<List<ConsultationCenter>> _future;
  final TextEditingController _search = TextEditingController();
  CenterKind? _kind;
  CenterType? _filter;

  @override
  void initState() {
    super.initState();
    _future = ConsultationCenters.load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ConsultationCenter> _visible(List<ConsultationCenter> all) {
    final query = _search.text.trim().toLowerCase();
    return all.where((center) {
      if (_kind != null && center.kind != _kind) return false;
      if (_filter != null && center.type != _filter) return false;
      if (query.isEmpty) return true;
      return center.name.toLowerCase().contains(query) ||
          center.region.toLowerCase().contains(query) ||
          center.address.toLowerCase().contains(query);
    }).toList();
  }

  /// Naka-sunod-sunod na ang magkakalugar dahil sa pag-sort sa `load()`, kaya
  /// ang pagkakasunod ng pagpasok dito ang mismong pagkakasunod sa pantalan.
  Map<String, List<ConsultationCenter>> _grouped(
    List<ConsultationCenter> centers,
  ) {
    final groups = <String, List<ConsultationCenter>>{};
    for (final center in centers) {
      groups.putIfAbsent(center.region, () => []).add(center);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConsultationCenter>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final all = snapshot.data ?? const <ConsultationCenter>[];
        if (all.isEmpty) return _buildEmpty();

        final visible = _visible(all);
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            _buildBanner(),
            const SizedBox(height: 14),
            _buildSearch(),
            const SizedBox(height: 12),
            _buildFilters(),
            const SizedBox(height: 16),
            if (visible.isEmpty)
              _buildNoMatch()
            else
              for (final group in _grouped(visible).entries) ...[
                _buildRegionHeader(group.key, group.value.length),
                const SizedBox(height: 10),
                for (final center in group.value) ...[
                  _buildCenter(center),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 6),
              ],
          ],
        );
      },
    );
  }

  /// Walang banner na nagsasabing "verified" habang wala pang laman — iyon ang
  /// pinaka-mapanganib na pangakong hindi natutupad sa buong app.
  Widget _buildEmpty() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        Icon(
          Icons.travel_explore_rounded,
          size: 52,
          color: AppColors.textMuted,
        ),
        const SizedBox(height: 18),
        Text(
          tr('Ginagawa pa ang listahan', 'The list is still being built'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          tr(
            'Wala pa kaming maibibigay na listahan ng klinika. Ayaw naming '
                'magbigay ng pangalan o numerong hindi pa napapatunayan — may '
                'magulang na tatawag doon, gagastos ng pamasahe, at magdadala '
                'ng bata.\n\nKapag napatunayan na namin kasama ng mga magulang '
                'at healthcare professional, dito ito lalabas.',
            'We do not have a list of clinics to give you yet. We will not put '
                'up a name or a number we have not checked — a parent would call '
                'it, spend on fare, and bring their child.\n\nOnce it is '
                'verified with parents and healthcare professionals, it will '
                'appear here.',
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            height: 1.55,
            color: AppColors.textMuted,
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 24),
        KikoCard(
          backgroundColor: AppColors.tintSuccess,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 18,
                    color: AppColors.mintInk,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tr('Habang wala pa', 'In the meantime'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mintInk,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                tr(
                  'Magsimula sa health center o barangay ninyo at itanong kung '
                      'saan sila nagre-refer para sa developmental pediatrician. '
                      'Sila ang karaniwang unang hakbang, at may listahan sila ng '
                      'malapit sa inyo.\n\nMagandang itanong din ito sa grupo ng '
                      'mga magulang — marami na ang dumaan dito.',
                  'Start at your health center or barangay and ask where they '
                      'refer families for a developmental pediatrician. They are '
                      'usually the first step and they know what is near you.'
                      '\n\nIt is also worth asking in the parents group — many '
                      'have already been through this.',
                ),
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.mintInk,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return KikoCard(
      backgroundColor: AppColors.tintGold,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: AppColors.warning,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tr(
                'Ang mga pangalan at lugar dito ay hindi galing sa amin — '
                    'galing ito sa internet. Maaaring ito pa rin ang gamit ng '
                    'mga sentro, o maaaring nabago na.\n\nHanapin at kausapin '
                    'muna sila bago kayo bumiyahe. Hindi namin masisiguro kung '
                    'tumatanggap pa sila o magkano ang bayad.',
                'The names and places here did not come from us — they came '
                    'from the internet. They may still be current, or they may '
                    'have changed.\n\nLook them up and speak to them before you '
                    'travel. We cannot promise they are still accepting '
                    'patients or what they charge.',
              ),
              style: const TextStyle(
                fontSize: 12,
                height: 1.45,
                color: AppColors.textDark,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _search,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontSize: 14, fontFamily: 'Nunito'),
      decoration: InputDecoration(
        hintText: tr('Hanapin ang lugar o pangalan', 'Search place or name'),
        prefixIcon: const Icon(Icons.search_rounded),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Anong hinahanap mo', 'What you are looking for'),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildKindChip(tr('Lahat', 'All'), null),
            for (final kind in CenterKind.values)
              _buildKindChip(kind.label, kind),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          tr('Pampubliko o pribado', 'Public or private'),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip(tr('Lahat', 'All'), null),
            for (final type in CenterType.values) _buildChip(type.label, type),
          ],
        ),
      ],
    );
  }

  Widget _buildKindChip(String label, CenterKind? kind) {
    final isSelected = _kind == kind;

    return GestureDetector(
      onTap: () => setState(() => _kind = kind),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.logoGreen : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(
            color: isSelected ? AppColors.logoGreen : AppColors.divider,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.surface : AppColors.textDark,
            fontFamily: 'Nunito',
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, CenterType? type) {
    final isSelected = _filter == type;

    return GestureDetector(
      onTap: () => setState(() => _filter = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.logoGreen : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(
            color: isSelected ? AppColors.logoGreen : AppColors.divider,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.surface : AppColors.textDark,
            fontFamily: 'Nunito',
          ),
        ),
      ),
    );
  }

  Widget _buildNoMatch() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(
        tr('Walang tumugma sa hinahanap mo.', 'Nothing matched your search.'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textMuted,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }

  Widget _buildCenter(ConsultationCenter center) {
    return KikoCard(
      backgroundColor: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  center.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: center.type == CenterType.public
                      ? AppColors.mintGreen
                      : AppColors.skyBlueLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  center.type.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: center.type == CenterType.public
                        ? AppColors.mintInk
                        : AppColors.skyInk,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // `Wrap` at hindi `Row`: mahaba ang paglalarawan ng uri, kaya hindi
          // sila laging magkasya nang magkatabi sa makitid na telepono.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: center.kind == CenterKind.therapy
                      ? AppColors.tintTeal
                      : AppColors.tintWarm,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${center.kind.label} \u00b7 ${center.kind.description}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              if (center.closedOn != null) _buildClosedBadge(center.closedOn!),
            ],
          ),
          const SizedBox(height: 8),
          _buildAddressRow(center),
          if (center.contactNumber != null) ...[
            const SizedBox(height: 6),
            _buildPhoneRow(center.contactNumber!),
          ],
          if (center.schedule != null) ...[
            const SizedBox(height: 6),
            _buildRow(Icons.schedule_rounded, center.schedule!),
          ],
          if (center.notes != null) ...[
            const SizedBox(height: 6),
            _buildRow(Icons.sticky_note_2_rounded, center.notes!),
          ],
          if (center.facebookUrl != null) ...[
            const SizedBox(height: 10),
            _buildFacebookLink(center.facebookUrl!),
          ],
          if (center.verifiedOn != null) ...[
            const SizedBox(height: 8),
            Text(
              tr(
                'Huling nakumpirma: ${DateFormatter.monthYear(center.verifiedOn!)}',
                'Last confirmed: ${DateFormatter.monthYear(center.verifiedOn!)}',
              ),
              style: const TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: AppColors.textMuted,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Kayumanggi at hindi pula: karaniwan lang ang saradong araw, kaya hindi
  /// ito dapat kabahan ng magulang.
  Widget _buildClosedBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.tintGold,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.event_busy_rounded,
            size: 13,
            color: AppColors.warning,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.warning,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sumusunod ang bilang sa hinahanap at sa filter, kaya nakikita agad ng
  /// magulang kung ilan ang natitira sa lugar niya.
  Widget _buildRegionHeader(String region, int count) {
    return Row(
      children: [
        Text(
          region.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: AppColors.textDark,
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: SizedBox(
            height: 1,
            child: ColoredBox(color: AppColors.divider),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.tintGold,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ],
    );
  }

  /// Walang ipinapadala ang app dito — bubukas lang ang Facebook, at ang
  /// magulang ang magpapasya kung susulat siya.
  Widget _buildFacebookLink(String url) {
    return ContactPill(
      icon: Icons.chat_rounded,
      label: tr('Buksan ang Facebook page', 'Open their Facebook page'),
      onTap: () => _open(
        Uri.parse(url),
        tr(
          'Hindi mabuksan ang Facebook. Subukan ulit mamaya.',
          'Could not open Facebook. Please try again later.',
        ),
      ),
    );
  }

  Future<void> _open(Uri uri, String failureMessage) =>
      LinkLauncher.open(context, uri, failureMessage);

  /// Sinusubukan muna ang maps app bago ang browser: bumubukas ang `geo:`
  /// kahit mahina ang signal, samantalang ang browser naman ang tiyak na
  /// mayroon ang bawat telepono.
  Future<void> _openMap(ConsultationCenter center) async {
    final query = Uri.encodeComponent(
      '${center.name}, ${center.address}, ${center.region}, Philippines',
    );
    if (await LinkLauncher.tryLaunch(Uri.parse('geo:0,0?q=$query'))) return;
    if (await LinkLauncher.tryLaunch(
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$query'),
    )) {
      return;
    }
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(
            'Hindi mabuksan ang mapa. Kopyahin na lang ang address.',
            'Could not open maps. Please copy the address instead.',
          ),
        ),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  /// Hinahanap ang address sa maps app. Hindi ito nagbibigay ng direksyon
  /// nang kusa — ang magulang pa rin ang pipindot niyon doon.
  Widget _buildAddressRow(ConsultationCenter center) {
    return ContactLinkRow(
      icon: Icons.place_rounded,
      text: '${center.address}, ${center.region}',
      onTap: () => _openMap(center),
    );
  }

  /// Bumubukas ang dialer na may nakalagay nang numero. Hindi ito tumatawag
  /// nang kusa — ang magulang pa rin ang pipindot.
  Widget _buildPhoneRow(String number) {
    return ContactLinkRow(
      icon: Icons.call_rounded,
      text: number,
      onTap: () => _open(
        Uri.parse('tel:${number.replaceAll(RegExp(r'[^0-9+]'), '')}'),
        tr(
          'Hindi mabuksan ang dialer. Kopyahin na lang ang numero.',
          'Could not open the dialer. Please copy the number instead.',
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String text) =>
      ContactInfoRow(icon: icon, text: text);
}
