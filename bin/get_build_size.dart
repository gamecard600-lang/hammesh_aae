import 'dart:io';

void main() {
  final apkFile = File('build/app/outputs/flutter-apk/app-release.apk');
  if (apkFile.existsSync()) {
    final bytes = apkFile.lengthSync();
    final mb = (bytes / (1024 * 1024)).toStringAsFixed(2);
    print('SUCCESS: Baseline Release APK size: $mb MB ($bytes bytes)');
  } else {
    print('APK file not built yet.');
  }
}
