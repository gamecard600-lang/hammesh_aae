import 'dart:convert';
import 'dart:io';

void main() {
  stdout.writeln('=== HAMMESH_AAE JSON CONTENT VALIDATION ===');

  final masterFile = File('assets/study_material/master_study_material.json');
  if (!masterFile.existsSync()) {
    stderr.writeln('❌ ERROR: master_study_material.json not found!');
    exit(1);
  }

  try {
    final masterContent = masterFile.readAsStringSync();
    final List<dynamic> subjects = jsonDecode(masterContent);

    int totalTopics = 0;
    int visualTopics = 0;

    for (final subj in subjects) {
      final String subjectName = subj['subject'] ?? '';
      final List<dynamic> topics = subj['topics'] ?? [];

      for (final topic in topics) {
        totalTopics++;
        if (topic['id'] == null) {
          stdout.writeln('⚠️ Warning: Topic in $subjectName missing ID: ${topic['title']}');
        }

        final vl = topic['visualLearning'];
        if (vl != null && (vl['enabled'] == true || vl['visualRequired'] == true)) {
          visualTopics++;
          if ((vl['animationKey'] ?? '').toString().isEmpty) {
            stdout.writeln('⚠️ Warning: Enabled visual topic $subjectName -> ${topic['title']} missing animationKey!');
          }
        }
      }
    }

    stdout.writeln('✅ master_study_material.json validated successfully!');
    stdout.writeln('  - Subjects: ${subjects.length}');
    stdout.writeln('  - Total Topics: $totalTopics');
    stdout.writeln('  - Visual Topics Configured: $visualTopics');

    // Also check questions JSON files if available
    final questionsDir = Directory('assets/questions');
    if (questionsDir.existsSync()) {
      int totalQuestions = 0;
      final jsonFiles = questionsDir.listSync().whereType<File>().where((f) => f.path.endsWith('.json'));

      for (final qFile in jsonFiles) {
        final qContent = qFile.readAsStringSync();
        final dynamic decoded = jsonDecode(qContent);
        if (decoded is List) {
          totalQuestions += decoded.length;
        }
      }
      stdout.writeln('✅ All question JSON files validated! Total questions: $totalQuestions');
    }

    stdout.writeln('🎉 ALL JSON CONTENT VALIDATION PASSED WITH 0 ERRORS!');
  } catch (e, stack) {
    stderr.writeln('❌ JSON VALIDATION FAILED: $e');
    stderr.writeln(stack);
    exit(1);
  }
}
