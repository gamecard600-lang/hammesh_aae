import 'dart:io';

void main() {
  final dir = Directory('.artifacts/pdf_extracted_pages');
  if (!dir.existsSync()) {
    print('Dir not found');
    return;
  }

  print('=== ANALYZING ALL 161 EXTRACTED PDF PAGES ===\n');

  for (int p = 1; p <= 161; p++) {
    final pageFile = File('.artifacts/pdf_extracted_pages/page_$p.txt');
    if (!pageFile.existsSync()) continue;

    final lines = pageFile.readAsLinesSync().where((l) => l.trim().isNotEmpty).toList();

    // Show first 3 non-empty lines of each page to discover headings
    final String head1 = lines.isNotEmpty ? lines[0] : '';
    final String head2 = lines.length > 1 ? lines[1] : '';

    print('Page $p:');
    print('   Line 1: $head1');
    if (head2.isNotEmpty) print('   Line 2: $head2');
  }
}
