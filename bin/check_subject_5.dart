import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/study_material/master_study_material.json');
  if (!file.existsSync()) {
    print('File missing!');
    return;
  }
  final List master = jsonDecode(file.readAsStringSync());
  final s5 = master.firstWhere(
    (e) => (e['subject'] as String? ?? '').trim().toLowerCase().contains('refrigeration'),
    orElse: () => null,
  );

  if (s5 == null) {
    print('Subject 5 (Refrigeration & Air Conditioning) not found in master_study_material.json!');
    return;
  }

  final List topics = s5['topics'] ?? [];
  print('=== SUBJECT 5: REFRIGERATION & AIR CONDITIONING CURRENT STATUS ===');
  print('Total Topics: ${topics.length}\n');

  for (int i = 0; i < topics.length; i++) {
    final t = topics[i];
    print('Topic ${i + 1}: ID ${t['id']} | Title: ${t['title'] ?? t['topic']}');
  }
}
