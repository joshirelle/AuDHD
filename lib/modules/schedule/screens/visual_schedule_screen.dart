import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/models/schedule_task.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/how_to_card.dart';
import '../../../widgets/kiko_card.dart';
import '../../../widgets/star_burst_overlay.dart';
import '../../../widgets/weekly_date_strip.dart';
import '../../home/widgets/home_tour_guide.dart';
import '../../home/widgets/star_badge_widget.dart';
import '../widgets/add_schedule_task_dialog.dart';
import '../widgets/schedule_style.dart';
import '../widgets/schedule_task_card.dart';
import 'arrange_schedule_screen.dart';

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
  late DateTime _selectedDate;
  late final Listenable _sources;

  final GlobalKey _arrangeKey = GlobalKey();
  final GlobalKey _dateStripKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _today = _dateOnly(DateTime.now());
    _selectedDate = _today;
    _sources = Listenable.merge([
      HiveService.getScheduleBox().listenable(),
      HiveService.getScheduleDoneBox().listenable(),
      HiveService.getScheduleOrderBox().listenable(),
      HiveService.getScheduleHiddenBox().listenable(),
    ]);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTour());
  }

  void _startTour() {
    if (!mounted) return;
    HomeTourGuide.showIfNeeded(
      context,
      [
        TourStep(
          targetKey: _dateStripKey,
          title: 'Balikan ang nakaraan',
          body:
              'Pindutin ang ibang araw para makita kung ano ang natapos noon. '
              'Naka-tala ang bawat araw, hindi lang ang ngayon.',
        ),
        TourStep(
          targetKey: _arrangeKey,
          title: 'Ayusin ang iskedyul',
          body:
              'Dito mo mababago ang pagkakasunod-sunod, maitatago ang gawaing '
              'hindi ninyo ginagawa, at makikita ang oras ng bawat isa.',
        ),
      ],
      seenKey: HiveService.hasSeenScheduleTourKey,
    );
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
    if (now == _today) return;

    setState(() {
      // Huwag hilahin pabalik sa ngayon ang magulang na tumitingin ng nakaraan.
      final wasOnToday = _selectedDate == _today;
      _today = now;
      if (wasOnToday) _selectedDate = now;
    });
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

  /// Hindi diretsong pagbura: ang maling napiling "Kailan?" ay dapat naitatama,
  /// hindi nagiging dahilan para mawala ang gawain at ang bituin nito.
  Future<void> _showTaskOptions(ScheduleTask task) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              task.titleTagalog,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(
                Icons.edit_rounded,
                color: AppColors.logoGreen,
              ),
              title: const Text(
                'Baguhin',
                style: TextStyle(fontFamily: 'Nunito', fontSize: 15),
              ),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
              ),
              title: const Text(
                'Burahin',
                style: TextStyle(fontFamily: 'Nunito', fontSize: 15),
              ),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (!mounted) return;
    if (action == 'edit') await _editTask(task);
    if (action == 'delete') await _confirmDelete(task);
  }

  Future<void> _editTask(ScheduleTask task) async {
    final updated = await AddScheduleTaskDialog.show(context, existing: task);
    if (updated == null) return;

    // Ang lumang posisyon ay para sa dating bahagi ng araw; kapag lumipat ito,
    // mas mabuting bumalik sa likas na pwesto kaysa mapunta sa gitna.
    if (updated.timeOfDay != task.timeOfDay) {
      await HiveService.getScheduleOrderBox().delete(task.id);
    }
    await HiveService.addScheduleTask(updated);
  }

  Future<void> _confirmDelete(ScheduleTask task) async {
    final history = HiveService.scheduleHistoryFor(task.id);
    final childName = HiveService.getChildProfile()?.displayName;

    final action = await showDialog<String>(
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
          'Aalisin sa iskedyul ang "${task.titleTagalog}".'
          '${history.days == 0 ? '' : '\n\nMay ${history.days} araw na natapos '
              'dito. Mababawasan ng ${history.stars} ang bituin '
              '${childName == null ? 'ng bata' : 'ni $childName'}.'
              '\n\nKung ayaw mong mabawasan, itago na lang ito.'}',
          style: const TextStyle(fontSize: 14, fontFamily: 'Nunito'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hindi',
              style: TextStyle(fontFamily: 'Nunito', color: Colors.grey),
            ),
          ),
          if (history.days > 0)
            TextButton(
              onPressed: () => Navigator.pop(context, 'hide'),
              child: const Text(
                'Itago',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: AppColors.logoGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'delete'),
            child: const Text(
              'Burahin',
              style: TextStyle(fontFamily: 'Nunito', color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (action == 'hide') {
      await HiveService.setScheduleTaskHidden(task.id, true);
    } else if (action == 'delete') {
      await HiveService.deleteScheduleTask(task.id);
    }
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
        actions: [
          IconButton(
            key: _arrangeKey,
            tooltip: 'Ayusin ang iskedyul',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ArrangeScheduleScreen(),
              ),
            ),
            icon: const Icon(Icons.tune_rounded),
          ),
          const Padding(
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
      _selectedDate,
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
              'Pindutin nang matagal ang gawaing ikaw ang nagdagdag para '
                  'baguhin o burahin ito.',
            ],
            footnote:
                'Kusang nagre-reset ang tsek tuwing bagong araw, pero '
                'nananatili ang listahan ng gawain.',
          ),
        ),
        Padding(
          key: _dateStripKey,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: WeeklyDateStrip(
            selectedDate: _selectedDate,
            onDateSelected: (date) => setState(() => _selectedDate = date),
            progressSource: HiveService.getScheduleDoneBox().listenable(),
            hasProgress: HiveService.hasAnyScheduleDoneOn,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _buildNextUp(visible, doneCount),
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
                date: _selectedDate,
                isDone: HiveService.isScheduleTaskDone(_selectedDate, task.id),
                onChanged: () => setState(() {}),
                onOptions: HiveService.isCustomScheduleTask(task.id)
                    ? () => _showTaskOptions(task)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Ang pangunahing silbi ng visual schedule sa bata ay iisang sagot: ano ang
  /// susunod. Walang susunod sa araw na lumipas, kaya buod ang ipinapakita doon.
  Widget _buildNextUp(List<ScheduleTask> visible, int doneCount) {
    if (_selectedDate != _today) {
      return _buildPastDayNote(visible.length, doneCount);
    }

    final pending =
        visible
            .where((t) => !HiveService.isScheduleTaskDone(_selectedDate, t.id))
            .toList()
          ..sort((a, b) => a.timeOfDay.index.compareTo(b.timeOfDay.index));

    if (pending.isEmpty) return _buildAllDoneNote(visible.isEmpty);
    return _buildNextTaskCard(pending.first);
  }

  Widget _buildNextTaskCard(ScheduleTask task) {
    final style = ScheduleTimeStyle.of(task.timeOfDay);

    return KikoCard(
      backgroundColor: style.fill,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              ScheduleIcons.of(task.iconKey),
              color: style.accent,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SUSUNOD',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: AppColors.textMuted,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.titleTagalog,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
                Text(
                  task.timeOfDay.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: style.accent,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _markDone(task),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.logoGreen,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            child: const Text(
              'Tapos!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markDone(ScheduleTask task) async {
    await HiveService.setScheduleTaskDone(_selectedDate, task, true);
    if (!mounted) return;
    StarBurstOverlay.show(context, task.starReward);
    setState(() {});
  }

  Widget _buildAllDoneNote(bool isEmptySchedule) {
    return KikoCard(
      backgroundColor: AppColors.tintSuccess,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEmptySchedule
                  ? 'Wala pang gawain sa bahaging ito.'
                  : 'Tapos na ang buong iskedyul ngayong araw!',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastDayNote(int totalCount, int doneCount) {
    return KikoCard(
      backgroundColor: AppColors.tintWarm,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, color: AppColors.warning, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tinitingnan mo ang ${DateFormatter.longDate(_selectedDate)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
                Text(
                  '$doneCount sa $totalCount ang natapos noon.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _selectedDate = _today),
            style: TextButton.styleFrom(foregroundColor: AppColors.logoGreen),
            child: const Text(
              'Bumalik',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
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
