import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/assessment_session.dart';

/// Builds and shares a results summary, either as a printed/AirPrint PDF
/// or as a pre-filled email.
class ReportService {
  ReportService._();

  static String _summaryText(AssessmentSession session) {
    final a = session.assessment;
    final buffer = StringBuffer()
      ..writeln('SPPB Results')
      ..writeln('Patient: ${a.patientFirstName} ${a.patientLastName}')
      ..writeln('Date: ${a.date.toLocal()}')
      ..writeln()
      ..writeln('Balance score: ${session.balanceScore} / 4')
      ..writeln('Gait speed score: ${session.gaitScore} / 4')
      ..writeln('Chair stand score: ${session.chairStandScore} / 4')
      ..writeln('Total SPPB score: ${session.totalScore} / 12');
    return buffer.toString();
  }

  /// Opens the native print dialog (AirPrint on iOS, system print on
  /// Android) with a simple one-page results PDF.
  static Future<void> printResults(AssessmentSession session) async {
    final doc = pw.Document();
    final a = session.assessment;
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SPPB Results',
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),
              pw.Text('Patient: ${a.patientFirstName} ${a.patientLastName}'),
              pw.Text('Date: ${a.date.toLocal()}'.split('.').first),
              pw.SizedBox(height: 20),
              _scoreRow('Balance', session.balanceScore, 4),
              _scoreRow('Gait Speed', session.gaitScore, 4),
              _scoreRow('Chair Stand', session.chairStandScore, 4),
              pw.Divider(),
              _scoreRow('Total SPPB Score', session.totalScore, 12, bold: true),
            ],
          ),
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  static pw.Widget _scoreRow(String label, int score, int max, {bool bold = false}) {
    final style = pw.TextStyle(
      fontSize: bold ? 16 : 13,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text('$score / $max', style: style),
        ],
      ),
    );
  }

  /// Opens the device's email client with the results pre-filled in the
  /// body (via a mailto: link, so this works without any extra setup).
  static Future<bool> emailResults(AssessmentSession session) async {
    final a = session.assessment;
    final subject = 'SPPB Results - ${a.patientFirstName} ${a.patientLastName}';
    final uri = Uri(
      scheme: 'mailto',
      queryParameters: {
        'subject': subject,
        'body': _summaryText(session),
      },
    );
    return launchUrl(uri);
  }
}
