import 'dart:io';

void main() {
  final jsonFile = File(r'C:\Users\hamme\Downloads\aae_study_notes_source_extracted.json');
  final txtFile = File(r'C:\Users\hamme\Downloads\aae_study_notes_source_extracted.txt');

  print('JSON File Exists: ${jsonFile.existsSync()} (${jsonFile.existsSync() ? jsonFile.lengthSync() : 0} bytes)');
  print('TXT File Exists: ${txtFile.existsSync()} (${txtFile.existsSync() ? txtFile.lengthSync() : 0} bytes)');
}
