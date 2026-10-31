import 'dart:io';

void main() {
  final assetsDir = Directory('assets');
  if (!assetsDir.existsSync()) {
    print('assets directory not found');
    return;
  }

  print('=== ASSETS DIRECTORY SIZE ANALYSIS ===\n');

  final Map<String, int> folderSizes = {};
  final List<File> allFiles = [];

  for (final entity in assetsDir.listSync(recursive: true)) {
    if (entity is File) {
      allFiles.add(entity);
      final size = entity.lengthSync();
      final parentPath = entity.parent.path;
      folderSizes[parentPath] = (folderSizes[parentPath] ?? 0) + size;
    }
  }

  print('--- FOLDER SIZES ---');
  folderSizes.forEach((path, size) {
    print('${path.replaceAll('\\', '/')}: ${(size / (1024 * 1024)).toStringAsFixed(2)} MB ($size bytes)');
  });

  print('\n--- LARGEST ASSET FILES ---');
  allFiles.sort((a, b) => b.lengthSync().compareTo(a.lengthSync()));
  for (int i = 0; i < allFiles.length && i < 20; i++) {
    final f = allFiles[i];
    final path = f.path.replaceAll('\\', '/');
    final mb = (f.lengthSync() / (1024 * 1024)).toStringAsFixed(2);
    print('${i + 1}. $path: $mb MB (${f.lengthSync()} bytes)');
  }
}
