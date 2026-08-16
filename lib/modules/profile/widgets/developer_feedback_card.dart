import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/kiko_card.dart';

class DeveloperFeedbackCard extends StatefulWidget {
  const DeveloperFeedbackCard({super.key});

  @override
  State<DeveloperFeedbackCard> createState() => _DeveloperFeedbackCardState();
}

class _DeveloperFeedbackCardState extends State<DeveloperFeedbackCard> {
  static final Uri _profileUrl = Uri.parse(
    'https://facebook.com/joshuagadsila',
  );

  String? _version;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    // Mula sa build, hindi hardcoded: hindi masusundan ng nakasulat na bilang
    // ang pagtaas ng bersyon sa pubspec.
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = 'v${info.version}');
  }

  Future<void> _openMessenger() async {
    // Hindi dumadaan sa canLaunchUrl: nagbabalik ito ng false sa mga device na
    // walang naka-deklarang <queries>, kahit kayang buksan ang link.
    final isLaunched = await launchUrl(
      _profileUrl,
      mode: LaunchMode.externalApplication,
    );
    if (isLaunched || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hindi mabuksan ang Facebook. Subukan ulit mamaya.'),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KikoCard(
      backgroundColor: AppColors.tintTeal,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'May feedback o suhestiyon?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Mag-message nang direkta sa developer para sa mga tanong o tulong.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textDark,
              height: 1.35,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _openMessenger,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: AppColors.surface,
              side: const BorderSide(color: AppColors.accentBlue, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            icon: const Icon(
              Icons.chat_bubble_rounded,
              size: 18,
              color: AppColors.accentBlue,
            ),
            label: const Text(
              'Kausapin ang Developer',
              style: TextStyle(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    const style = TextStyle(
      fontSize: 11,
      color: AppColors.textDark,
      fontFamily: 'Nunito',
    );

    return Column(
      children: [
        Text(
          _version == null ? 'AuDHD' : 'AuDHD $_version',
          textAlign: TextAlign.center,
          style: style,
        ),
        const SizedBox(height: 3),
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Developed with '),
              // WidgetSpan sa halip na Row: sumasabay ang icon sa linya ng
              // teksto kaya hindi nasisira ang pagkaka-center kapag bumalot.
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(
                  Icons.favorite_rounded,
                  size: 11,
                  color: AppColors.danger,
                ),
              ),
              TextSpan(text: ' by Josh-Irelle C. Budano'),
            ],
          ),
          textAlign: TextAlign.center,
          style: style,
        ),
      ],
    );
  }
}
