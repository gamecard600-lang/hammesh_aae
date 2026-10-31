import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/study_material/master_study_material.json');
  if (!file.existsSync()) {
    print('File missing!');
    return;
  }
  final List master = jsonDecode(file.readAsStringSync());
  final s3 = master.firstWhere(
    (e) => (e['subject'] as String? ?? '').trim().toLowerCase() == 'power engineering',
    orElse: () => null,
  );

  if (s3 == null) {
    print('Subject 3 (Power Engineering) not found in master_study_material.json!');
    return;
  }

  final List topics = s3['topics'] ?? [];
  print('=== SUBJECT 3: POWER ENGINEERING CURRENT STATUS ===');
  print('Total Topics: ${topics.length}\n');

  for (int i = 0; i < topics.length; i++) {
    final t = topics[i];
    print('Topic ${i + 1}: ID ${t['id']} | Title: ${t['title'] ?? t['topic']}');
    print('  Overview length: ${(t['overview'] as String? ?? '').length}');
    print('  DetailedTheory length: ${(t['detailedTheory'] as String? ?? '').length}');
    print('  Formulas count: ${(t['formulas'] as List? ?? []).length}');
    print('  Solved Examples count: ${(t['solvedExamples'] as List? ?? []).length}');
    print('  KeyPoints count: ${(t['keyPoints'] as List? ?? []).length}');
    print('  ExamPoints count: ${(t['examPoints'] as List? ?? []).length}');
    print('  Videos count: ${(t['visualLearning']?['videos'] as List? ?? []).length}');
    print('');
  }
}
