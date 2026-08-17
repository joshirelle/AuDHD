import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/behavior_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/behavior_log.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/step_progress_header.dart';

class AddBehaviorLogScreen extends StatefulWidget {
  const AddBehaviorLogScreen({super.key});

  @override
  State<AddBehaviorLogScreen> createState() => _AddBehaviorLogScreenState();
}

class _AddBehaviorLogScreenState extends State<AddBehaviorLogScreen> {
  static const String _customOption = 'Iba pa (Custom)';
  static const int _totalSteps = 7;

  int _currentStep = 0;

  String? _selectedAntecedent;
  final TextEditingController _customAntecedentController =
      TextEditingController();

  String? _selectedBehavior;
  final TextEditingController _customBehaviorController =
      TextEditingController();

  String? _selectedConsequence;
  final TextEditingController _customConsequenceController =
      TextEditingController();

  final List<String> _selectedSensoryTriggers = [];
  double _intensity = 3.0;
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

  static const List<String> _stepTags = [
    'ANTECEDENT (A)',
    'BEHAVIOR (B)',
    'CONSEQUENCE (C)',
    'SENSORY DOMAIN TAGS',
    'SEVERITY / INTENSITY',
    'TAGAL',
    'KARAGDAGANG TALA',
  ];

  static const List<IconData> _stepIcons = [
    Icons.history_rounded,
    Icons.directions_run_rounded,
    Icons.reply_rounded,
    Icons.sensors_rounded,
    Icons.speed_rounded,
    Icons.timer_rounded,
    Icons.edit_note_rounded,
  ];

  static const List<Color> _stepColors = [
    AppColors.skyBlue,
    AppColors.coralPeach,
    AppColors.mintGreen,
    AppColors.butterYellow,
    AppColors.coralPeach,
    AppColors.skyBlueLight,
    AppColors.mintGreen,
  ];

  static const List<String> _stepQuestions = [
    'Ano ang nangyari bago ang insidente?',
    'Anong kilos o reaksyon ang ipinakita?',
    'Ano ang naging tugon o resulta?',
    'Ano ang maaaring pumukaw sa kanya?',
    'Gaano kalubha ang naging insidente?',
    'Gaano ito katagal?',
    'May nais ka pa bang idagdag?',
  ];

