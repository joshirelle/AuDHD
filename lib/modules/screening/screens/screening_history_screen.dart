import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/screening_result.dart';
import '../../../data/services/hive_service.dart';
import 'screening_detail_screen.dart';

class ScreeningHistoryScreen extends StatefulWidget {
  const ScreeningHistoryScreen({super.key});

  @override
  State<ScreeningHistoryScreen> createState() => _ScreeningHistoryScreenState();
}

class _ScreeningHistoryScreenState extends State<ScreeningHistoryScreen> {
  List<ScreeningResult> _results = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final history = HiveService.getAllScreeningResults();
    setState(() {
      _results = history;
    });
  }

  Color _getRiskColor(String riskLevel) {
    if (riskLevel.contains('HIGH')) return const Color(0xFFD9383A);
    if (riskLevel.contains('MEDIUM')) return const Color(0xFFD9A000);
    return const Color(0xFF2D7A4D);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tala ng mga Screening'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: _results.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text('Wala pang nakatalang screening result.', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final item = _results[index];
                final color = _getRiskColor(item.riskLevel);
                final formattedDate = '${item.date.day}/${item.date.month}/${item.date.year}';
                final isADHD = item.type == ScreeningResult.typeADHD;
                final testColor = isADHD ? const Color(0xFF3B82F6) : AppColors.logoGreen;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Text(
                        '${item.score}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: color),
                      ),
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: testColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isADHD ? 'Vanderbilt' : 'M-CHAT-R',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: testColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.riskLevel,
                            style: TextStyle(fontWeight: FontWeight.bold, color: color),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text('Petsa: $formattedDate • ${item.answers.length} na Tanong'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScreeningDetailScreen(result: item),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}