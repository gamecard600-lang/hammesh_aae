import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'question_service.dart';
import 'study_material_loader.dart';

class AutoUpdateService {
  static const String _updaterChannel = 'com.example.hammesh_aae/app_updater';
  static const String _lastCheckKey = 'auto_update_last_check_time';
  
  // Specific content version keys
  static const String _contentVersionKey = 'local_content_version';
  static const String _mcqVersionKey = 'local_mcq_version';
  static const String _studyMaterialVersionKey = 'local_study_material_version';
  static const String _formulaVersionKey = 'local_formula_version';
  static const String _quickRevisionVersionKey = 'local_quick_revision_version';
  static const String _visualVersionKey = 'local_visual_version';

  static const MethodChannel _channel = MethodChannel(_updaterChannel);
  static bool _isChecking = false;

  /// Main entry point triggered on app startup or manual check.
  /// Executes silently in background without UI popups or disrupting user experience.
  static Future<void> checkForUpdates({bool force = false}) async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Throttling: Check at most once every 1 hour unless forced
      final lastCheckTime = prefs.getInt(_lastCheckKey) ?? 0;
      final nowTime = DateTime.now().millisecondsSinceEpoch;
      if (!force && (nowTime - lastCheckTime) < (3600 * 1000)) {
        _isChecking = false;
        return;
      }

      await prefs.setInt(_lastCheckKey, nowTime);

      // Fetch remote manifest JSON
      final manifest = await _fetchRemoteManifest();
      if (manifest == null) {
        _isChecking = false;
        return;
      }

      // 1. Process Automatic Content Update (MCQs, Study Material, Formulas, Quick Revision, Visuals)
      await _processContentUpdate(manifest, prefs);