  /// Hindi puwedeng lumipat hangga't kulang ang A, B, o C.
  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _isChoiceComplete(
          _selectedAntecedent,
          _customAntecedentController,
        );
      case 1:
        return _isChoiceComplete(_selectedBehavior, _customBehaviorController);
      case 2:
        return _isChoiceComplete(
          _selectedConsequence,
          _customConsequenceController,
        );
      default:
        return true;
    }
  }

  bool _isChoiceComplete(String? selected, TextEditingController controller) {
    if (selected == null) return false;
    if (selected == _customOption) return controller.text.trim().isNotEmpty;
    return true;
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  void _goNext() {
    if (!_canProceed) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _saveLog();
    }
  }

  String _resolve(String? selected, TextEditingController controller) {
    return selected == _customOption ? controller.text.trim() : selected!;
  }

  Future<void> _saveLog() async {
    final log = BehaviorLog(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      antecedent: _resolve(_selectedAntecedent, _customAntecedentController),
      behavior: _resolve(_selectedBehavior, _customBehaviorController),
      consequence: _resolve(_selectedConsequence, _customConsequenceController),
      sensoryTriggers: _selectedSensoryTriggers,
      intensity: _intensity.toInt(),
      durationMinutes: _durationMinutes,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    await HiveService.addLog(log);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Matagumpay na naitala ang Behavior Log!'),
        backgroundColor: AppColors.logoGreen,
      ),
    );
    Navigator.pop(context);
  }

  // Kapareho ng risk colours na ginagamit sa screening result at history.
  Color _getSeverityColor(double val) {
    if (val <= 2) return AppColors.success;
    if (val <= 3) return AppColors.warning;
    return AppColors.danger;
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
    final bool isLastStep = _currentStep == _totalSteps - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StepProgressHeader(
                currentIndex: _currentStep,
                totalCount: _totalSteps,
                onBack: _goBack,
              ),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  'HAKBANG ${_currentStep + 1}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.0,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Ang scroll view ang umaabot sa ibaba, hindi ang card, kaya
              // hindi naghihiwa ang gilid nito sa huling chip.
              Expanded(
                child: SingleChildScrollView(child: _buildStepCard()),
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _canProceed ? _goNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.logoGreen,
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    isLastStep ? 'I-SAVE ANG BEHAVIOR LOG' : 'SUSUNOD',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _canProceed ? Colors.white : Colors.grey.shade600,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.skyBlueLight, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _buildStepChip(),
          ),
          const SizedBox(height: 18),
          Text(
            _stepQuestions[_currentStep],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.35,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 20),
          _buildStepInput(),
        ],
      ),
    );
  }

  Widget _buildStepChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _stepColors[_currentStep],
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_stepIcons[_currentStep], size: 18, color: AppColors.textDark),
          const SizedBox(width: 6),
          Text(
            _stepTags[_currentStep],
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepInput() {
    switch (_currentStep) {
      case 0:
        return _buildChoiceStep(
          options: BehaviorConstants.commonAntecedents,
          selected: _selectedAntecedent,
          controller: _customAntecedentController,
          hint: 'Tukuyin ang sanhi...',
          onSelected: (val) => setState(() => _selectedAntecedent = val),
        );
      case 1:
        return _buildChoiceStep(
          options: BehaviorConstants.commonBehaviors,
          selected: _selectedBehavior,
          controller: _customBehaviorController,
          hint: 'Tukuyin ang kilos...',
          onSelected: (val) => setState(() => _selectedBehavior = val),
        );
      case 2:
        return _buildChoiceStep(
          options: BehaviorConstants.commonConsequences,
          selected: _selectedConsequence,
          controller: _customConsequenceController,
          hint: 'Tukuyin ang tugon...',
          onSelected: (val) => setState(() => _selectedConsequence = val),
        );
      case 3:
        return _buildSensoryStep();
      case 4:
        return _buildIntensityStep();
      case 5:
        return _buildDurationStep();
      default:
        return _buildNotesStep();
    }
  }

  Widget _buildChoiceStep({
    required List<String> options,
    required String? selected,
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.0,
          runSpacing: 8.0,
          // Idinudugtong ang custom option dito para hindi na ulitin sa bawat tawag.
          children: [...options, _customOption].map((opt) {
            final isSelected = selected == opt;
            return ChoiceChip(
              label: Text(
                opt,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? Colors.white : AppColors.textDark,
                ),
              ),
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 4,
              ),
              selected: isSelected,
              selectedColor: AppColors.logoGreen,
              shape: const StadiumBorder(
                side: BorderSide(color: AppColors.mintGreen),
              ),
              onSelected: (_) => onSelected(opt),
            );
          }).toList(),
        ),
        if (selected == _customOption) ...[
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: hint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSensoryStep() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      runSpacing: 8.0,
      children: BehaviorConstants.sensoryCategories.map((sensory) {
        final isSelected = _selectedSensoryTriggers.contains(sensory);
        return FilterChip(
          label: Text(sensory, style: const TextStyle(fontSize: 13)),
          labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          selected: isSelected,
          selectedColor: AppColors.mintGreen,
          checkmarkColor: AppColors.mintInk,
          shape: const StadiumBorder(
            side: BorderSide(color: AppColors.mintGreen),
          ),
          onSelected: (selected) {
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
    );
  }

  Widget _buildIntensityStep() {
    final severityColor = _getSeverityColor(_intensity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: severityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: severityColor, width: 2),
      ),
      child: Column(
        children: [
          Text(
            _getSeverityLabel(_intensity),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: severityColor,
              fontSize: 15,
              fontFamily: 'Nunito',
            ),
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
    );
  }

  Widget _buildDurationStep() {
    return DropdownButtonFormField<int>(
      initialValue: _durationMinutes,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: [5, 10, 15, 20, 30, 45, 60, 90, 120]
          .map((m) => DropdownMenuItem(value: m, child: Text('$m mins')))
          .toList(),
      onChanged: (v) => setState(() => _durationMinutes = v ?? 10),
    );
  }

  Widget _buildNotesStep() {
    return TextField(
      controller: _notesController,
      maxLines: 4,
      decoration: const InputDecoration(
        hintText:
            'Halimbawa: Pagod mula sa biyahe, hindi gaanong nakakain ng tanghalian...',
        border: OutlineInputBorder(),
      ),
    );
  }
}
