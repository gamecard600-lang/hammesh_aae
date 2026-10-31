import 'dart:convert';
import 'dart:io';

void main() {
  final jsonFile = File(r'C:\Users\hamme\Downloads\aae_study_notes_source_extracted.json');
  final dynamic decoded = jsonDecode(jsonFile.readAsStringSync());

  if (decoded is List) {
    print('JSON is a List of length: ${decoded.length}');
    if (decoded.isNotEmpty) {
      print('First item keys: ${(decoded[0] as Map).keys}');
    }
  } else if (decoded is Map) {
    print('JSON is a Map with keys count: ${decoded.keys.length}');
    print('First 5 keys: ${decoded.keys.take(5).toList()}');
  }
}
