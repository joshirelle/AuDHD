import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../core/services/pdf_export_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/screening_answer_row.dart';
import '../../../data/models/screening_result.dart';
import '../../../data/services/hive_service.dart';

class ScreeningDetailScreen extends StatefulWidget {
  final ScreeningResult result;

  const ScreeningDetailScreen({super.key, required this.result});

  @override
  State<ScreeningDetailScreen> createState() => _ScreeningDetailScreenState();
}

class _ScreeningDetailScreenState extends State<ScreeningDetailScreen> {
  List<ScreeningAnswerRow> _rows = [];
  bool _isLoading = true;

  bool get _isADHD => widget.result.type == ScreeningResult.typeADHD;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final rows = await ScreeningAnswerRow.buildFor(widget.result);
    if (!mounted) return;
    setState(() {
      _rows = rows;
      _isLoading = false;
    });
  }

  Color _getRiskColor(String riskLevel) {
    if (riskLevel.contains('HIGH')) return const Color(0xFFD9383A);
    if (riskLevel.contains('MEDIUM')) return const Color(0xFFD9A000);
    return const Color(0xFF2D7A4D);
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final color = _getRiskColor(result.riskLevel);
    final formattedDate =
        '${result.date.day}/${result.date.month}/${result.date.year}';
    // Walang slash — ginagamit ito sa filename.
    final fileDate = '${result.date.year}-${result.date.month}-${result.date.day}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalyadong Resulta'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.picture_as_pdf_rounded,
              color: AppColors.logoGreen,
            ),
            tooltip: 'Export as PDF',
            onPressed: () async {
              final child = HiveService.getChildProfile();
              final pdfData = await PdfExportService.generateScreeningReport(
                result,
                _rows,
                childName: child?.name,
                birthDate: child?.birthDate,
              );
              // Malayang teksto ang pangalan, kaya sinasala ang mga bawal sa filename.
              final safeName = (child?.name ?? 'Bata').replaceAll(
                RegExp(r'[^A-Za-z0-9]+'),
                '_',
              );
              await Printing.layoutPdf(
                onLayout: (format) => pdfData,
                name:
                    'Screening_Report_${safeName}_${_isADHD ? 'Vanderbilt' : 'MCHAT'}_$fileDate.pdf',
              );
            },
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _isADHD ? 'VANDERBILT ADHD' : 'M-CHAT-R AUTISM',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'KABUUANG SCORE: ${result.score}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.riskLevel,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Petsa ng Screening: $formattedDate',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Mga Tala ng Sagot',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isADHD
                  ? 'Ang may pulang bandila ay binibilang na sintomas ("Madalas" o "Palagi").'
                  : 'Ang may pulang bandila ay nagdagdag ng risk point sa kabuuang score.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            // Answers List
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.logoGreen),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _rows.length,
                itemBuilder: (context, index) {
                  final row = _rows[index];
                  final isAtRisk = row.isAtRisk;
                  final markColor = isAtRisk
                      ? const Color(0xFFD9383A)
                      : AppColors.logoGreen;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isAtRisk ? const Color(0xFFFFF5F4) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isAtRisk ? markColor : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: markColor.withValues(alpha: 0.15),
                            child: Text(
                              '${row.number}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: markColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row.text,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),
                                if (isAtRisk) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.flag_rounded,
                                        size: 13,
                                        color: Color(0xFFD9383A),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _isADHD
                                            ? '+1 sintomas'
                                            : '+1 risk point',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFD9383A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isAtRisk
                                  ? Colors.red.shade50
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              row.answerLabel,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isAtRisk
                                    ? Colors.red.shade800
                                    : Colors.green.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