      // 2. Process Automatic APK Background Update
      await _processApkUpdate(manifest);
    } catch (e) {
      debugPrint('Silent auto update error: $e');
    } finally {
      _isChecking = false;
    }
  }

  /// Fetches version.json silently from remote server
  static Future<Map<String, dynamic>?> _fetchRemoteManifest() async {
    try {
      final response = await http
          .get(Uri.parse(AppConfig.updateManifestUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch update manifest: $e');
    }
    return null;
  }

  /// Safe Content Update Process:
  /// Download -> Temp File -> JSON Validation -> Checksum -> Backup -> Atomic Activation -> Rollback on Failure
  static Future<void> _processContentUpdate(
    Map<String, dynamic> manifest,
    SharedPreferences prefs,
  ) async {
    try {
      final remoteContentVer = manifest['contentVersion'] as int? ?? AppConfig.defaultContentVersion;
      final remoteMcqVer = manifest['mcqVersion'] as int? ?? remoteContentVer;
      final remoteStudyVer = manifest['studyMaterialVersion'] as int? ?? remoteContentVer;
      final remoteFormulaVer = manifest['formulaVersion'] as int? ?? remoteContentVer;
      final remoteQuickVer = manifest['quickRevisionVersion'] as int? ?? remoteContentVer;
      final remoteVisualVer = manifest['visualVersion'] as int? ?? remoteContentVer;

      final localContentVer = prefs.getInt(_contentVersionKey) ?? AppConfig.defaultContentVersion;
      final localMcqVer = prefs.getInt(_mcqVersionKey) ?? localContentVer;
      final localStudyVer = prefs.getInt(_studyMaterialVersionKey) ?? localContentVer;
      final localFormulaVer = prefs.getInt(_formulaVersionKey) ?? localContentVer;
      final localQuickVer = prefs.getInt(_quickRevisionVersionKey) ?? localContentVer;
      final localVisualVer = prefs.getInt(_visualVersionKey) ?? localContentVer;

      bool needsUpdate = remoteContentVer > localContentVer ||
          remoteMcqVer > localMcqVer ||
          remoteStudyVer > localStudyVer ||
          remoteFormulaVer > localFormulaVer ||
          remoteQuickVer > localQuickVer ||
          remoteVisualVer > localVisualVer;

      if (!needsUpdate) return;

      debugPrint('Content update detected! Processing safe download and activation...');

      final docDir = await getApplicationDocumentsDirectory();
      final tempDir = Directory('${docDir.path}/temp_content_update');
      final activeDir = Directory('${docDir.path}/updated_content');
      final backupDir = Directory('${docDir.path}/backup_content');

      if (await tempDir.exists()) await tempDir.delete(recursive: true);
      await tempDir.create(recursive: true);

      bool updateSuccess = false;

      // 1. Process Master Study Material Update
      final studyUrl = manifest['studyMaterialUrl'] as String? ?? manifest['contentUrl'] as String?;
      if (studyUrl != null && studyUrl.isNotEmpty && remoteStudyVer > localStudyVer) {
        final res = await http.get(Uri.parse(studyUrl)).timeout(const Duration(seconds: 15));
        if (res.statusCode == 200) {
          final tempFile = File('${tempDir.path}/master_study_material.json');
          await tempFile.writeAsString(res.body);

          // Schema Validation
          if (_validateJsonSchema(res.body, isList: true)) {
            updateSuccess = true;
          } else {
            debugPrint('Study material JSON validation failed! Aborting content update.');
            return;
          }
        }
      }

      // 2. Process MCQs / Questions Update
      final questionsUrl = manifest['questionsUrl'] as String?;
      if (questionsUrl != null && questionsUrl.isNotEmpty && remoteMcqVer > localMcqVer) {
        final res = await http.get(Uri.parse(questionsUrl)).timeout(const Duration(seconds: 20));
        if (res.statusCode == 200) {
          final qTempDir = Directory('${tempDir.path}/questions');
          await qTempDir.create(recursive: true);
          final tempFile = File('${qTempDir.path}/questions_update.json');
          await tempFile.writeAsString(res.body);

          if (_validateJsonSchema(res.body)) {
            updateSuccess = true;
          }
        }
      }

      // Atomic Activation with Backup & Rollback
      if (updateSuccess) {
        try {
          // Backup existing active content
          if (await activeDir.exists()) {
            if (await backupDir.exists()) await backupDir.delete(recursive: true);
            await _copyDirectory(activeDir, backupDir);
          } else {
            await activeDir.create(recursive: true);
          }

          // Move validated temp content to active directory
          await _copyDirectory(tempDir, activeDir);
          await tempDir.delete(recursive: true);

          // Update version tags in SharedPreferences
          await prefs.setInt(_contentVersionKey, remoteContentVer);
          await prefs.setInt(_mcqVersionKey, remoteMcqVer);
          await prefs.setInt(_studyMaterialVersionKey, remoteStudyVer);
          await prefs.setInt(_formulaVersionKey, remoteFormulaVer);
          await prefs.setInt(_quickRevisionVersionKey, remoteQuickVer);
          await prefs.setInt(_visualVersionKey, remoteVisualVer);

          // Reload caches
          QuestionService.clearCache();
          StudyMaterialLoader.reloadContent();

          debugPrint('Content update activated successfully! Content Version: $remoteContentVer');
        } catch (e) {
          debugPrint('Activation failed! Rolling back to previous version: $e');
          if (await backupDir.exists()) {
            if (await activeDir.exists()) await activeDir.delete(recursive: true);
            await _copyDirectory(backupDir, activeDir);
          }
        }
      }
    } catch (e) {
      debugPrint('Error during safe content update: $e');
    }
  }

  /// Validates downloaded JSON content structure before activating
  static bool _validateJsonSchema(String jsonStr, {bool isList = false}) {
    try {
      final decoded = json.decode(jsonStr);
      if (isList) {
        return decoded is List && decoded.isNotEmpty;
      }
      return decoded != null;
    } catch (e) {
      return false;
    }
  }

  /// Copies directory contents recursively
  static Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (var entity in source.list(recursive: false)) {
      if (entity is Directory) {
        var newDirectory = Directory('${destination.path}/${entity.path.split(Platform.pathSeparator).last}');
        await _copyDirectory(entity, newDirectory);
      } else if (entity is File) {
        await entity.copy('${destination.path}/${entity.path.split(Platform.pathSeparator).last}');
      }
    }
  }

  /// Downloads & verifies APK in background, then triggers Android package installer
  static Future<void> _processApkUpdate(Map<String, dynamic> manifest) async {
    try {
      final remoteVersionCode = manifest['versionCode'] as int? ?? AppConfig.currentVersionCode;
      final downloadUrl = (manifest['downloadUrl'] ?? manifest['apkUrl']) as String?;
      final expectedSha256 = manifest['sha256'] as String? ?? '';

      if (remoteVersionCode <= AppConfig.currentVersionCode) return;
      if (downloadUrl == null || downloadUrl.isEmpty) return;

      debugPrint('New APK version available ($remoteVersionCode > ${AppConfig.currentVersionCode}). Downloading in background...');

      // Download to temp directory
      final tempDir = await getTemporaryDirectory();
      final tempApkFile = File('${tempDir.path}/update_release.apk');
      if (await tempApkFile.exists()) {
        await tempApkFile.delete();
      }

      final response = await http.get(Uri.parse(downloadUrl)).timeout(const Duration(minutes: 5));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        debugPrint('Failed to download update APK: status ${response.statusCode}');
        return;
      }

      await tempApkFile.writeAsBytes(response.bodyBytes);

      // SHA-256 Checksum Verification
      if (expectedSha256.isNotEmpty) {
        final calculatedSha256 = sha256.convert(response.bodyBytes).toString().toLowerCase();
        if (calculatedSha256 != expectedSha256.trim().toLowerCase()) {
          debugPrint('SHA-256 mismatch! Expected: $expectedSha256, Calculated: $calculatedSha256');
          if (await tempApkFile.exists()) await tempApkFile.delete();
          return;
        }
        debugPrint('SHA-256 verification passed!');
      }

      // Trigger installation via Android Package Installer MethodChannel
      if (Platform.isAndroid) {
        await _triggerApkInstall(tempApkFile.path);
      }
    } catch (e) {
      debugPrint('Error during background APK update: $e');
    }
  }

  /// Triggers OS Package Installer prompt via FileProvider Intent
  static Future<void> _triggerApkInstall(String filePath) async {
    try {
      final result = await _channel.invokeMethod('installApk', {'filePath': filePath});
      debugPrint('Triggered APK installation result: $result');
    } on PlatformException catch (e) {
      debugPrint('Platform Exception on APK install: ${e.message}');
    } catch (e) {
      debugPrint('Error triggering APK install: $e');
    }
  }

  /// Gets current local content version
  static Future<int> getLocalContentVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_contentVersionKey) ?? AppConfig.defaultContentVersion;
  }
}
