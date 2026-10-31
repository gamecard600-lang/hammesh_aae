import 'dart:io';

void main() {
  final dir = Directory('.artifacts/pdf_extracted_pages');
  if (!dir.existsSync()) {
    print('Dir does not exist yet.');
    return;
  }

  final files = dir.listSync().whereType<File>().where((f) => f.path.contains('page_')).toList();
  print('Extracted Pages Count: ${files.length}');

  final allPages = File('.artifacts/pdf_extracted_pages/all_pages.txt');
  print('all_pages.txt exists: ${allPages.existsSync()}');
  if (allPages.existsSync()) {
    print('all_pages.txt size: ${allPages.lengthSync()} bytes');
  }
}
