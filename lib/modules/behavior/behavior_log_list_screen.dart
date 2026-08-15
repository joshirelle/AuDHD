import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/behavior_log.dart';
import '../../data/services/hive_service.dart';
import 'behavior_log_form_screen.dart';

class BehaviorLogListScreen extends StatefulWidget {
  const BehaviorLogListScreen({super.key});

  @override
  State<BehaviorLogListScreen> createState() => _BehaviorLogListScreenState();
}

class _BehaviorLogListScreenState extends State<BehaviorLogListScreen> {
  static const List<Color> _intensityColors = [
    AppColors.mintGreen,
    AppColors.skyBlue,
    AppColors.butterYellow,
    AppColors.coralPeach,
    Color(0xFFE57373),
  ];

  List<BehaviorLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _logs = HiveService.getAllLogs());
  }

  Future<void> _openForm() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const BehaviorLogFormScreen()),
    );
    if (saved == true) _load();
  }

  void _showDetail(BehaviorLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_formatStamp(log.timestamp), style: const TextStyle(fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailBlock('A — Nauna', log.antecedent),
              _detailBlock('B — Kilos', log.behavior),
              _detailBlock('C — Tugon', log.consequence),
              _detailBlock('Tindi', '${log.intensity} / 5'),
              _detailBlock('Tagal', '${log.durationMinutes} minuto'),
              if (log.sensoryTriggers.isNotEmpty)
                _detailBlock('Sensory Triggers', log.sensoryTriggers.join(', ')),
              if (log.notes != null) _detailBlock('Tala', log.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Isara'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tala ng Ugali'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.logoGreen,
        onPressed: _openForm,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Bagong Tala',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _logs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_note_rounded, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Wala pang naitalang insidente.',
                      style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Itala ang A-B-C: ano ang nauna, anong kilos ang nakita, at ano ang ginawa mo. '
                      'Sa paglipas ng panahon, lilitaw ang pattern ng mga trigger.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final color = _intensityColors[(log.intensity - 1).clamp(0, 4)];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: () => _showDetail(log),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${log.intensity}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.behavior,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.3),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_formatStamp(log.timestamp)}  •  ${log.durationMinutes} min',
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'A: ${log.antecedent}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                          ),
                          if (log.sensoryTriggers.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final trigger in log.sensoryTriggers)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.skyBlueLight,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      trigger,
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF16537E)),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  static String _formatStamp(DateTime stamp) {
    final hour = stamp.hour % 12 == 0 ? 12 : stamp.hour % 12;
    final minute = stamp.minute.toString().padLeft(2, '0');
    final period = stamp.hour < 12 ? 'AM' : 'PM';
    return '${stamp.day}/${stamp.month}/${stamp.year}  $hour:$minute $period';
  }

  Widget _detailBlock(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.logoGreen),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, height: 1.3)),
        ],
      ),
    );
  }
}
