// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final path = 'assets/study_material/master_study_material.json';
  final file = File(path);
  if (!file.existsSync()) {
    print('ERROR: $path not found.');
    exit(1);
  }

  final List<dynamic> data = jsonDecode(file.readAsStringSync());
  if (data.length != 14) {
    print('ERROR: Expected 14 subjects, found ${data.length}');
    exit(1);
  }

  int count = 0;
  List<String> bad = [];

  for (var s in data) {
    final sName = s['subject'] ?? 'Unknown';
    final topics = s['topics'] as List<dynamic>? ?? [];
    for (var t in topics) {
      final tName = t['topic'] ?? 'Unknown Topic';
      final defs = t['definitions'] as List<dynamic>? ?? [];
      for (var x in defs) {
        count++;
        final str = x.toString().trim();
        if (!str.contains(':') || str.split(':')[0].trim().isEmpty || str.split(':')[1].trim().isEmpty) {
          bad.add('[$sName > $tName]: "$str"');
        }
      }
    }
  }

  print('Subjects: ${data.length}');
  print('Topics: ${data.fold<int>(0, (sum, s) => sum + (s['topics'] as List? ?? []).length)}');
  print('Definitions: $count');

  if (bad.isNotEmpty) {
    print('BAD DEFINITIONS: ${bad.length}');
    for (var b in bad.take(20)) {
      print(b);
    }
    exit(1);
  }

  print('DEFINITIONS VALIDATION: PASS');
}
