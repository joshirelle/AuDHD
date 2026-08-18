import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme.dart';
import 'kiko_card.dart';

/// Facebook group ng mga magulang na gumagamit ng AuDHD.
///
/// Dalawang lugar ang gumagamit nito, kaya iisang constant — isang linya lang
/// ang papalitan kapag nagbago ang address.
///
/// Ang `mibextid` ay tracking parameter na idinagdag ng Facebook share sheet.
/// Kung gumagana ang link nang wala ito, alisin.
const String audhdGroupUrl =
    'https://www.facebook.com/share/g/1EqqRUEjNM/?mibextid=wwXIfr';

/// Walang ipinapadala ang app dito — bubukas lang ang Facebook, at ang magulang
/// ang magpapasya kung susulat siya doon.
Future<void> openAudhdGroup(BuildContext context) async {
  // Hindi dumadaan sa canLaunchUrl: nagbabalik ito ng false sa ilang device
  // kahit kayang buksan ang link.
  final isLaunched = await launchUrl(
    Uri.parse(audhdGroupUrl),
    mode: LaunchMode.externalApplication,
  );
  if (isLaunched || !context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Hindi mabuksan ang Facebook. Subukan ulit mamaya.'),
      backgroundColor: AppColors.danger,
    ),
  );
}

class CommunityCard extends StatelessWidget {
  const CommunityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return KikoCard(
      backgroundColor: AppColors.tintWarm,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: AppColors.coralInk,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Komunidad ng AuDHD',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Hindi ka nag-iisa — may grupo ng mga magulang na dumaraan din '
            'dito. Magtanong, magbahagi, o makinig lang.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textDark,
              height: 1.4,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bubukas ito sa Facebook. Makikita ng ibang miyembro ang anumang '
            'isulat mo doon.',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
              height: 1.4,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => openAudhdGroup(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.coralInk,
                side: const BorderSide(color: AppColors.coralInk),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text(
                'Buksan ang grupo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
