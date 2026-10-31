// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  test('Extract Blueprint PDF Text', () {
    final pdfFile = File(r'C:\Users\hamme\Downloads\Hammesh AAE - Final Master Blueprint & Syllabus.pdf');
    expect(pdfFile.existsSync(), isTrue, reason: 'PDF File must exist');

    print('Reading PDF File: ${pdfFile.path} (${pdfFile.lengthSync()} bytes)');
    final bytes = pdfFile.readAsBytesSync();
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    print('Total Pages in PDF: ${document.pages.count}');

    final StringBuffer sb = StringBuffer();
    final PdfTextExtractor extractor = PdfTextExtractor(document);

    for (int i = 0; i < document.pages.count; i++) {
      final String pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
      sb.writeln('=== PAGE ${i + 1} ===');
      sb.writeln(pageText);
      sb.writeln('\n');
    }

    document.dispose();

    final outputFile = File(r'C:\Users\hamme\AndroidStudioProjects\hammesh_aae\.artifacts\blueprint_pdf_text.txt');
    if (!outputFile.parent.existsSync()) {
      outputFile.parent.createSync(recursive: true);
    }
    outputFile.writeAsStringSync(sb.toString());
    print('✅ Extracted PDF text saved to: ${outputFile.path}');
  });
}
