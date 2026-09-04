import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exam_history.dart';
import '../models/app_backup.dart';
import '../models/study_progress.dart';
import '../models/study_bookmark.dart';
import '../models/mistake.dart';

class LocalStorageService {
  static const String _bookmarksKey = 'bookmarked_questions_ids';
  static const String _mistakesKey = 'mistake_questions_ids';
  static const String _fullMistakesKey = 'full_mistakes_v2';
  static const String _topicMistakesKey = 'topic_mistakes';
  static const String _examHistoryKey = 'exam_history_v2';
  static const String _studyProgressKey = 'study_progress';
  static const String _studyBookmarksKey = 'study_bookmarks';
  static const String _themeModeKey = 'app_theme_mode';
  static const String _aiApiKey = 'ai_api_key';
  static const String _aiMistakeExplanationsKey = 'ai_mistake_explanations';

  // --- Theme Mode ---
  static Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode);
  }

  static Future<String> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey) ?? 'light';
  }

  // --- Bookmarks ---
  static Future<void> saveBookmarks(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_bookmarksKey, ids.map((e) => e.toString()).toList());
  }

  static Future<Set<int>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_bookmarksKey) ?? [];
    return data.map((e) => int.tryParse(e)).whereType<int>().toSet();
  }

  // --- Mistakes ---
  static Future<void> saveMistakes(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_mistakesKey, ids.map((e) => e.toString()).toList());
  }

  static Future<Set<int>> loadMistakes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_mistakesKey) ?? [];
    return data.map((e) => int.tryParse(e)).whereType<int>().toSet();
  }

  static Future<void> saveFullMistakes(List<Mistake> list) async {
    final prefs = await SharedPreferences.getInstance();
    final data = list.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(_fullMistakesKey, data);
    // Sync IDs for legacy compatibility
    await saveMistakes(list.map((m) => m.questionId).toSet());
  }

  static Future<List<Mistake>> loadFullMistakes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_fullMistakesKey);
    if (data != null && data.isNotEmpty) {
      try {
        return data.map((item) => Mistake.fromJson(jsonDecode(item))).toList();
      } catch (_) {}
    }
    return [];
  }

  // --- Topic Mistakes ---
  static Future<void> saveTopicMistakes(Map<String, int> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_topicMistakesKey, jsonEncode(data));
  }

  static Future<Map<String, int>> loadTopicMistakes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_topicMistakesKey);
    if (raw == null) return {};
    try {
      return Map<String, int>.from(jsonDecode(raw));
    } catch (e) {
      return {};
    }
  }

  // --- Exam History ---
  static Future<void> saveExamHistory(List<ExamHistory> history) async {
    final prefs = await SharedPreferences.getInstance();
    final data = history.map((e) => e.toJson()).toList();
    await prefs.setString(_examHistoryKey, jsonEncode(data));
  }

  static Future<List<ExamHistory>> loadExamHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_examHistoryKey);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((item) => ExamHistory.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<void> addExamToHistory(ExamHistory exam) async {
    final history = await loadExamHistory();
    history.insert(0, exam);
    if (history.length > 50) history.removeRange(50, history.length);
    await saveExamHistory(history);
  }

  // --- Study Progress ---
  static Future<void> saveStudyProgress(List<StudyProgress> progress) async {
    final prefs = await SharedPreferences.getInstance();
    final data = progress.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_studyProgressKey, data);
  }

  static Future<List<StudyProgress>> loadStudyProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_studyProgressKey) ?? [];
    return data.map((item) => StudyProgress.fromJson(jsonDecode(item))).toList();
  }

  static Future<void> markTopicCompleted(String subject, String topic) async {
    final progressList = await loadStudyProgress();
    final index = progressList.indexWhere((p) => p.subject == subject && p.topic == topic);
    
    final newProgress = StudyProgress(
      subject: subject,
      topic: topic,
      completed: true,
      progress: 100,
    );

    if (index != -1) {
      progressList[index] = newProgress;
    } else {
      progressList.add(newProgress);
    }
    await saveStudyProgress(progressList);
  }

  // --- Study Bookmarks ---
  static Future<void> saveStudyBookmarks(List<StudyBookmark> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    final data = bookmarks.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_studyBookmarksKey, data);
  }

  static Future<List<StudyBookmark>> loadStudyBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_studyBookmarksKey) ?? [];
    return data.map((item) => StudyBookmark.fromJson(jsonDecode(item))).toList();
  }

  static Future<void> toggleStudyBookmark(StudyBookmark bookmark) async {
    final bookmarks = await loadStudyBookmarks();
    final index = bookmarks.indexWhere((b) => 
      b.subject.trim() == bookmark.subject.trim() && 
      b.topic.trim() == bookmark.topic.trim());
    
    if (index != -1) {
      bookmarks.removeAt(index);
    } else {
      bookmarks.add(bookmark);
    }
    await saveStudyBookmarks(bookmarks);
  }

  // --- AI Settings & Cache ---
  static Future<void> saveAiApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aiApiKey, apiKey.trim());
  }

  static Future<String> loadAiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_aiApiKey) ?? '';
  }

  static Future<void> saveAiMistakeExplanation(int questionId, String explanation) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_aiMistakeExplanationsKey);
    Map<String, dynamic> map = {};
    if (raw != null) {
      try {
        map = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }
    map[questionId.toString()] = {
      'explanation': explanation,
      'date': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_aiMistakeExplanationsKey, jsonEncode(map));
  }

  static Future<Map<int, Map<String, dynamic>>> loadAiMistakeExplanations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_aiMistakeExplanationsKey);
    if (raw == null) return {};
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      final Map<int, Map<String, dynamic>> result = {};
      decoded.forEach((key, value) {
        final id = int.tryParse(key);
        if (id != null && value is Map<String, dynamic>) {
          result[id] = value;
        }
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  // --- Backup & Restore ---
  static Future<String> generateBackupJson() async {
    final backup = AppBackup(
      version: 2,
      createdAt: DateTime.now().toIso8601String(),
      bookmarks: await loadBookmarks(),
      mistakes: await loadMistakes(),
      topicMistakes: await loadTopicMistakes(),
      examHistory: await loadExamHistory(),
      studyProgress: await loadStudyProgress(),
      studyBookmarks: await loadStudyBookmarks(),
    );
    return jsonEncode(backup.toJson());
  }

  static Future<void> restoreFromBackupJson(String json) async {
    final decoded = jsonDecode(json);
    final backup = AppBackup.fromJson(decoded);

    // Save all to local storage
    await saveBookmarks(backup.bookmarks);
    await saveMistakes(backup.mistakes);
    await saveTopicMistakes(backup.topicMistakes);
    await saveExamHistory(backup.examHistory);
    await saveStudyProgress(backup.studyProgress);
    await saveStudyBookmarks(backup.studyBookmarks);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
