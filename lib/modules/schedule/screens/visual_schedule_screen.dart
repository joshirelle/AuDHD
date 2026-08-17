import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/models/schedule_task.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/how_to_card.dart';
import '../../home/widgets/star_badge_widget.dart';
import '../widgets/add_schedule_task_dialog.dart';
import '../widgets/schedule_style.dart';
import '../widgets/schedule_task_card.dart';

class VisualScheduleScreen extends StatefulWidget {
  const VisualScheduleScreen({super.key});

  @override
  State<VisualScheduleScreen> createState() => _VisualScheduleScreenState();
}

class _VisualScheduleScreenState extends State<VisualScheduleScreen>
    with WidgetsBindingObserver {
  /// `null` ang ibig sabihin ay "Lahat".
  ScheduleTimeOfDay? _filter;

  late DateTime _today;
  late final Listenable _sources;

  @override
  void initState() {
    super.initState();
    _today = _dateOnly(DateTime.now());
    _sources = Listenable.merge([
      HiveService.getScheduleBox().listenable(),
      HiveService.getScheduleDoneBox().listenable(),
    ]);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Kusang blangko ang bagong araw dahil naka-index sa petsa ang pagkatapos,
  /// pero luma pa rin ang `_today` kung naiwang bukas ang app lampas hatinggabi.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final now = _dateOnly(DateTime.now());
    if (now != _today) setState(() => _today = now);
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<void> _addTask() async {
    final task = await AddScheduleTaskDialog.show(context);
    if (task == null) return;

    await HiveService.addScheduleTask(task);
    // Kung nakatago ito ng kasalukuyang filter, mukhang walang nangyari.
    if (mounted && _filter != null && _filter != task.timeOfDay) {
      setState(() => _filter = task.timeOfDay);
    }
  }

  Future<void> _confirmDelete(ScheduleTask task) async {
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: const Text(
          'Burahin ang gawain?',
          style: TextStyle(fontSize: 17, fontFamily: 'Nunito'),
        ),
        content: Text(
          'Aalisin sa iskedyul ang "${task.titleTagalog}".',
          style: const TextStyle(fontSize: 14, fontFamily: 'Nunito'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Hindi',
              style: TextStyle(fontFamily: 'Nunito', color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Burahin',
              style: TextStyle(fontFamily: 'Nunito', color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (isConfirmed != true) return;
    // Hindi binabawi ang mga bituing kinita na ng bata sa gawaing ito.
    await HiveService.deleteScheduleTask(task.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Aking Iskedyul'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: StarBadgeWidget()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        backgroundColor: AppColors.logoGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Gawain',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
        ),
      ),
      body: ListenableBuilder(
        listenable: _sources,
        builder: (context, _) => _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final tasks = HiveService.getScheduleTasks();
    final visible = _filter == null
        ? tasks
        : tasks.where((task) => task.timeOfDay == _filter).toList();
    final doneCount = HiveService.countScheduleDoneOn(
      _today,
      visible.map((task) => task.id).toList(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: HowToCard(
            steps: [
              'Pindutin ang "Gawain" para magdagdag, kasama ang larawan at ang '
                  'oras ng araw kung kailan ito ginagawa.',
              'Ipakita ang iskedyul sa bata sa umpisa ng araw para malaman '
                  'niya kung ano ang susunod na mangyayari.',
              'Hayaan siyang mag-tsek ng natapos. Siya ang dapat pumindot, '
                  'hindi ikaw.',
            ],
            footnote:
                'Kusang nagre-reset ang tsek tuwing bagong araw, pero '
                'nananatili ang listahan ng gawain.',
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: _buildFilters(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: _buildProgress(doneCount, visible.length),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
            // Nakapirming taas para hindi umapaw ang tile sa makikitid na screen.
            gridDelegate:
                const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 128,
                  mainAxisExtent: 136,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
            itemCount: visible.length,
            itemBuilder: (context, index) {
              final task = visible[index];
              return ScheduleTaskCard(
                task: task,
                date: _today,
                isDone: HiveService.isScheduleTaskDone(_today, task.id),
                onChanged: () => setState(() {}),
                onDelete: HiveService.isCustomScheduleTask(task.id)
                    ? () => _confirmDelete(task)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(int doneCount, int totalCount) {
    final ratio = totalCount == 0 ? 0.0 : doneCount / totalCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$doneCount sa $totalCount na gawain ang tapos ngayong araw',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation(AppColors.logoGreen),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            'Lahat',
            null,
            Icons.apps_rounded,
            AppColors.logoGreen,
          ),
          for (final time in ScheduleTimeOfDay.values) ...[
            const SizedBox(width: 8),
            _buildFilterChip(
              time.label,
              time,
              ScheduleTimeStyle.of(time).icon,
              ScheduleTimeStyle.of(time).accent,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    ScheduleTimeOfDay? time,
    IconData icon,
    Color color,
  ) {
    final isSelected = _filter == time;

    return GestureDetector(
      onTap: () => setState(() => _filter = time),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
