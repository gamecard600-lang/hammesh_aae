import 'dart:convert';
import 'dart:io';

void main() {
  stdout.writeln('=== HAMMESH_AAE VIDEO CATALOG VALIDATION ===');

  // 1. Load authoritative topics from master_study_material.json and subjects.json
  final masterFile = File('assets/study_material/master_study_material.json');
  if (!masterFile.existsSync()) {
    stderr.writeln('❌ ERROR: assets/study_material/master_study_material.json not found!');
    exit(1);
  }

  final List<dynamic> masterData = jsonDecode(masterFile.readAsStringSync());
  final Map<String, List<String>> authoritativeMap = {};
  int totalAuthoritativeTopics = 0;

  for (final s in masterData) {
    final String subject = (s['subject'] as String? ?? '').trim();
    if (subject.isEmpty) continue;

    authoritativeMap[subject] = [];
    final List<dynamic> topics = s['topics'] as List<dynamic>? ?? [];

    for (final t in topics) {
      if (t is Map<String, dynamic>) {
        final String topicTitle = (t['title'] as String? ?? '').trim();
        if (topicTitle.isNotEmpty) {
          authoritativeMap[subject]!.add(topicTitle);
          totalAuthoritativeTopics++;
        }
      }
    }
  }

  stdout.writeln('✅ Loaded Authoritative Topics: ${authoritativeMap.length} Subjects, $totalAuthoritativeTopics Topics');

  // 2. Load Video Catalog JSON
  final catalogFile = File('assets/video_learning/video_catalog.json');
  if (!catalogFile.existsSync()) {
    stderr.writeln('❌ ERROR: assets/video_learning/video_catalog.json does not exist!');
    exit(1);
  }

  Map<String, dynamic> catalogJson;
  try {
    catalogJson = jsonDecode(catalogFile.readAsStringSync());
  } catch (e) {
    stderr.writeln('❌ ERROR: Invalid JSON format in video_catalog.json: $e');
    exit(1);
  }

  final List<dynamic> videos = catalogJson['videos'] as List<dynamic>? ?? [];
  if (videos.isEmpty) {
    stderr.writeln('❌ ERROR: Video catalog has 0 videos!');
    exit(1);
  }

  // Tracking variables
  final Set<String> seenIds = {};
  final Set<String> seenUrls = {};
  final Map<String, Map<String, List<Map<String, dynamic>>>> videoCoverageMap = {};

  int duplicateIds = 0;
  int duplicateUrls = 0;
  int invalidUrls = 0;
  int invalidScores = 0;
  int invalidTypes = 0;
  int invalidLanguages = 0;
  int unverifiedCount = 0;
  int primaryCount = 0;
  int practicalCount = 0;
  int numericalCount = 0;
  int examCount = 0;
  int invalidSubjectTopics = 0;

  for (int i = 0; i < videos.length; i++) {
    final item = videos[i];
    if (item is! Map<String, dynamic>) {
      stderr.writeln('❌ Item #$i is not a valid JSON object');
      exit(1);
    }

    final id = (item['id'] as String? ?? '').trim();
    final subject = (item['subject'] as String? ?? '').trim();
    final topic = (item['topic'] as String? ?? '').trim();
    final title = (item['title'] as String? ?? '').trim();
    final url = (item['url'] as String? ?? '').trim();
    final type = (item['type'] as String? ?? '').trim().toLowerCase();
    final language = (item['language'] as String? ?? '').trim();
    final isPrimary = item['isPrimary'] as bool? ?? false;
    final verified = item['verified'] as bool? ?? false;
    final qualityScore = (item['qualityScore'] as num?)?.toInt() ?? -1;
    final practicalScore = (item['practicalScore'] as num?)?.toInt() ?? -1;
    final examRelevance = (item['examRelevance'] as num?)?.toInt() ?? -1;

    // Check required fields
    if (id.isEmpty || subject.isEmpty || topic.isEmpty || title.isEmpty || url.isEmpty) {
      stderr.writeln('❌ Video #$i ($title) missing required text fields!');
      exit(1);
    }

    // Duplicate ID check
    if (seenIds.contains(id)) {
      stderr.writeln('❌ Duplicate Video ID detected: $id');
      duplicateIds++;
    } else {
      seenIds.add(id);
    }

    // Duplicate URL check
    if (seenUrls.contains(url)) {
      stderr.writeln('⚠️ Duplicate Video URL detected: $url for topic "$topic"');
      duplicateUrls++;
    } else {
      seenUrls.add(url);
    }

    // URL validation
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      stderr.writeln('❌ Invalid URL format: $url');
      invalidUrls++;
    }

    // Score ranges 0-10
    if (qualityScore < 0 || qualityScore > 10 ||
        practicalScore < 0 || practicalScore > 10 ||
        examRelevance < 0 || examRelevance > 10) {
      stderr.writeln('❌ Invalid score range (0-10) for video $id');
      invalidScores++;
    }

    // Type validation
    if (!['concept', 'practical', 'numerical', 'exam'].contains(type)) {
      stderr.writeln('❌ Invalid video type "$type" for video $id');
      invalidTypes++;
    }

    // Language validation
    if (!['English', 'Hindi', 'Gujarati'].contains(language)) {
      stderr.writeln('❌ Invalid language "$language" for video $id');
      invalidLanguages++;
    }

    if (!verified) unverifiedCount++;
    if (isPrimary) primaryCount++;
    if (type == 'practical') practicalCount++;
    if (type == 'numerical') numericalCount++;
    if (type == 'exam') examCount++;

    // Verify subject and topic match authoritative source
    final normSubjectKey = authoritativeMap.keys.firstWhere(
      (s) => s.toLowerCase() == subject.toLowerCase(),
      orElse: () => '',
    );

    if (normSubjectKey.isEmpty) {
      stderr.writeln('❌ Unknown Subject in video catalog: "$subject"');
      invalidSubjectTopics++;
    } else {
      final normTopicKey = authoritativeMap[normSubjectKey]!.firstWhere(
        (t) => t.toLowerCase() == topic.toLowerCase(),
        orElse: () => '',
      );

      if (normTopicKey.isEmpty) {
        stderr.writeln('❌ Unknown Topic in subject "$subject": "$topic"');
        invalidSubjectTopics++;
      } else {
        videoCoverageMap.putIfAbsent(normSubjectKey, () => {});
        videoCoverageMap[normSubjectKey]!.putIfAbsent(normTopicKey, () => []);
        videoCoverageMap[normSubjectKey]![normTopicKey]!.add(item);
      }
    }
  }

  // Check Authoritative Topic Coverage
  int missingPrimaryTopics = 0;
  int missingTopicsCount = 0;
  int coveredTopicsCount = 0;

  for (final sEntry in authoritativeMap.entries) {
    final subject = sEntry.key;
    final topics = sEntry.value;

    for (final topic in topics) {
      final topicVideos = videoCoverageMap[subject]?[topic] ?? [];
      if (topicVideos.isEmpty) {
        missingTopicsCount++;
        stderr.writeln('❌ MISSING ALL VIDEOS for topic: "$subject" -> "$topic"');
      } else {
        coveredTopicsCount++;
        final hasVerifiedPrimary = topicVideos.any((v) =>
            v['isPrimary'] == true && v['verified'] == true);

        if (!hasVerifiedPrimary) {
          missingPrimaryTopics++;
          stderr.writeln('❌ MISSING VERIFIED PRIMARY VIDEO for topic: "$subject" -> "$topic"');
        }
      }
    }
  }

  // Print Summary Report
  stdout.writeln('\n================ VALIDATION REPORT ================');
  stdout.writeln('Total Authoritative Subjects: ${authoritativeMap.length}');
  stdout.writeln('Total Authoritative Topics  : $totalAuthoritativeTopics');
  stdout.writeln('Total Catalog Videos        : ${videos.length}');
  stdout.writeln('Topics Covered              : $coveredTopicsCount / $totalAuthoritativeTopics');
  stdout.writeln('Topics Missing              : $missingTopicsCount');
  stdout.writeln('Primary Videos              : $primaryCount');
  stdout.writeln('Practical Videos            : $practicalCount');
  stdout.writeln('Numerical Videos            : $numericalCount');
  stdout.writeln('Exam Videos                 : $examCount');
  stdout.writeln('Verified Videos             : ${videos.length - unverifiedCount}');
  stdout.writeln('Unverified Videos           : $unverifiedCount');
  stdout.writeln('Duplicate IDs               : $duplicateIds');
  stdout.writeln('Duplicate URLs              : $duplicateUrls');
  stdout.writeln('Invalid URLs                : $invalidUrls');
  stdout.writeln('Invalid Scores              : $invalidScores');
  stdout.writeln('Invalid Subject/Topics      : $invalidSubjectTopics');
  stdout.writeln('Topics Lacking Verified Primary Video: $missingPrimaryTopics');
  stdout.writeln('====================================================\n');

  if (duplicateIds > 0 ||
      invalidUrls > 0 ||
      invalidScores > 0 ||
      invalidTypes > 0 ||
      invalidLanguages > 0 ||
      invalidSubjectTopics > 0 ||
      missingTopicsCount > 0 ||
      missingPrimaryTopics > 0) {
    stderr.writeln('❌ VALIDATION FAILED: Video catalog has validation errors or incomplete authoritative topic coverage!');
    exit(1);
  } else {
    stdout.writeln('🎉 ALL VIDEO CATALOG VALIDATIONS PASSED WITH 0 ERRORS!');
    exit(0);
  }
}
