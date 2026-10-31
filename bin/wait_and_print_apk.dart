import 'dart:io';

void main() {
  final apkFile = File('build/app/outputs/flutter-apk/app-release.apk');
  print('Waiting for app-release.apk to be built...');

  for (int i = 0; i < 60; i++) {
    if (apkFile.existsSync()) {
      final bytes = apkFile.lengthSync();
      final mb = (bytes / (1024 * 1024)).toStringAsFixed(2);
      print('\n==================================================');
      print('✅ RELEASE APK BUILT SUCCESSFULLY!');
      print('   • Path: ${apkFile.path}');
      print('   • Size: $mb MB ($bytes bytes)');
      print('==================================================\n');
      return;
    }
    sleep(const Duration(seconds: 3));
  }

  print('Timeout waiting for release APK.');
}
