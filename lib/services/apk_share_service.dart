import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../config/app_config.dart';

class ApkShareService {
  static const MethodChannel _channel = MethodChannel('com.example.hammesh_aae/apk_share');

  /// Shares the actual installed APK file via Android system share sheet.
  static Future<void> shareInstalledApk() async {
    try {
      final String? apkPath = await _channel.invokeMethod<String>('getApkPath');
      if (apkPath != null && apkPath.isNotEmpty) {
        await Share.shareXFiles(
          [
            XFile(
              apkPath,
              mimeType: 'application/vnd.android.package-archive',
              name: 'hammesh_aae.apk',
            ),
          ],
          text: AppConfig.fullShareText,
          subject: AppConfig.appTitle,
        );
        return;
      }
    } catch (_) {
      // Fallback
    }

    // Fallback if APK path not found or on non-Android platform
    await Share.share(
      AppConfig.fullShareText,
      subject: AppConfig.appTitle,
    );
  }
}
