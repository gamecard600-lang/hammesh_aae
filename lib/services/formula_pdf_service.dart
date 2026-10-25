import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/formula.dart';

class FormulaPdfService {
  static Future<void> exportAndPrintFormulas(List<Formula> formulas) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Hammesh AAE Mechanical - Formula Handbook',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text('GSSSB AAE Exam Prep', style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            ...formulas.map((f) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(f.title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
                        pw.Text(f.subject, style: const pw.TextStyle(fontSize: 10, color: PdfColors.blue800)),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Formula: ${f.formula}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.blue900)),
                    if (f.description.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(f.description, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                    ],
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Hammesh_AAE_Mechanical_Formulas.pdf',
    );
  }
}
