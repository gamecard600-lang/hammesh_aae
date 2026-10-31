import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  final pdfFile = File(r'C:\Users\hamme\Downloads\Aae Study notes .pdf');
  if (!pdfFile.existsSync()) {
    print('PDF file missing!');
    return;
  }

  print('Reading PDF bytes...');
  final List<int> bytes = pdfFile.readAsBytesSync();

  print('Loading PdfDocument...');
  final PdfDocument document = PdfDocument(inputBytes: bytes);

  print('Total PDF Pages: ${document.pages.count}');

  final PdfTextExtractor extractor = PdfTextExtractor(document);

  final outDir = Directory('.artifacts/pdf_extracted_pages');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  final Map<int, String> pageTextMap = {};
  final StringBuffer fullTextBuffer = StringBuffer();

  for (int i = 0; i < document.pages.count; i++) {
    final int pageNum = i + 1;
    final String pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);

    pageTextMap[pageNum] = pageText;

    final pageFile = File('${outDir.path}/page_$pageNum.txt');
    pageFile.writeAsStringSync(pageText);

    fullTextBuffer.writeln('=== PAGE $pageNum ===');
    fullTextBuffer.writeln(pageText);
    fullTextBuffer.writeln('\n');
  }

  final allPagesFile = File('${outDir.path}/all_pages.txt');
  allPagesFile.writeAsStringSync(fullTextBuffer.toString());

  document.dispose();

  print('✅ Extracted ${document.pages.count} pages into .artifacts/pdf_extracted_pages/');
}
