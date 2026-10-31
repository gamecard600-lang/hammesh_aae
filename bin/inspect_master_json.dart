import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/study_material/master_study_material.json');
  final List master = jsonDecode(file.readAsStringSync());

  print('=== MASTER STUDY MATERIAL VERIFICATION ===');
  print('Total Subjects in Master JSON: ${master.length}');

  int totalTopics = 0;
  for (int i = 0; i < master.length; i++) {
    final s = master[i];
    final String name = s['subject'] ?? '';
    final List topics = s['topics'] ?? [];
    totalTopics += topics.length;

    print('Subject ${i + 1}: $name (${topics.length} topics)');
    if (topics.isNotEmpty) {
      final t1 = topics[0];
      print('  • Topic 1 Title: ${t1['title']} | ID: ${t1['id']}');
      print('  • Topic 1 Theory Length: ${(t1['detailedTheory'] as String? ?? '').length} chars');
      print('  • Topic 1 Videos Count: ${(t1['visualLearning']?['videos'] as List? ?? []).length}');
    }
  }

  print('\nTotal Topics Across All 14 Subjects: $totalTopics');
}
