import 'dart:io';

void main() {
  final dir = Directory('.artifacts/pdf_extracted_pages');
  if (!dir.existsSync()) {
    print('PDF extracted pages directory missing!');
    return;
  }

  print('=== MAPPING PDF PAGES TO SUBJECTS ===\n');

  for (int p = 1; p <= 161; p++) {
    final file = File('.artifacts/pdf_extracted_pages/page_$p.txt');
    if (!file.existsSync()) continue;

    final content = file.readAsStringSync();
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();

    for (final line in lines) {
      if (line.toLowerCase().contains('subject') || line.contains('SUBJECT')) {
        print('Page $p: $line');
      }
    }
  }
}
