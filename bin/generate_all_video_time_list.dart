import 'dart:convert';
import 'dart:io';

void main() {
  final catalogFile = File('assets/video_learning/video_catalog.json');
  if (!catalogFile.existsSync()) {
    print('Error: video_catalog.json not found!');
    exit(1);
  }

  final Map<String, dynamic> catalogJson = jsonDecode(catalogFile.readAsStringSync());
  final List videos = catalogJson['videos'] as List? ?? [];

  final masterFile = File('assets/study_material/master_study_material.json');
  final List masterData = jsonDecode(masterFile.readAsStringSync());

  print('================================================================================');
  print('🎬 HAMMESH_AAE COMPLETE 14 SUBJECTS & 165 TOPICS VIDEO DURATION CATALOG');
  print('================================================================================\n');

  int grandTotalSeconds = 0;
  int totalVideosCount = 0;

  for (int sIndex = 0; sIndex < masterData.length; sIndex++) {
    final s = masterData[sIndex];
    final String subjectName = s['subject'] ?? '';
    final List topics = s['topics'] as List? ?? [];

    int subjectSeconds = 0;
    int subjectVideosCount = 0;

    print('--------------------------------------------------------------------------------');
    print('📌 SUBJECT ${sIndex + 1}: $subjectName (${topics.length} Topics)');
    print('--------------------------------------------------------------------------------');

    for (int tIndex = 0; tIndex < topics.length; tIndex++) {
      final t = topics[tIndex];
      final int topicId = t['id'];
      final String topicTitle = t['title'] ?? t['topic'] ?? '';

      final conceptVid = videos.firstWhere((v) => v['id'] == 'vid_${topicId}_1', orElse: () => null);
      final numVid = videos.firstWhere((v) => v['id'] == 'vid_${topicId}_2', orElse: () => null);

      final int conceptSec = conceptVid != null ? (conceptVid['durationSeconds'] ?? 0) : 0;
      final int numSec = numVid != null ? (numVid['durationSeconds'] ?? 0) : 0;
      final int topicTotalSec = conceptSec + numSec;

      subjectSeconds += topicTotalSec;
      subjectVideosCount += (conceptVid != null ? 1 : 0) + (numVid != null ? 1 : 0);

      final String conceptMin = '${(conceptSec / 60).floor()}m ${conceptSec % 60}s';
      final String numMin = '${(numSec / 60).floor()}m ${numSec % 60}s';
      final String totalMin = '${(topicTotalSec / 60).floor()}m ${topicTotalSec % 60}s';

      print('  • Topic ${tIndex + 1} (ID $topicId): $topicTitle');
      print('      - Primary Concept Video : $conceptMin ($conceptSec sec)');
      print('      - Numerical & Practical : $numMin ($numSec sec)');
      print('      - Total Topic Duration  : $totalMin ($topicTotalSec sec)');
    }

    grandTotalSeconds += subjectSeconds;
    totalVideosCount += subjectVideosCount;

    final int subjHours = (subjectSeconds / 3600).floor();
    final int subjMins = ((subjectSeconds % 3600) / 60).floor();
    final int subjSecs = subjectSeconds % 60;

    print('\n  ⏱️ Subject ${sIndex + 1} Total Duration: ${subjHours}h ${subjMins}m ${subjSecs}s ($subjectSeconds sec) | $subjectVideosCount Videos\n');
  }

  final int grandHours = (grandTotalSeconds / 3600).floor();
  final int grandMins = ((grandTotalSeconds % 3600) / 60).floor();
  final int grandSecs = grandTotalSeconds % 60;

  print('================================================================================');
  print('🏆 GRAND TOTAL ACROSS ALL 14 SUBJECTS (165 TOPICS & $totalVideosCount VIDEOS)');
  print('⏱️ Total Course Video Learning Duration: ${grandHours} Hours ${grandMins} Minutes ${grandSecs} Seconds ($grandTotalSeconds sec)');
  print('================================================================================');
}
