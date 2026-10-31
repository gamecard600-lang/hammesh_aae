import 'dart:convert';
import 'dart:io';

void main() {
  final masterFile = File('assets/study_material/master_study_material.json');
  final List masterData = jsonDecode(masterFile.readAsStringSync());

  print('=== SUBJECTS IN MASTER STUDY MATERIAL (${masterData.length}) ===\n');

  for (int i = 0; i < masterData.length; i++) {
    final s = masterData[i];
    final String subjectName = s['subject'] ?? '';
    final List topics = s['topics'] as List? ?? [];
    print('Subject ${i + 1}: $subjectName (${topics.length} topics)');
    for (int j = 0; j < topics.length && j < 3; j++) {
      final t = topics[j];
      print('   Topic ${j + 1} (ID ${t['id']}): ${t['title'] ?? t['topic']}');
    }
  }
}
