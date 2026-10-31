import 'dart:convert';
import 'dart:io';

void main() {
  final subjectsFile = File('assets/questions/subjects.json');
  final List subjectsData = jsonDecode(subjectsFile.readAsStringSync());

  print('=== SUBJECTS.JSON TOPIC IDS INSPECTION ===\n');

  int cumulativeId = 1;
  for (int sIdx = 0; sIdx < subjectsData.length; sIdx++) {
    final s = subjectsData[sIdx];
    final String name = s['name'] ?? s['subject'] ?? '';
    final List topics = s['topics'] as List? ?? s['subTopics'] as List? ?? [];

    print('Subject ${sIdx + 1}: $name (${topics.length} topics)');
    for (int tIdx = 0; tIdx < topics.length; tIdx++) {
      final t = topics[tIdx];
      if (t is Map) {
        print('   ${tIdx + 1}. Specified ID: ${t['id']} | Cumulative ID: $cumulativeId | Title: ${t['title'] ?? t['name']}');
      }
      cumulativeId++;
    }
  }
}
