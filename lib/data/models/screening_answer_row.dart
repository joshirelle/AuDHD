import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/services/mchat_scoring.dart';
import '../../core/services/vanderbilt_scoring.dart';
import 'adhd_question.dart';
import 'mchat_question.dart';
import 'screening_result.dart';

/// Pinagsanib na anyo ng isang sagot para iisa lang ang pinagmumulan ng screen at ng PDF.
class ScreeningAnswerRow {
  static const List<String> _adhdLabels = [
    'Kailanman',
    'Minsan',
    'Madalas',
    'Palagi',
  ];

  final int number;
  final String text;
  final String answerLabel;
  final bool isAtRisk;

  ScreeningAnswerRow({
    required this.number,
    required this.text,
    required this.answerLabel,
    required this.isAtRisk,
  });

  static Future<List<ScreeningAnswerRow>> buildFor(ScreeningResult result) async {
    final bool isAdhd = result.type == ScreeningResult.typeADHD;
    final String asset = isAdhd
        ? 'assets/json/vanderbilt_questions.json'
        : 'assets/json/mchat_questions.json';
    final List<dynamic> data = json.decode(await rootBundle.loadString(asset));

    // Hindi maaasahan ang pagkakasunod-sunod ng keys mula sa Hive.
    final rows = isAdhd ? _buildADHD(data, result) : _buildMChat(data, result);
    rows.sort((a, b) => a.number.compareTo(b.number));
    return rows;
  }

  static List<ScreeningAnswerRow> _buildMChat(
    List<dynamic> data,
    ScreeningResult result,
  ) {
    final byId = {
      for (final item in data)
        item['id'] as String: MChatQuestion.fromJson(
          item as Map<String, dynamic>,
        ),
    };
    return [
      for (final entry in result.answers.entries)
        ScreeningAnswerRow(
          number: byId[entry.key]?.questionNumber ?? 0,
          text: byId[entry.key]?.textTagalog ?? 'Tanong ${entry.key}',
          answerLabel: entry.value == true ? 'OO' : 'HINDI',
          // Sa items 2, 5 at 12 ang "OO" ang at-risk na sagot, kaya hindi sapat ang oo/hindi bilang batayan.
          isAtRisk:
              byId[entry.key] != null &&
              MChatScoring.isAtRisk(byId[entry.key]!, entry.value),
        ),
    ];
  }

  static List<ScreeningAnswerRow> _buildADHD(
    List<dynamic> data,
    ScreeningResult result,
  ) {
    final byId = {
      for (final item in data)
        item['id'] as String: ADHDQuestion.fromJson(
          item as Map<String, dynamic>,
        ),
    };
    return [
      for (final entry in result.answers.entries)
        ScreeningAnswerRow(
          number: byId[entry.key]?.number ?? 0,
          text: byId[entry.key]?.textTagalog ?? 'Tanong ${entry.key}',
          answerLabel: _adhdLabels[(entry.value as int).clamp(0, 3)],
          // Sa Vanderbilt, "Madalas" (2) pataas lang ang binibilang na sintomas.
          isAtRisk:
              (entry.value as int) >= VanderbiltScoring.symptomThreshold,
        ),
    ];
  }
}
