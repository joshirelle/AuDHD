import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/link_launcher.dart';
import '../../../widgets/contact_rows.dart';
import '../../../widgets/kiko_card.dart';
import '../models/dswd_office.dart';

/// Saan puwedeng pumunta.
///
/// Blangko muna ang listahan. Ang UI ay handa na; ang laman ay dadagdag sa
/// `assets/data/dswd_offices.json` kapag may napatunayan na.
class OfficeDirectoryWidget extends StatefulWidget {
  const OfficeDirectoryWidget({super.key});

  @override
  State<OfficeDirectoryWidget> createState() => _OfficeDirectoryWidgetState();
}

class _OfficeDirectoryWidgetState extends State<OfficeDirectoryWidget> {
  late Future<List<DswdOffice>> _future;
  String? _city;

  @override
  void initState() {
    super.initState();
    _future = DswdOffices.load();
  }

  String _failure() => tr(
    'Walang app na makakabukas nito.',
    'There is no app here that can open this.',
  );

  /// Tinatanggal ang puwang at panaklong: hindi lahat ng dialer ay
  /// nakakabasa ng numerong may hitsurang pantao.
  Future<void> _call(String number) async {
    final digits = number.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.isEmpty) return;
    await LinkLauncher.open(
      context,
      Uri(scheme: 'tel', path: digits),
      _failure(),
    );
  }

  Future<void> _openMap(String address) async {
    final query = Uri.encodeComponent(address);
    final opened = await LinkLauncher.tryLaunch(Uri.parse('geo:0,0?q=$query'));
    if (opened || !mounted) return;

    await LinkLauncher.open(
      context,
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$query'),
      _failure(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DswdOffice>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final all = snapshot.data ?? const <DswdOffice>[];
        if (all.isEmpty) return _buildEmpty();

        final cities = DswdOffices.citiesIn(all);
        final visible = _city == null
            ? all
            : all.where((office) => office.city == _city).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            _buildCityChips(cities),
            const SizedBox(height: 16),
            if (visible.isEmpty)
              _buildNoMatch()
            else
              for (final office in visible) ...[
                _buildOffice(office),
                const SizedBox(height: 12),
              ],
            const SizedBox(height: 4),
            _buildHotline(),
          ],
        );
      },
    );
  }

  Widget _buildCityChips(List<String> cities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Anong lungsod', 'Which city'),
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
            for (final city in cities) _buildChip(city, city),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(String label, String? city) {
    final isSelected = _city == city;

    return GestureDetector(
      onTap: () => setState(() => _city = city),
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
        tr('Wala pang opisina dito.', 'No office here yet.'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textMuted,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }

  Widget _buildOffice(DswdOffice office) {
    return KikoCard(
      backgroundColor: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            office.officeName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            office.city,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 8),
          if (office.address != null) ...[
            ContactLinkRow(
              icon: Icons.place_rounded,
              text: office.address!,
              onTap: () => _openMap('${office.officeName}, ${office.address}'),
            ),
            const SizedBox(height: 6),
          ],
          for (final phone in office.contactNumbers) ...[
            // Ang hindi matatawagan ay nababasa pa rin: puwedeng i-dial nang
            // manu-mano, o itanong sa opisina kung ano ang bago.
            if (phone.isDialable)
              ContactLinkRow(
                icon: Icons.call_rounded,
                text: phone.label,
                onTap: () => _call(phone.dial!),
              )
            else
              ContactInfoRow(icon: Icons.call_rounded, text: phone.label),
            const SizedBox(height: 6),
          ],
          if (office.email != null) ...[
            ContactInfoRow(
              icon: Icons.mail_outline_rounded,
              text: office.email!,
            ),
            const SizedBox(height: 6),
          ],
          if (office.operatingHours != null) ...[
            ContactInfoRow(
              icon: Icons.schedule_rounded,
              text: office.operatingHours!,
            ),
            const SizedBox(height: 6),
          ],
          if (office.contactPerson != null) ...[
            ContactInfoRow(
              icon: Icons.person_rounded,
              text: office.contactPerson!,
            ),
            const SizedBox(height: 6),
          ],
          if (office.notes != null) ...[
            ContactInfoRow(
              icon: Icons.sticky_note_2_rounded,
              text: office.notes!,
            ),
            const SizedBox(height: 6),
          ],
          if (office.officialSourceUrl != null) ...[
            const SizedBox(height: 4),
            ContactPill(
              icon: Icons.verified_outlined,
              label: tr('Opisyal na pinagmulan', 'Official source'),
              onTap: () => LinkLauncher.open(
                context,
                Uri.parse(office.officialSourceUrl!),
                _failure(),
              ),
            ),
          ],
          if (office.verifiedOn != null) ...[
            const SizedBox(height: 8),
            Text(
              tr(
                'Huling nakumpirma: ${DateFormatter.monthYear(office.verifiedOn!)}',
                'Last confirmed: ${DateFormatter.monthYear(office.verifiedOn!)}',
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

  /// Walang listahan pa. Sinasabi kung bakit, at binibigay ang tanging
  /// numerong galing mismo sa DSWD.
  Widget _buildEmpty() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        const Icon(
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
            'Ayaw naming maglagay ng address o numerong hindi pa napapatunayan '
                '— may magulang na susunod doon, gagastos ng pamasahe, at '
                'magdadala ng bata.\n\nHabang wala pa, ang opisyal na listahan '
                'ng DSWD ang pinakamalapit sa katotohanan.',
            'We will not put up an address or a number we have not checked — a '
                'parent would follow it, spend on fare, and bring their child.'
                '\n\nUntil we have, the official DSWD list is the closest thing '
                'to the truth.',
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            height: 1.55,
            color: AppColors.textMuted,
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 22),
        _buildHotline(),
        const SizedBox(height: 12),
        _buildOfficeListButton(),
      ],
    );
  }

  Widget _buildHotline() {
    return KikoCard(
      backgroundColor: AppColors.tintTeal,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Pambansang hotline ng DSWD', 'The DSWD national hotline'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.skyInk,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tr(
              'Dito puwedeng itanong kung saan ang pinakamalapit na opisina sa '
                  'inyo.',
              'You can ask here which office is nearest to you.',
            ),
            style: const TextStyle(
              fontSize: 12,
              height: 1.45,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 10),
          ContactLinkRow(
            icon: Icons.call_rounded,
            text: DswdOfficial.hotline,
            onTap: () => _call(DswdOfficial.hotlineDialable),
          ),
          for (final mobile in DswdOfficial.mobileNumbers) ...[
            const SizedBox(height: 6),
            ContactLinkRow(
              icon: Icons.smartphone_rounded,
              text: mobile,
              onTap: () => _call(mobile),
            ),
          ],
          const SizedBox(height: 6),
          ContactInfoRow(
            icon: Icons.mail_outline_rounded,
            text: DswdOfficial.email,
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeListButton() {
    return GestureDetector(
      onTap: () =>
          LinkLauncher.open(context, DswdOfficial.officeList, _failure()),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.logoGreen,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.open_in_new_rounded,
              size: 18,
              color: AppColors.surface,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                tr(
                  'Opisyal na listahan ng opisina',
                  'The official list of offices',
                ),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.surface,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
