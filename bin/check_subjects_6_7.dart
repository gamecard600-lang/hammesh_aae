import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/study_material/master_study_material.json');
  if (!file.existsSync()) {
    print('File missing!');
    return;
  }
  final List master = jsonDecode(file.readAsStringSync());

  final s6 = master.firstWhere(
    (e) => (e['subject'] as String? ?? '').trim().toLowerCase().contains('engineering mechanics'),
    orElse: () => null,
  );

  final s7 = master.firstWhere(
    (e) => (e['subject'] as String? ?? '').trim().toLowerCase().contains('mechanics of materials'),
    orElse: () => null,
  );

  print('=== SUBJECT 6 & SUBJECT 7 CURRENT STATUS ===');
  if (s6 != null) {
    print('Subject 6 (Engineering Mechanics) Topics Count: ${(s6['topics'] as List).length}');
  } else {
    print('Subject 6 not found');
  }

  if (s7 != null) {
    print('Subject 7 (Mechanics of Materials) Topics Count: ${(s7['topics'] as List).length}');
  } else {
    print('Subject 7 not found');
  }
}
