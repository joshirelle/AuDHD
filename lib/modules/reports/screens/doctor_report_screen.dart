import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/child_profile.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/kiko_card.dart';
import '../services/doctor_pdf_service.dart';

class DoctorReportScreen extends StatefulWidget {
  const DoctorReportScreen({super.key});

  @override
  State<DoctorReportScreen> createState() => _DoctorReportScreenState();
}

class _DoctorReportScreenState extends State<DoctorReportScreen> {
  int _rangeDays = DoctorPdfService.rangeLast30Days;
  bool _isSharing = false;

  Future<Uint8List> _buildPdf(ChildProfile child) {
    return DoctorPdfService.generateDoctorReport(
      childName: child.name,
      childAgeMonths: child.ageInMonthsOn(DateTime.now()),
      rangeDays: _rangeDays,
    );
  }

  Future<void> _share(ChildProfile child) async {
    setState(() => _isSharing = true);
    try {
      final bytes = await _buildPdf(child);
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'progress-report-$_rangeDays-araw.pdf',
      );
    } catch (error) {
      debugPrint('DoctorReportScreen: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hindi naibahagi ang ulat. Subukan ulit.'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = HiveService.getChildProfile();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulat para sa Doktor'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: child == null ? _buildNoChildState() : _buildPreview(child),
    );
  }

  Widget _buildNoChildState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: KikoCard(
          backgroundColor: AppColors.butterYellow,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.butterInk,
                size: 32,
              ),
              const SizedBox(height: 12),
              const Text(
                'Kailangan muna ng profile ng bata bago makabuo ng ulat para sa doktor.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark,
                  fontFamily: 'Nunito',
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(ChildProfile child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRangeChip('Huling 30 Araw', DoctorPdfService.rangeLast30Days),
              const SizedBox(width: 10),
              _buildRangeChip('Huling 90 Araw', DoctorPdfService.rangeLast90Days),
            ],
          ),
        ),
        Expanded(
          child: PdfPreview(
            // Pinipilit ang muling pagbuo kapag nagpalit ng saklaw ang magulang.
            key: ValueKey(_rangeDays),
            build: (format) => _buildPdf(child),
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowSharing: false,
            allowPrinting: true,
            loadingWidget: const CircularProgressIndicator(
              color: AppColors.logoGreen,
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              height: 54,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSharing ? null : () => _share(child),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.logoGreen,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: _isSharing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.ios_share_rounded, color: Colors.white),
                label: Text(
                  _isSharing ? 'Inihahanda...' : 'I-share sa Doktor (PDF)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _isSharing ? Colors.grey.shade600 : Colors.white,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRangeChip(String label, int days) {
    final isSelected = _rangeDays == days;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_rangeDays == days) return;
          setState(() => _rangeDays = days);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.mintGreen : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(
              color: isSelected ? AppColors.logoGreen : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.mintInk : AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ),
    );
  }
}
