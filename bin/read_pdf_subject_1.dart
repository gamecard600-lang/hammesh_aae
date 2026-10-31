import 'dart:convert';
import 'dart:io';

void main() {
  final jsonFile = File(r'C:\Users\hamme\Downloads\aae_study_notes_source_extracted.json');
  if (!jsonFile.existsSync()) return;

  final Map<String, dynamic> data = jsonDecode(jsonFile.readAsStringSync());

  print('=== SUBJECT 1: THERMODYNAMICS PDF SOURCE PAGES (3 to 15) ===\n');

  data.forEach((key, val) {
    final int pageNum = int.tryParse(key.replaceAll('page_', '')) ?? 0;
    if (pageNum >= 3 && pageNum <= 15) {
      print('--- PAGE $pageNum ---');
      print(val.toString().substring(0, val.toString().length > 300 ? 300 : val.toString().length));
      print('\n');
    }
  });
}
