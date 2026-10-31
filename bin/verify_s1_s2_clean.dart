import 'dart:convert';
import 'dart:io';

void main() {
  final catalogFile = File('assets/video_learning/video_catalog.json');
  if (!catalogFile.existsSync()) {
    print('Catalog file not found!');
    return;
  }

  final Map<String, dynamic> catalogJson = jsonDecode(catalogFile.readAsStringSync());
  final List videos = catalogJson['videos'] as List? ?? [];

  final s1Videos = videos.where((v) => (v['subject'] as String? ?? '').trim().toLowerCase() == 'thermodynamics').toList();
  final s2Videos = videos.where((v) => (v['subject'] as String? ?? '').trim().toLowerCase() == 'fluid mechanics').toList();

  print('=== VERIFICATION OF SUBJECT 1 & SUBJECT 2 VIDEOS ===');
  print('Subject 1 (Thermodynamics) Total Catalog Videos: ${s1Videos.length} (Expected: 20)');
  print('Subject 2 (Fluid Mechanics) Total Catalog Videos: ${s2Videos.length} (Expected: 26)');

  print('\n--- Subject 1 Video IDs & Asset Paths ---');
  for (final v in s1Videos) {
    print('  • ${v['id']} | Topic: ${v['topic']} | Asset: ${v['assetPath']} | Verified: ${v['verified']}');
  }

  print('\n--- Subject 2 Video IDs & Asset Paths ---');
  for (final v in s2Videos) {
    print('  • ${v['id']} | Topic: ${v['topic']} | Asset: ${v['assetPath']} | Verified: ${v['verified']}');
  }
}
