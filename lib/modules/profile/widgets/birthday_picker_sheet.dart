import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/age_formatter.dart';
import '../../../core/utils/date_formatter.dart';

/// Pagpili ng kaarawan sa tatlong gulong: taon, buwan, araw.
///
/// Hindi ginagamit ang `showDatePicker`: kalendaryo iyon na bumubukas sa
/// kasalukuyang buwan, kaya kailangang bumalik nang buwan-buwan ang magulang
/// ng batang apat na taon. Dito, isang kaway kada hanay at kasya ang lahat sa
/// isang tingin — walang scroll na pahina at walang pader ng chip.
Future<DateTime?> showBirthdayPicker(BuildContext context, DateTime? initial) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    // Kulang ang default na 9/16 ng screen para sa tatlong gulong at sa
    // footer — pumuputol ito sa iPhone SE.
    isScrollControlled: true,
    builder: (context) => _BirthdayPickerSheet(initial: initial),
  );
}

class _BirthdayPickerSheet extends StatefulWidget {
  const _BirthdayPickerSheet({this.initial});

  final DateTime? initial;

  @override
  State<_BirthdayPickerSheet> createState() => _BirthdayPickerSheetState();
}

class _BirthdayPickerSheetState extends State<_BirthdayPickerSheet> {
  static const List<String> _monthsFil = [
    'Ene',
    'Peb',
    'Mar',
    'Abr',
    'May',
    'Hun',
    'Hul',
    'Ago',
    'Set',
    'Okt',
    'Nob',
    'Dis',
  ];

  static const List<String> _monthsEng = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const double _itemExtent = 46;

  final DateTime _now = DateTime.now();

  late final int _firstYear = _now.year - 18;
  late final List<int> _years = [
    for (var y = _firstYear; y <= _now.year; y++) y,
  ];

  late int _year;
  late int _month;
  late int _day;

  late final FixedExtentScrollController _yearController;
  late final FixedExtentScrollController _monthController;
  late final FixedExtentScrollController _dayController;

  @override
  void initState() {
    super.initState();
    // Dalawang taon ang nakalipas kapag wala pang napili: ang karaniwang
    // gumagamit nito ay may batang wala pang eskwela.
    final start =
        widget.initial ?? DateTime(_now.year - 2, _now.month, _now.day);
    _year = start.year.clamp(_firstYear, _now.year);
    _month = start.month;
    _day = start.day;

    _yearController = FixedExtentScrollController(
      initialItem: _years.indexOf(_year),
    );
    _monthController = FixedExtentScrollController(initialItem: _month - 1);
    _dayController = FixedExtentScrollController(initialItem: _day - 1);
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  /// Ang `0` na araw ng susunod na buwan ay ang huli nito, kaya walang
  /// talahanayan ng Pebrero at tama ang leap year nang libre.
  int get _daysInMonth => DateTime(_year, _month + 1, 0).day;

  DateTime get _value => DateTime(_year, _month, _day);

  bool get _isFuture => _value.isAfter(_now);

  /// Ang Marso 31 na naging Pebrero ay walang araw na 31.
  void _clampDay() {
    final last = _daysInMonth;
    if (_day <= last) return;
    _day = last;
    _dayController.jumpToItem(last - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        // Umaabot pa rin sa mababang screen, hal. SE na naka-landscape.
        child: SingleChildScrollView(
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
                tr('Kailan siya ipinanganak?', 'When were they born?'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                tr('Igalaw ang bawat hanay.', 'Spin each column.'),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 14),
              _buildWheels(),
              const SizedBox(height: 16),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWheels() {
    return SizedBox(
      height: _itemExtent * 4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ang napili ay ang nasa gitna. Nasa likod ito ng mga numero para
          // hindi matakpan ang teksto.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: _itemExtent,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  border: Border.all(color: AppColors.logoGreen, width: 2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildWheel(
                    controller: _yearController,
                    count: _years.length,
                    labelAt: (index) => '${_years[index]}',
                    isSelected: (index) => _years[index] == _year,
                    onChanged: (index) => setState(() {
                      _year = _years[index];
                      _clampDay();
                    }),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _buildWheel(
                    controller: _monthController,
                    count: 12,
                    labelAt: (index) => LanguageController.isEnglish
                        ? _monthsEng[index]
                        : _monthsFil[index],
                    isSelected: (index) => index + 1 == _month,
                    onChanged: (index) => setState(() {
                      _month = index + 1;
                      _clampDay();
                    }),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _buildWheel(
                    controller: _dayController,
                    count: _daysInMonth,
                    labelAt: (index) => '${index + 1}',
                    isSelected: (index) => index + 1 == _day,
                    onChanged: (index) => setState(() => _day = index + 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int count,
    required String Function(int index) labelAt,
    required bool Function(int index) isSelected,
    required ValueChanged<int> onChanged,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: _itemExtent,
      // Halos patag: ang malakas na kurba ay nagpapahirap basahin ang gilid.
      perspective: 0.002,
      diameterRatio: 1.8,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: count,
        builder: (context, index) {
          final selected = isSelected(index);
          return Center(
            child: Text(
              labelAt(index),
              style: TextStyle(
                fontSize: selected ? 19 : 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
                color: selected ? AppColors.textDark : AppColors.textMuted,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    final isFuture = _isFuture;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isFuture
                ? tr(
                    'Hindi pa dumarating ang petsang ito.',
                    'That date has not happened yet.',
                  )
                : '${DateFormatter.longDate(_value)}  \u00b7  '
                      '${AgeFormatter.formatAge(_value, _now)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
              color: isFuture ? AppColors.danger : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    tr('Kanselahin', 'Cancel'),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: isFuture
                      ? null
                      : () => Navigator.pop(context, _value),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.logoGreen,
                    disabledBackgroundColor: AppColors.divider,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  child: Text(
                    tr('Piliin', 'Choose'),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
