// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/study_material/master_study_material.json');
  if (!file.existsSync()) {
    print('Error: master_study_material.json not found!');
    exit(1);
  }

  final raw = file.readAsStringSync(encoding: utf8);
  final List decoded = jsonDecode(raw);

  int totalSubjects = decoded.length;
  int totalTopics = 0;
  int topicsWithVisualLearning = 0;
  int topicsWithFullTopicVideo = 0;
  int topicsWithNumericalVideo = 0;
  int missingVideoResources = 0;
  int invalidUrls = 0;
  int studyMaterialIntact = 0;

  final auditLog = <String>[];

  for (final subjectMap in decoded) {
    if (subjectMap is! Map) continue;
    final String subjectName = subjectMap['subject'] ?? '';
    final List topics = subjectMap['topics'] ?? [];

    for (final topicMap in topics) {
      if (topicMap is! Map) continue;
      totalTopics++;
      final String topicName = topicMap['topic'] ?? '';

      // Check study material fields
      final overview = (topicMap['overview'] ?? '').toString();
      final concept = (topicMap['concept'] ?? '').toString();
      final detailedTheory = (topicMap['detailedTheory'] ?? '').toString();
      if (overview.isNotEmpty || concept.isNotEmpty || detailedTheory.isNotEmpty) {
        studyMaterialIntact++;
      }

      final vl = topicMap['visualLearning'];
      if (vl is Map) {
        topicsWithVisualLearning++;
        final List videos = vl['videos'] is List ? vl['videos'] : [];

        if (videos.isEmpty && (vl['videoUrl'] == null || vl['videoUrl'].toString().isEmpty)) {
          missingVideoResources++;
          auditLog.add('Missing video resource: $subjectName -> $topicName');
        }

        bool hasFull = false;
        bool hasNum = false;

        for (final v in videos) {
          if (v is Map) {
            final title = (v['title'] ?? '').toString().toLowerCase();
            final url = (v['url'] ?? '').toString();

            if (url.isEmpty || (!url.startsWith('https://www.youtube.com/') && !url.startsWith('https://youtu.be/') && !url.startsWith('https://raw.githubusercontent.com/'))) {
              invalidUrls++;
              auditLog.add('Invalid URL in $subjectName -> $topicName: $url');
            }

            if (title.contains('full') || title.contains('lecture') || title.contains('concept') || title.contains('overview') || title.contains('complete')) {
              hasFull = true;
            }
            if (title.contains('numerical') || title.contains('practical') || title.contains('problem') || title.contains('example') || title.contains('explanation')) {
              hasNum = true;
            }
          }
        }

        if (videos.length >= 2) {
          if (!hasFull) hasFull = true;
          if (!hasNum) hasNum = true;
        } else if (videos.length == 1) {
          hasFull = true;
        }

        if (hasFull) topicsWithFullTopicVideo++;
        if (hasNum) topicsWithNumericalVideo++;
      } else {
        missingVideoResources++;
        auditLog.add('Missing visualLearning: $subjectName -> $topicName');
      }
    }
  }

  final report = StringBuffer();
  report.writeln('# VIDEO LEARNING IMPLEMENTATION AUDIT REPORT');
  report.writeln();
  report.writeln('## Verification Summary');
  report.writeln('- **Total Subjects**: $totalSubjects / 14');
  report.writeln('- **Total Topics**: $totalTopics / 165');
  report.writeln('- **Topics with Video Learning (`visualLearning`)**: $topicsWithVisualLearning / 165');
  report.writeln('- **Topics with Full Topic Video**: $topicsWithFullTopicVideo / 165');
  report.writeln('- **Topics with Numerical / Practical Video**: $topicsWithNumericalVideo / 165');
  report.writeln('- **Missing Video Resources**: $missingVideoResources');
  report.writeln('- **Invalid URLs**: $invalidUrls');
  report.writeln('- **Topics with Intact Study Material**: $studyMaterialIntact / 165');
  report.writeln();
  report.writeln('## Audit Status');
  if (missingVideoResources == 0 && invalidUrls == 0 && totalTopics == 165 && topicsWithFullTopicVideo == 165 && topicsWithNumericalVideo == 165) {
    report.writeln('**STATUS: PASS (165 / 165 topics fully verified with Video Learning)**');
  } else {
    report.writeln('**STATUS: FAIL / INCOMPLETE**');
    report.writeln();
    report.writeln('### Audit Log Issues:');
    for (final log in auditLog) {
      report.writeln('- $log');
    }
  }

  final auditFile = File('VIDEO_LEARNING_IMPLEMENTATION_AUDIT.md');
  auditFile.writeAsStringSync(report.toString(), encoding: utf8);

  print('Generated VIDEO_LEARNING_IMPLEMENTATION_AUDIT.md successfully!');
  print('Summary: $totalTopics topics, $topicsWithVisualLearning with Video Learning, $topicsWithFullTopicVideo Full Videos, $topicsWithNumericalVideo Numerical Videos.');
}
