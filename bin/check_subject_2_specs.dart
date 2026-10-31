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

  final s2Videos = videos.where((v) => v['subject'] == 'Fluid Mechanics').toList();

  print('=== SUBJECT 2: FLUID MECHANICS TOPIC-WISE VIDEO SPECS ===\n');

  for (int i = 11; i <= 23; i++) {
    final conceptVid = s2Videos.firstWhere(
      (v) => v['id'] == 'vid_${i}_1',
      orElse: () => null,
    );
    final numVid = s2Videos.firstWhere(
      (v) => v['id'] == 'vid_${i}_2',
      orElse: () => null,
    );

    if (conceptVid == null) continue;

    final assetPath = conceptVid['assetPath'] as String? ?? '';
    int assetSizeBytes = 0;
    if (assetPath.isNotEmpty) {
      final f = File(assetPath);
      if (f.existsSync()) {
        assetSizeBytes = f.lengthSync();
      }
    }

    final double assetSizeMB = assetSizeBytes / (1024 * 1024);
    final int conceptSec = conceptVid['durationSeconds'] ?? 0;
    final int numSec = numVid != null ? (numVid['durationSeconds'] ?? 0) : 0;
    final int totalSec = conceptSec + numSec;

    final String conceptMin = '${(conceptSec / 60).floor()}m ${conceptSec % 60}s';
    final String numMin = '${(numSec / 60).floor()}m ${numSec % 60}s';
    final String totalMin = '${(totalSec / 60).floor()}m ${totalSec % 60}s';

    print('Topic ${i - 10}: ${conceptVid['topic']} (ID $i)');
    print('  • Primary Concept Video Duration : $conceptMin ($conceptSec sec)');
    print('  • Numerical & Practical Duration  : $numMin ($numSec sec)');
    print('  • Total Topic Video Duration     : $totalMin ($totalSec sec)');
    print('  • Primary Video Asset File       : ${assetPath.isNotEmpty ? assetPath : "External/Stream"}');
    print('  • Primary Asset File Size        : ${assetSizeMB > 0 ? "${assetSizeMB.toStringAsFixed(2)} MB" : "Streaming Asset"}');
    print('');
  }
}
