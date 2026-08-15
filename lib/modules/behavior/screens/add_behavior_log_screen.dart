import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/behavior_constants.dart';
import '../../../data/models/behavior_log.dart';
import '../../../data/services/hive_service.dart';

class AddBehaviorLogScreen extends StatefulWidget {
  const AddBehaviorLogScreen({super.key});

  @override
  State<AddBehaviorLogScreen> createState() => _AddBehaviorLogScreenState();
}

class _AddBehaviorLogScreenState extends State<AddBehaviorLogScreen> {
  static const String _customOption = 'Iba pa (Custom)';

  final _formKey = GlobalKey<FormState>();

  // Form State Values
  String? _selectedAntecedent;
  final TextEditingController _customAntecedentController = TextEditingController();

  String? _selectedBehavior;
  final TextEditingController _customBehaviorController = TextEditingController();

  String? _selectedConsequence;
  final TextEditingController _customConsequenceController = TextEditingController();

  final List<String> _selectedSensoryTriggers = [];
  double _intensity = 3.0; // 1 to 5 (Default 3 - Moderate)
  int _durationMinutes = 10;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _customAntecedentController.dispose();
    _customBehaviorController.dispose();
    _customConsequenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveLog() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAntecedent == null) {
        _showSnackBar('Mangyaring pumili ng Antecedent (Sanhi).');
        return;
      }
      if (_selectedBehavior == null) {
        _showSnackBar('Mangyaring pumili ng Behavior (Kilos).');
        return;
      }
      if (_selectedConsequence == null) {
        _showSnackBar('Mangyaring pumili ng Consequence (Tugon).');
        return;
      }

      final finalAntecedent = _selectedAntecedent == _customOption
          ? _customAntecedentController.text.trim()
          : _selectedAntecedent!;

      final finalBehavior = _selectedBehavior == _customOption
          ? _customBehaviorController.text.trim()
          : _selectedBehavior!;

      final finalConsequence = _selectedConsequence == _customOption
          ? _customConsequenceController.text.trim()
          : _selectedConsequence!;

      final log = BehaviorLog(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        antecedent: finalAntecedent,
        behavior: finalBehavior,
        consequence: finalConsequence,
        sensoryTriggers: _selectedSensoryTriggers,
        intensity: _intensity.toInt(),
        durationMinutes: _durationMinutes,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      await HiveService.addLog(log);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Matagumpay na naitala ang Behavior Log!'),
            backgroundColor: Colors.teal,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Color _getSeverityColor(double val) {
    if (val <= 2) return Colors.green;
    if (val <= 3) return Colors.orange;
    return Colors.red;
  }

  String _getSeverityLabel(double val) {
    if (val == 1) return '1 - Bahagya (Mild)';
    if (val == 2) return '2 - Katamtaman (Mild-Moderate)';
    if (val == 3) return '3 - Moderato (Moderate)';
    if (val == 4) return '4 - Malubha (Severe)';
    return '5 - Napakamalubha (Critical Meltdown)';
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(_intensity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mag-tala ng Kilos / Insidente'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- 1. ANTECEDENT (A) ---
            _buildSectionHeader('1. Antecedent (A) - Ano ang nangyari bago ang insidente?'),
            _buildSingleSelectChips(
              options: BehaviorConstants.commonAntecedents,
              selectedOption: _selectedAntecedent,
              onSelected: (val) => setState(() => _selectedAntecedent = val),
            ),
            if (_selectedAntecedent == _customOption) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _customAntecedentController,
                decoration: const InputDecoration(
                  labelText: 'Tukuyin ang sanhi...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Mangyaring ilagay ang sanhi' : null,
              ),
            ],
            const SizedBox(height: 20),

            // --- 2. BEHAVIOR (B) ---
            _buildSectionHeader('2. Behavior (B) - Anong kilos o reaksyon ang ipinakita?'),
            _buildSingleSelectChips(
              options: BehaviorConstants.commonBehaviors,
              selectedOption: _selectedBehavior,
              onSelected: (val) => setState(() => _selectedBehavior = val),
            ),
            if (_selectedBehavior == _customOption) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _customBehaviorController,
                decoration: const InputDecoration(
                  labelText: 'Tukuyin ang kilos...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Mangyaring ilagay ang kilos' : null,
              ),
            ],
            const SizedBox(height: 20),

            // --- 3. CONSEQUENCE (C) ---
            _buildSectionHeader('3. Consequence (C) - Ano ang naging tugon o resulta?'),
            _buildSingleSelectChips(
              options: BehaviorConstants.commonConsequences,
              selectedOption: _selectedConsequence,
              onSelected: (val) => setState(() => _selectedConsequence = val),
            ),
            if (_selectedConsequence == _customOption) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _customConsequenceController,
                decoration: const InputDecoration(
                  labelText: 'Tukuyin ang tugon...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Mangyaring ilagay ang tugon' : null,
              ),
            ],
            const SizedBox(height: 20),

            // --- 4. SENSORY TRIGGERS (MULTI-SELECT) ---
            _buildSectionHeader('4. Sensory Domain Tags (Pumili ng 1 o higit pa)'),
            Wrap(
              spacing: 8.0,
              children: BehaviorConstants.sensoryCategories.map((sensory) {
                final isSelected = _selectedSensoryTriggers.contains(sensory);
                return FilterChip(
                  label: Text(sensory, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  selectedColor: Colors.teal.shade100,
                  checkmarkColor: Colors.teal.shade800,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedSensoryTriggers.add(sensory);
                      } else {
                        _selectedSensoryTriggers.remove(sensory);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // --- 5. INTENSITY SLIDER ---
            _buildSectionHeader('5. Severity / Intensity Level'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: severityColor),
              ),
              child: Column(
                children: [
                  Text(
                    _getSeverityLabel(_intensity),
                    style: TextStyle(fontWeight: FontWeight.bold, color: severityColor, fontSize: 13),
                  ),
                  Slider(
                    value: _intensity,
                    min: 1.0,
                    max: 5.0,
                    divisions: 4,
                    activeColor: severityColor,
                    onChanged: (val) => setState(() => _intensity = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- 6. DURATION & NOTES ---
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Tagal (Minutes)'),
                      DropdownButtonFormField<int>(
                        initialValue: _durationMinutes,
                        decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                        items: [5, 10, 15, 20, 30, 45, 60, 90, 120]
                            .map((m) => DropdownMenuItem(value: m, child: Text('$m mins')))
                            .toList(),
                        onChanged: (v) => setState(() => _durationMinutes = v ?? 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('Karagdagang Tala (Optional Notes)'),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Halimbawa: Pagod mula sa biyahe, hindi gaanong nakakain ng tanghalian...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),

            // SAVE BUTTON
            ElevatedButton(
              onPressed: _saveLog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('I-SAVE ANG BEHAVIOR LOG', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildSingleSelectChips({
    required List<String> options,
    required String? selectedOption,
    required Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 6.0,
      runSpacing: 4.0,
      // Idinudugtong ang custom option dito para hindi na ulitin sa bawat tawag.
      children: [...options, _customOption].map((opt) {
        final isSelected = selectedOption == opt;
        return ChoiceChip(
          label: Text(opt, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
          selected: isSelected,
          selectedColor: Colors.teal,
          onSelected: (_) => onSelected(opt),
        );
      }).toList(),
    );
  }
}