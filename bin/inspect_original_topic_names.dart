import 'dart:convert';
import 'dart:io';

void main() {
  final subjectsFile = File('assets/questions/subjects.json');
  if (!subjectsFile.existsSync()) return;

  final List subjectsData = jsonDecode(subjectsFile.readAsStringSync());

  print('=== AUTHORITATIVE TOPIC NAMES FROM SUBJECTS.JSON ===\n');

  for (int i = 0; i < subjectsData.length; i++) {
    final s = subjectsData[i];
    final String subjectName = s['name'] ?? s['subject'] ?? '';
    final List topics = s['topics'] as List? ?? s['subTopics'] as List? ?? [];

    print('Subject ${i + 1}: $subjectName (${topics.length} topics)');
    for (int j = 0; j < topics.length; j++) {
      final t = topics[j];
      if (t is Map) {
        print('   ${j + 1}. ID ${t['id']}: ${t['title'] ?? t['name'] ?? t['topic']}');
      } else {
        print('   ${j + 1}. $t');
      }
    }
    print('');
  }
}
