import 'dart:convert';
import 'dart:io';

void main() {
  final jsonFile = File(r'C:\Users\hamme\Downloads\aae_study_notes_source_extracted.json');
  final Map<String, dynamic> data = jsonDecode(jsonFile.readAsStringSync());

  final pages = data['pages'] as List? ?? [];
  print('Pages list length: ${pages.length}');

  if (pages.isNotEmpty) {
    print('Page 1 object keys: ${(pages[0] as Map).keys}');
    print('Page 3 text sample:\n${(pages[2]['text'] as String).substring(0, 300)}');
  }
}
