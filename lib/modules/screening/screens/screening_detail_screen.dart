import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/adhd_question.dart';
import '../../../data/models/mchat_question.dart';
import '../../../data/models/screening_result.dart';

class ScreeningDetailScreen extends StatefulWidget {
  final ScreeningResult result;

  const ScreeningDetailScreen({super.key, required this.result});

  @override
  State<ScreeningDetailScreen> createState() => _ScreeningDetailScreenState();
}

/// Pinagsanib na anyo ng isang sagot para iisa lang ang pag-render ng M-CHAT at ADHD.
class _AnswerRow {
  final int number;
  final String text;
  final String answerLabel;
  final bool isAtRisk;

  _AnswerRow({
    required this.number,
    required this.text,
    required this.answerLabel,
    required this.isAtRisk,
  });
}

class _ScreeningDetailScreenState extends State<ScreeningDetailScreen> {
  static const List<String> _adhdLabels = ['Kailanman', 'Minsan', 'Madalas', 'Palagi'];

  List<_AnswerRow> _rows = [];
  bool _isLoading = true;

  bool get _isADHD => widget.result.type == ScreeningResult.typeADHD;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final String asset = _isADHD
        ? 'assets/json/vanderbilt_questions.json'
        : 'assets/json/mchat_questions.json';
    final List<dynamic> data = json.decode(await rootBundle.loadString(asset));

    // Hindi maaasahan ang pagkakasunod-sunod ng keys mula sa Hive.
    final rows = _isADHD ? _buildADHDRows(data) : _buildMChatRows(data);
    rows.sort((a, b) => a.number.compareTo(b.number));

    setState(() {
      _rows = rows;
      _isLoading = false;
    });
  }

  List<_AnswerRow> _buildMChatRows(List<dynamic> data) {
    final byId = {
      for (final item in data) item['id'] as String: MChatQuestion.fromJson(item as Map<String, dynamic>),
    };
    return [
      for (final entry in widget.result.answers.entries)
        _AnswerRow(
          number: byId[entry.key]?.questionNumber ?? 0,
          text: byId[entry.key]?.textTagalog ?? 'Tanong ${entry.key}',
          answerLabel: entry.value == true ? 'OO' : 'HINDI',
          // Sa items 2, 5 at 12 ang "OO" ang at-risk na sagot, kaya hindi sapat ang oo/hindi bilang batayan.
          isAtRisk: byId[entry.key] != null && entry.value == byId[entry.key]!.atRiskAnswer,
        ),
    ];
  }

  List<_AnswerRow> _buildADHDRows(List<dynamic> data) {
    final byId = {
      for (final item in data) item['id'] as String: ADHDQuestion.fromJson(item as Map<String, dynamic>),
    };
    return [
      for (final entry in widget.result.answers.entries)
        _AnswerRow(
          number: byId[entry.key]?.number ?? 0,
          text: byId[entry.key]?.textTagalog ?? 'Tanong ${entry.key}',
          answerLabel: _adhdLabels[(entry.value as int).clamp(0, 3)],
          // Sa Vanderbilt, "Madalas" (2) pataas lang ang binibilang na sintomas.
          isAtRisk: (entry.value as int) >= 2,
        ),
    ];
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
    final formattedDate = '${result.date.day}/${result.date.month}/${result.date.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalyadong Resulta'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
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
                border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    _isADHD ? 'VANDERBILT ADHD' : 'M-CHAT-R AUTISM',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'KABUUANG SCORE: ${result.score}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.riskLevel,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            Text(
              _isADHD
                  ? 'Ang may pulang bandila ay binibilang na sintomas ("Madalas" o "Palagi").'
                  : 'Ang may pulang bandila ay nagdagdag ng risk point sa kabuuang score.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
            ),
            const SizedBox(height: 12),

            // Answers List
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator(color: AppColors.logoGreen)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _rows.length,
                itemBuilder: (context, index) {
                  final row = _rows[index];
                  final isAtRisk = row.isAtRisk;
                  final markColor = isAtRisk ? const Color(0xFFD9383A) : AppColors.logoGreen;

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
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: markColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row.text,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.3),
                                ),
                                if (isAtRisk) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.flag_rounded, size: 13, color: Color(0xFFD9383A)),
                                      const SizedBox(width: 4),
                                      Text(
                                        _isADHD ? '+1 sintomas' : '+1 risk point',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD9383A)),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isAtRisk ? Colors.red.shade50 : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              row.answerLabel,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isAtRisk ? Colors.red.shade800 : Colors.green.shade800,
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