// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final masterFile = File('assets/study_material/master_study_material.json');
  if (!masterFile.existsSync()) {
    print('Master study material file not found.');
    return;
  }

  final String content = masterFile.readAsStringSync(encoding: utf8);
  final List<dynamic> masterData = jsonDecode(content);

  final List<Map<String, dynamic>> quickRevisions = [];

  for (final subjectEntry in masterData) {
    if (subjectEntry is! Map<String, dynamic>) continue;
    final String subject = subjectEntry['subject'] ?? '';
    final List<dynamic> topics = subjectEntry['topics'] ?? [];

    for (final topicEntry in topics) {
      if (topicEntry is! Map<String, dynamic>) continue;
      final String topic = topicEntry['topic'] ?? topicEntry['title'] ?? '';

      final Set<String> pointsSet = {};

      List<String> extractList(dynamic val) {
        if (val is List) {
          return val.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
        } if (val is String && val.trim().isNotEmpty) {
          return [val.trim()];
        }
        return [];
      }

      final qr = extractList(topicEntry['quickRevision']);
      final ep = extractList(topicEntry['examPoints']);
      final ip = extractList(topicEntry['importantPoints']);
      final kp = extractList(topicEntry['keyPoints']);

      pointsSet.addAll(qr);
      pointsSet.addAll(ep);
      pointsSet.addAll(ip);
      pointsSet.addAll(kp);

      final List<String> finalPoints = pointsSet.toList();
      if (finalPoints.isNotEmpty) {
        quickRevisions.add({
          'subject': subject,
          'topic': topic,
          'points': finalPoints,
        });
      }
    }
  }

  final String outputJson = const JsonEncoder.withIndent('  ').convert(quickRevisions);
  final outputFile = File('assets/study_material/quick_revision.json');
  outputFile.writeAsStringSync(outputJson, encoding: utf8);

  print('Successfully generated quick_revision.json with ${quickRevisions.length} topics.');
}
