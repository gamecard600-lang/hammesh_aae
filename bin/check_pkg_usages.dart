import 'dart:io';

void main() {
  final packages = [
    'cupertino_icons',
    'shared_preferences',
    'pdf',
    'printing',
    'fl_chart',
    'share_plus',
    'http',
    'crypto',
    'path_provider',
    'url_launcher',
    'video_player',
  ];

  final libDir = Directory('lib');
  final List<File> dartFiles = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();

  print('=== PACKAGE USAGES IN LIB/ ===\n');

  for (final pkg in packages) {
    int count = 0;
    final List<String> filesWithPkg = [];
    for (final file in dartFiles) {
      final content = file.readAsStringSync();
      if (content.contains("package:$pkg/")) {
        count++;
        filesWithPkg.add(file.path.replaceAll('\\', '/'));
      }
    }
    print('Package "$pkg": Used in $count files ${filesWithPkg.isEmpty ? "❌ UNUSED IN LIB!" : ""}');
    for (final path in filesWithPkg) {
      print('   - $path');
    }
    print('');
  }
}
