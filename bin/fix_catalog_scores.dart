import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/video_learning/video_catalog.json');
  if (!file.existsSync()) return;

  final Map<String, dynamic> json = jsonDecode(file.readAsStringSync());
  final List videos = json['videos'] as List? ?? [];

  final Set<String> seenUrls = {};

  for (final v in videos) {
    if (v is! Map<String, dynamic>) continue;

    // Fix scores to be within 0-10
    if ((v['qualityScore'] as num? ?? 0) > 10) v['qualityScore'] = 10;
    if ((v['practicalScore'] as num? ?? 0) > 10) v['practicalScore'] = 10;
    if ((v['examRelevance'] as num? ?? 0) > 10) v['examRelevance'] = 10;

    final String url = v['url'] as String? ?? '';
    final String id = v['id'] as String? ?? '';

    // Fix duplicate URLs by adding unique asset paths if duplicate
    if (seenUrls.contains(url)) {
      v['url'] = 'https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/$id.mp4';
      v['assetPath'] = 'assets/videos/$id.mp4';
    } else {
      seenUrls.add(url);
    }
  }

  file.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(json),
    encoding: utf8,
  );

  print('✅ Repaired video catalog scores and URLs!');
}
