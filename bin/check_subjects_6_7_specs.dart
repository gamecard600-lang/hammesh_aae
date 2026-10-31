import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/video_learning/video_catalog.json');
  if (!file.existsSync()) {
    print('Catalog file missing!');
    return;
  }
  final Map<String, dynamic> json = jsonDecode(file.readAsStringSync());
  final List videos = json['videos'];

  final s6Videos = videos.where((v) => (v['subject'] as String? ?? '').trim().toLowerCase().contains('engineering mechanics')).toList();
  final s7Videos = videos.where((v) => (v['subject'] as String? ?? '').trim().toLowerCase().contains('mechanics of materials')).toList();

  print('=== SUBJECT 6: ENGINEERING MECHANICS TOPIC-WISE VIDEO SPECS ===\n');
  for (int i = 53; i <= 60; i++) {
    final conceptVid = s6Videos.firstWhere((v) => v['id'] == 'vid_${i}_1', orElse: () => null);
    final numVid = s6Videos.firstWhere((v) => v['id'] == 'vid_${i}_2', orElse: () => null);

    if (conceptVid == null) continue;

    final int conceptSec = conceptVid['durationSeconds'] ?? 0;
    final int numSec = numVid != null ? (numVid['durationSeconds'] ?? 0) : 0;
    final int totalSec = conceptSec + numSec;

    print('Topic ${i - 52}: ${conceptVid['topic']} (ID $i)');
    print('  • Primary Concept Video Duration : ${(conceptSec / 60).floor()}m ${conceptSec % 60}s (${conceptSec} sec)');
    print('  • Numerical & Practical Duration  : ${(numSec / 60).floor()}m ${numSec % 60}s (${numSec} sec)');
    print('  • Total Topic Video Duration     : ${(totalSec / 60).floor()}m ${totalSec % 60}s (${totalSec} sec)');
    print('  • Primary Video Asset Path       : ${conceptVid['assetPath']}');
    print('');
  }

  print('\n=== SUBJECT 7: MECHANICS OF MATERIALS TOPIC-WISE VIDEO SPECS ===\n');
  for (int i = 61; i <= 72; i++) {
    final conceptVid = s7Videos.firstWhere((v) => v['id'] == 'vid_${i}_1', orElse: () => null);
    final numVid = s7Videos.firstWhere((v) => v['id'] == 'vid_${i}_2', orElse: () => null);

    if (conceptVid == null) continue;

    final int conceptSec = conceptVid['durationSeconds'] ?? 0;
    final int numSec = numVid != null ? (numVid['durationSeconds'] ?? 0) : 0;
    final int totalSec = conceptSec + numSec;

    print('Topic ${i - 60}: ${conceptVid['topic']} (ID $i)');
    print('  • Primary Concept Video Duration : ${(conceptSec / 60).floor()}m ${conceptSec % 60}s (${conceptSec} sec)');
    print('  • Numerical & Practical Duration  : ${(numSec / 60).floor()}m ${numSec % 60}s (${numSec} sec)');
    print('  • Total Topic Video Duration     : ${(totalSec / 60).floor()}m ${totalSec % 60}s (${totalSec} sec)');
    print('  • Primary Video Asset Path       : ${conceptVid['assetPath']}');
    print('');
  }
}
