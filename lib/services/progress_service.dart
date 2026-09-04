import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/progress.dart';

class ProgressService {
  static const String _progressKey = 'mcq_progress';

  static Future<List<Progress>> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final String? data = prefs.getString(_progressKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    final List<dynamic> jsonData = jsonDecode(data);

    return jsonData
        .map((json) => Progress.fromJson(json))
        .toList();
  }

  static Future<void> saveProgress(Progress progress) async {
    final progressList = await loadProgress();

    final index = progressList.indexWhere(
      (item) =>
          item.subject == progress.subject &&
          item.subTopic == progress.subTopic,
    );

    if (index >= 0) {
      progressList[index] = progress;
    } else {
      progressList.add(progress);
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _progressKey,
      jsonEncode(
        progressList.map((item) => item.toJson()).toList(),
      ),
    );
  }

  static Future<Progress?> getProgress(
    String subject,
    String subTopic,
  ) async {
    final progressList = await loadProgress();

    try {
      return progressList.firstWhere(
        (item) =>
            item.subject == subject &&
            item.subTopic == subTopic,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
  }
}
