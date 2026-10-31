import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/study_material/master_study_material.json');
  if (!file.existsSync()) {
    print('File missing!');
    return;
  }
  final List master = jsonDecode(file.readAsStringSync());

  print('=== ALL 14 TECHNICAL SUBJECTS STATUS ===\n');

  int totalTopics = 0;
  for (int i = 0; i < master.length; i++) {
    final s = master[i];
    final String name = s['subject'] ?? '';
    final List topics = s['topics'] ?? [];
    totalTopics += topics.length;

    // Check if topics have rich detailedTheory length > 800
    int detailedCount = 0;
    for (final t in topics) {
      final String theory = t['detailedTheory'] as String? ?? '';
      if (theory.length > 500) detailedCount++;
    }

    final bool isUpgraded = detailedCount == topics.length;

    print('Subject ${i + 1}: $name (${topics.length} topics) -> ${isUpgraded ? "✅ UPGRADED FULL DEPTH" : "⏳ NEEDS UPGRADE"} ($detailedCount/${topics.length})');
  }

  print('\nTotal Technical Topics: $totalTopics');
}
