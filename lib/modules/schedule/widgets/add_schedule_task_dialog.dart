import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/i18n/language_controller.dart';
import '../../../core/models/schedule_task.dart';
import '../../../core/theme/app_theme.dart';
import 'schedule_style.dart';
import 'simple_time_picker.dart';
import 'task_suggestion_list.dart';
import '../data/task_suggestions.dart';

/// Nagbabalik ng `ScheduleTask`, o `null` kapag kinansela.
///
/// Sa pag-edit, hindi ginagalaw ang `id` — naka-key doon ang bituin at ang
/// kasaysayan ng bata.
class AddScheduleTaskDialog extends StatefulWidget {
  const AddScheduleTaskDialog({super.key, this.existing});

  final ScheduleTask? existing;

  static Future<ScheduleTask?> show(
    BuildContext context, {
    ScheduleTask? existing,
  }) {
    // Bottom sheet at hindi dialog: umaapaw ang `AlertDialog` kapag umangat
    // ang keyboard — kulang ang natitirang taas para sa buong form.
    return showModalBottomSheet<ScheduleTask>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddScheduleTaskDialog(existing: existing),
    );
  }

  @override
  State<AddScheduleTaskDialog> createState() => _AddScheduleTaskDialogState();
}

class _AddScheduleTaskDialogState extends State<AddScheduleTaskDialog> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.existing?.titleTagalog ?? '',
  );
  late String _iconKey = widget.existing?.iconKey ?? ScheduleIcons.defaultKey;
  late ScheduleTimeOfDay _timeOfDay =
      widget.existing?.timeOfDay ?? ScheduleTimeOfDay.morning;
  late TimeOfDay? _exactTime = _initialExactTime();
  bool _showNameError = false;

  /// Mungkahi muna kapag bago: mas madali ang pumili kaysa mag-isip mula sa
  /// blangko. Walang mungkahi sa pag-edit — may gawain nang binabago doon.
  late bool _showingSuggestions = widget.existing == null;

  bool get _isEditing => widget.existing != null;

  TimeOfDay? _initialExactTime() {
    final minutes = widget.existing?.minuteOfDay;
    if (minutes == null) return null;
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _showNameError = true);
      return;
    }

    Navigator.pop(
      context,
      ScheduleTask(
        // Naka-key sa id ang bituin at ang natapos kada araw — hindi ito
        // pinapalitan sa pag-edit, kung hindi mabubura ang kasaysayan.
        id: widget.existing?.id ?? const Uuid().v4(),
        titleTagalog: name,
        iconKey: _iconKey,
        timeOfDay: _timeOfDay,
        starReward: widget.existing?.starReward ?? 1,
        minuteOfDay: _exactTime == null
            ? null
            : _exactTime!.hour * 60 + _exactTime!.minute,
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showSimpleTimePicker(context, _exactTime);
    if (picked != null) setState(() => _exactTime = picked);
  }

  void _addSuggestion(TaskSuggestion suggestion) =>
      Navigator.pop(context, suggestion.toTask());

  /// Ang mismong gawaing ginagawa. Dito rin kinukuha ang `timeLabel` para
  /// tiyak na pareho ang anyo ng oras sa preview at sa tunay na card.
  ScheduleTask get _preview => ScheduleTask(
    id: 'preview',
    titleTagalog: _nameController.text.trim(),
    iconKey: _iconKey,
    timeOfDay: _timeOfDay,
    minuteOfDay: _exactTime == null
        ? null
        : _exactTime!.hour * 60 + _exactTime!.minute,
  );

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _isEditing
                    ? tr('Baguhin ang Gawain', 'Edit Task')
                    : tr('Bagong Gawain', 'New Task'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 14),
              if (!_isEditing) ...[
                _buildModeTabs(),
                const SizedBox(height: 16),
              ],
              if (_showingSuggestions)
                TaskSuggestionList(onPick: _addSuggestion)
              else ...[
                _buildPreview(),
                const SizedBox(height: 18),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 30,
                  // Sumusunod ang preview sa bawat letra, kaya lahat ng palit
                  // ay kailangang mag-setState — hindi lang ang pagkakamali.
                  onChanged: (_) => setState(() => _showNameError = false),
                  decoration: InputDecoration(
                    hintText: tr(
                      'Halimbawa: Pag-iinom ng gamot',
                      'Example: Take medicine',
                    ),
                    errorText: _showNameError
                        ? tr('Kailangan ng pangalan.', 'A name is needed.')
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildLabel(tr('Kailan?', 'When?')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final time in ScheduleTimeOfDay.values)
                      _buildTimeChip(time),
                  ],
                ),
                const SizedBox(height: 18),
                _buildLabel(
                  tr('Tiyak na oras (opsyonal)', 'Exact time (optional)'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickTime,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.logoGreen,
                        side: const BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.button),
                        ),
                      ),
                      icon: const Icon(Icons.schedule_rounded, size: 18),
                      label: Text(
                        _exactTime == null
                            ? tr('Pumili ng oras', 'Pick a time')
                            : _exactTime!.format(context),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (_exactTime != null)
                      IconButton(
                        tooltip: tr('Alisin ang oras', 'Remove the time'),
                        onPressed: () => setState(() => _exactTime = null),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildLabel(tr('Pumili ng icon', 'Pick an icon')),
                const SizedBox(height: 10),
                for (final group in ScheduleIconGroup.values) ...[
                  _buildGroupLabel(group),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final key
                          in ScheduleIcons.grouped[group] ?? const [])
                        _buildIconTile(key),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        tr('Kanselahin', 'Cancel'),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.logoGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.button),
                        ),
                      ),
                      child: Text(
                        _isEditing
                            ? tr('I-save', 'Save')
                            : tr('I-dagdag', 'Add'),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                        ),
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
  }

  /// Kinokopya ang hitsura ng `ScheduleTaskCard`.
  ///
  /// Marami sa mga batang ito ang hindi pa nakakabasa — ang icon at ang kulay
  /// ang buong mensahe para sa kanila. Dapat nakikita ng magulang kung ano ang
  /// ginagawa niya bago pa ito i-save.
  Widget _buildPreview() {
    final task = _preview;
    final style = ScheduleTimeStyle.of(_timeOfDay);
    final hasName = task.titleTagalog.isNotEmpty;

    return Center(
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: style.fill,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                ScheduleIcons.of(_iconKey),
                size: 29,
                color: style.accent,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              hasName ? task.title : tr('Pangalan ng gawain', 'Task name'),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.2,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
                color: hasName ? AppColors.textDark : AppColors.textMuted,
              ),
            ),
            if (task.timeLabel.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                task.timeLabel,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Dalawang paraan ng pagdagdag. Hindi lumalabas sa pag-edit — may gawain
  /// nang binabago doon, at walang mapapalitan ang mungkahi.
  Widget _buildModeTabs() {
    return Row(
      children: [
        _buildModeTab(
          label: tr('Mungkahi', 'Suggestions'),
          icon: Icons.lightbulb_outline_rounded,
          isActive: _showingSuggestions,
          onTap: () => setState(() => _showingSuggestions = true),
        ),
        const SizedBox(width: 10),
        _buildModeTab(
          label: tr('Sarili kong gawain', 'My own task'),
          icon: Icons.edit_rounded,
          isActive: !_showingSuggestions,
          onTap: () => setState(() => _showingSuggestions = false),
        ),
      ],
    );
  }

  Widget _buildModeTab({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isActive ? AppColors.logoGreen : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(
              color: isActive ? AppColors.logoGreen : AppColors.divider,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? AppColors.surface : AppColors.textMuted,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                    color: isActive ? AppColors.surface : AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        fontFamily: 'Nunito',
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildGroupLabel(ScheduleIconGroup group) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: group.ink, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          group.label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
            fontFamily: 'Nunito',
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeChip(ScheduleTimeOfDay time) {
    final style = ScheduleTimeStyle.of(time);
    final isSelected = _timeOfDay == time;

    return GestureDetector(
      onTap: () => setState(() => _timeOfDay = time),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? style.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(
            color: isSelected ? style.accent : AppColors.divider,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              style.icon,
              size: 15,
              color: isSelected ? AppColors.surface : style.accent,
            ),
            const SizedBox(width: 5),
            Text(
              time.displayLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
                color: isSelected ? AppColors.surface : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconTile(String key) {
    final isSelected = _iconKey == key;
    final style = ScheduleTimeStyle.of(_timeOfDay);

    return Semantics(
      selected: isSelected,
      child: GestureDetector(
        onTap: () => setState(() => _iconKey = key),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            // Kulay ng napiling bahagi ng araw kapag pinili — iyon din ang
            // kulay na makikita ng bata sa card.
            color: isSelected ? style.fill : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? style.accent : AppColors.divider,
              width: 2,
            ),
          ),
          child: Icon(
            ScheduleIcons.of(key),
            size: 22,
            color: ScheduleIcons.inkOf(key),
          ),
        ),
      ),
    );
  }
}
