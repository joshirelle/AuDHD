import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/i18n/language_controller.dart';
import '../../../core/services/pdf_report_theme.dart';
import '../../../core/services/vanderbilt_scoring.dart';
import '../../../data/models/adhd_question.dart';
import '../../../data/models/screening_result.dart';

/// Nakabinbin habang hinihintay ang pahintulot sa M-CHAT-R at NICHQ Vanderbilt.
/// Walang tumatawag dito sa ngayon; ibalik sa `DoctorPdfService` kapag naaprubahan
/// na ang lisensya, at ayusin ang bilang ng seksyon ayon sa bagong ayos ng ulat.
class ScreeningPdfSections {
  static List<pw.Widget> mchatSection(ScreeningResult? result) {
    final title = tr(
      '1. Screening para sa Autism (M-CHAT-R)',
      '1. Autism Screening (M-CHAT-R)',
    );

    if (result == null) {
      return [
        PdfReportTheme.sectionTitle(title),
        pw.SizedBox(height: 8),
        _emptyNote(
          tr(
            'Wala pang naitalang M-CHAT-R screening.',
            'No M-CHAT-R screening recorded yet.',
          ),
        ),
      ];
    }

    final isHighRisk = result.riskLevel.contains('HIGH');

    return [
      PdfReportTheme.sectionTitle(
        title,
        subtitle: tr(
          'Pinakahuling resulta noong '
              '${PdfReportTheme.formatDate(result.date)}.',
          'Latest result on ${PdfReportTheme.formatDate(result.date)}.',
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: isHighRisk ? PdfColors.red50 : PdfColors.green50,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(
            color: isHighRisk ? PdfColors.red400 : PdfColors.green400,
          ),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  tr('Kategorya ng panganib', 'Risk category'),
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  result.riskLevel,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: isHighRisk ? PdfColors.red800 : PdfColors.green800,
                  ),
                ),
              ],
            ),
            pw.Text(
              tr('Puntos: ${result.score}', 'Score: ${result.score}'),
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    ];
  }

  static List<pw.Widget> vanderbiltSection(
    ScreeningResult? result,
    List<ADHDQuestion> questions,
  ) {
    final title = tr(
      '2. Screening para sa ADHD (Vanderbilt)',
      '2. ADHD Screening (Vanderbilt)',
    );

    if (result == null || questions.isEmpty) {
      return [
        PdfReportTheme.sectionTitle(title),
        pw.SizedBox(height: 8),
        _emptyNote(
          tr(
            'Wala pang naitalang Vanderbilt ADHD screening.',
            'No Vanderbilt ADHD screening recorded yet.',
          ),
        ),
      ];
    }

    final inattention = VanderbiltScoring.symptomCount(
      questions,
      result.answers,
      VanderbiltScoring.categoryInattention,
    );
    final hyperactivity = VanderbiltScoring.symptomCount(
      questions,
      result.answers,
      VanderbiltScoring.categoryHyperactivity,
    );
    final inattentionTotal = VanderbiltScoring.totalIn(
      questions,
      VanderbiltScoring.categoryInattention,
    );
    final hyperactivityTotal = VanderbiltScoring.totalIn(
      questions,
      VanderbiltScoring.categoryHyperactivity,
    );
    final isHighRisk = VanderbiltScoring.isHighRisk(inattention, hyperactivity);

    final impression = isHighRisk
        ? tr(
            '${result.riskLevel} - umabot sa ${VanderbiltScoring.riskThreshold}+ '
                'na sintomas ang isa o parehong subscale.',
            '${result.riskLevel} - one or both subscales reached '
                '${VanderbiltScoring.riskThreshold}+ symptoms.',
          )
        : tr(
            '${result.riskLevel} - hindi umabot sa ${VanderbiltScoring.riskThreshold} '
                'na sintomas ang alinmang subscale.',
            '${result.riskLevel} - neither subscale reached '
                '${VanderbiltScoring.riskThreshold} symptoms.',
          );

    return [
      PdfReportTheme.sectionTitle(
        title,
        subtitle: tr(
          'Pinakahuling resulta noong ${PdfReportTheme.formatDate(result.date)}. '
              'Binibilang lamang ang "Madalas" at "Palagi" bilang sintomas.',
          'Latest result on ${PdfReportTheme.formatDate(result.date)}. '
              'Only "Often" and "Always" are counted as symptoms.',
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: isHighRisk ? PdfColors.red50 : PdfColors.green50,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(
            color: isHighRisk ? PdfColors.red400 : PdfColors.green400,
          ),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Inattention: $inattention / $inattentionTotal',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Hyperactivity: $hyperactivity / $hyperactivityTotal',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              tr('Impresyon: $impression', 'Impression: $impression'),
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: isHighRisk ? PdfColors.red800 : PdfColors.green800,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  static pw.Widget _emptyNote(String message) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Text(
        message,
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
      ),
    );
  }
}
