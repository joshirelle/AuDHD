import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/child_profile.dart';
import '../../../data/services/hive_service.dart';
import '../../profile/child_editor_dialog.dart';

/// Babala bago ang screening kapag wala sa saklaw ng edad ang bata.
///
/// Hindi ito humaharang — may mga magulang na may dahilan para magpatuloy —
/// pero tahasang nagbabago ang label ng button para malinaw ang pinipili nila.
class ScreeningAgeGate extends StatefulWidget {
  final String instrumentName;
  final String rangeDescription;
  final int minMonths;

  /// `null` kapag walang itaas na hangganan.
  final int? maxMonths;

  final String belowRangeAdvice;
  final String aboveRangeAdvice;
  final WidgetBuilder screeningBuilder;

  const ScreeningAgeGate({
    super.key,
    required this.instrumentName,
    required this.rangeDescription,
    required this.minMonths,
    required this.maxMonths,
    required this.belowRangeAdvice,
    required this.aboveRangeAdvice,
    required this.screeningBuilder,
  });

  @override
  State<ScreeningAgeGate> createState() => _ScreeningAgeGateState();
}

class _ScreeningAgeGateState extends State<ScreeningAgeGate> {
  ChildProfile? _child;

  @override
  void initState() {
    super.initState();
    _child = HiveService.getChildProfile();
  }

  Future<void> _editProfile(ChildProfile child) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => ChildEditorDialog(existing: child),
    );
    if (saved == true) {
      setState(() => _child = HiveService.getChildProfile());
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _child;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tsek ng Edad'),
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: child == null ? _buildNoChild() : _buildGate(child),
    );
  }

  Widget _buildNoChild() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'Walang piniling bata. Bumalik at pumili muna sa Profile.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontFamily: 'Nunito'),
        ),
      ),
    );
  }

  Widget _buildGate(ChildProfile child) {
    final months = child.ageInMonthsOn(DateTime.now());
    final isBelow = months < widget.minMonths;
    final isAbove = widget.maxMonths != null && months > widget.maxMonths!;
    final isValid = !isBelow && !isAbove;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Angkop ba ang edad ni ${child.displayName}?',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.rangeDescription,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.4,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 24),
          _buildBirthCard(child),
          const SizedBox(height: 20),
          _buildVerdict(child, months, isValid, isBelow),
          const Spacer(),
          _buildProceedButton(isValid),
        ],
      ),
    );
  }

  Widget _buildBirthCard(ChildProfile child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.logoGreen, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.cake_rounded, color: AppColors.logoGreen, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Petsa ng Kapanganakan',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.longDate(child.birthDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _editProfile(child),
            child: const Text(
              'Baguhin',
              style: TextStyle(
                color: AppColors.logoGreen,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerdict(
    ChildProfile child,
    int months,
    bool isValid,
    bool isBelow,
  ) {
    final accent = isValid ? AppColors.logoGreen : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isValid ? AppColors.tintSuccess : AppColors.tintWarm,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isValid ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: accent,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edad: $months na buwan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accent,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isValid
                      ? 'Angkop ang edad ni ${child.displayName} para sa ${widget.instrumentName}.'
                      : isBelow
                      ? widget.belowRangeAdvice
                      : widget.aboveRangeAdvice,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textDark,
                    height: 1.35,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProceedButton(bool isValid) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isValid ? AppColors.logoGreen : AppColors.warning,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: widget.screeningBuilder),
      ),
      child: Text(
        isValid ? 'Ipagpatuloy ang Screening' : 'Ipagpatuloy pa rin',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.surface,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }
}
