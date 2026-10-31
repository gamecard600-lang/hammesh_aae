import 'dart:io';

void main() {
  final assetsDir = Directory('assets');
  if (!assetsDir.existsSync()) return;

  final allAssetFiles = assetsDir.listSync(recursive: true).whereType<File>().toList();

  // Load all text content from lib/ and assets/ JSON files
  final StringBuffer codeAndJsonBuffer = StringBuffer();

  final libDir = Directory('lib');
  if (libDir.existsSync()) {
    for (final f in libDir.listSync(recursive: true).whereType<File>()) {
      codeAndJsonBuffer.write(f.readAsStringSync());
      codeAndJsonBuffer.write('\n');
    }
  }

  for (final f in allAssetFiles) {
    if (f.path.endsWith('.json')) {
      codeAndJsonBuffer.write(f.readAsStringSync());
      codeAndJsonBuffer.write('\n');
    }
  }

  final String combinedText = codeAndJsonBuffer.toString();

  print('=== ASSET REFERENCE CHECK ===\n');

  final List<File> unusedAssets = [];
  final List<File> usedAssets = [];

  for (final file in allAssetFiles) {
    final normPath = file.path.replaceAll('\\', '/');
    final fileName = normPath.split('/').last;

    // Check if path or filename is mentioned
    final bool isReferenced = combinedText.contains(normPath) || combinedText.contains(fileName);

    if (isReferenced) {
      usedAssets.add(file);
    } else {
      unusedAssets.add(file);
    }
  }

  print('Total Asset Files: ${allAssetFiles.length}');
  print('Referenced Assets: ${usedAssets.length}');
  print('Unreferenced Assets: ${unusedAssets.length}\n');

  if (unusedAssets.isNotEmpty) {
    print('--- UNREFERENCED ASSET FILES LIST ---');
    int totalUnusedBytes = 0;
    for (final f in unusedAssets) {
      final size = f.lengthSync();
      totalUnusedBytes += size;
      final path = f.path.replaceAll('\\', '/');
      final mb = (size / (1024 * 1024)).toStringAsFixed(2);
      print('❌ $path ($mb MB / $size bytes)');
    }
    print('\nTotal Size of Unreferenced Assets: ${(totalUnusedBytes / (1024 * 1024)).toStringAsFixed(2)} MB');
  }
}
