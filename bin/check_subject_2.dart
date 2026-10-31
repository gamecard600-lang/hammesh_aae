import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/study_material/master_study_material.json');
  if (!file.existsSync()) {
    print('File missing!');
    return;
  }
  final List master = jsonDecode(file.readAsStringSync());
  final s2 = master.firstWhere(
    (e) => (e['subject'] as String? ?? '').trim().toLowerCase() == 'fluid mechanics',
    orElse: () => null,
  );

  if (s2 == null) {
    print('Subject 2 (Fluid Mechanics) not found in master_study_material.json!');
    return;
  }

  final List topics = s2['topics'] ?? [];
  print('=== SUBJECT 2: FLUID MECHANICS CURRENT STATUS ===');
  print('Total Topics: ${topics.length}\n');

  for (int i = 0; i < topics.length; i++) {
    final t = topics[i];
    print('Topic ${i + 1}: ID ${t['id']} | Title: ${t['title'] ?? t['topic']}');
  }
}
