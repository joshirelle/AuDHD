import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/behavior_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/behavior_log.dart';
import '../../data/services/hive_service.dart';

class BehaviorLogFormScreen extends StatefulWidget {
  const BehaviorLogFormScreen({super.key});

  @override
  State<BehaviorLogFormScreen> createState() => _BehaviorLogFormScreenState();
}

class _BehaviorLogFormScreenState extends State<BehaviorLogFormScreen> {
  static const List<Color> _intensityColors = [
    AppColors.mintGreen,
    AppColors.skyBlue,
    AppColors.butterYellow,
    AppColors.coralPeach,
    Color(0xFFE57373),
  ];

  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _antecedent;
  String? _behavior;
  String? _consequence;
  final Set<String> _sensoryTriggers = {};
  int _intensity = 3;
  String? _error;

  @override
  void dispose() {
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<String?> _promptCustom(String title) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kanselahin'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.logoGreen),
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    controller.dispose();
    return (value == null || value.isEmpty) ? null : value;
  }

  Future<void> _selectOption({
    required String title,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        children: [
          for (final option in options)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, option),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(option, style: const TextStyle(fontSize: 14)),
              ),
            ),
          const Divider(),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, _customSentinel),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Iba pa — isusulat ko',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.logoGreen),
              ),
            ),
          ),
        ],
      ),
    );

    if (picked == null) return;
    if (picked == _customSentinel) {
      final custom = await _promptCustom(title);
      if (custom != null) onSelected(custom);
      return;
    }
    onSelected(picked);
  }

  static const String _customSentinel = '__custom__';

  Future<void> _save() async {
    final duration = int.tryParse(_durationController.text.trim());

    if (_antecedent == null || _behavior == null || _consequence == null) {
      setState(() => _error = 'Kailangan ang A, B at C bago mag-save.');
      return;
    }
    if (duration == null || duration <= 0) {
      setState(() => _error = 'Kailangan ang tagal sa minuto.');
      return;
    }

    final notes = _notesController.text.trim();
    await HiveService.addLog(
      BehaviorLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        antecedent: _antecedent!,
        behavior: _behavior!,
        consequence: _consequence!,
        sensoryTriggers: _sensoryTriggers.toList(),
        intensity: _intensity,
        durationMinutes: duration,
        notes: notes.isEmpty ? null : notes,
      ),
    );

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bagong Tala'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Isulat ang nangyari habang sariwa pa. Ang A-B-C ay tumutulong sa Developmental Pediatrician na makita ang pattern.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
          ),
          const SizedBox(height: 20),

          _pickerField(
            letter: 'A',
            label: 'Antecedent — ano ang nauna?',
            value: _antecedent,
            onTap: () => _selectOption(
              title: 'Ano ang nangyari bago ang insidente?',
              options: BehaviorConstants.commonAntecedents,
              onSelected: (v) => setState(() => _antecedent = v),
            ),
          ),
          const SizedBox(height: 12),
          _pickerField(
            letter: 'B',
            label: 'Behavior — anong kilos ang nakita?',
            value: _behavior,
            onTap: () => _selectOption(
              title: 'Anong kilos ang naobserbahan?',
              options: BehaviorConstants.commonBehaviors,
              onSelected: (v) => setState(() => _behavior = v),
            ),
          ),
          const SizedBox(height: 12),
          _pickerField(
            letter: 'C',
            label: 'Consequence — ano ang ginawa mo?',
            value: _consequence,
            onTap: () => _selectOption(
              title: 'Anong tugon o interbensyon ang ginawa?',
              options: BehaviorConstants.commonConsequences,
              onSelected: (v) => setState(() => _consequence = v),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Sensory Triggers',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in BehaviorConstants.sensoryCategories)
                FilterChip(
                  label: Text(category, style: const TextStyle(fontSize: 12)),
                  selected: _sensoryTriggers.contains(category),
                  selectedColor: AppColors.skyBlueLight,
                  checkmarkColor: const Color(0xFF16537E),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _sensoryTriggers.add(category);
                      } else {
                        _sensoryTriggers.remove(category);
                      }
                    });
                  },
                ),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            'Tindi ng Insidente',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (int level = 1; level <= 5; level++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _intensity = level),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _intensityColors[level - 1],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _intensity == level ? AppColors.textDark : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Text(
                          '$level',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '1 = banayad  •  5 = napakatindi',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 24),
          TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Tagal (minuto)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Karagdagang tala (opsyonal)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Color(0xFFD9383A), fontSize: 12),
            ),
          ],

          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.logoGreen,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: _save,
            child: const Text(
              'I-save ang Tala',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickerField({
    required String letter,
    required String label,
    required String? value,
    required VoidCallback onTap,
  }) {
    final bool filled = value != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: filled ? AppColors.logoGreen : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: filled ? AppColors.logoGreen : Colors.grey.shade300,
              child: Text(
                letter,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: filled ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text(
                    value ?? 'Pumili',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: filled ? AppColors.textDark : Colors.grey.shade500,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
