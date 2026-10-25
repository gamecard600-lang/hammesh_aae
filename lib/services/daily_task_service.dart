import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_task.dart';
import '../models/question.dart';
import 'question_service.dart';

class DailyTaskService {
  static const String _sessionPrefix = 'daily_task_session_';
  static const String _shownHistoryKey = 'daily_task_shown_question_ids_v1';

  static String getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  /// Loads today's session or generates a new 10-question Daily Task session.
  static Future<DailyTaskSession> getTodaySession() async {
    final today = getTodayDateString();
    final prefs = await SharedPreferences.getInstance();
    final rawSession = prefs.getString('$_sessionPrefix$today');

    if (rawSession != null && rawSession.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawSession);
        return DailyTaskSession.fromJson(decoded);
      } catch (e) {
        debugPrint('Error parsing today session: $e');
      }
    }

    // Generate new session for today
    final session = await _generateNewDailySession(today);
    await saveSession(session);
    return session;
  }

  /// Saves session data for a specific date
  static Future<void> saveSession(DailyTaskSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_sessionPrefix${session.date}',
      jsonEncode(session.toJson()),
    );
  }

  /// Generates a randomized 10-question Daily Task covering all subjects evenly with 50% PYQs
  static Future<DailyTaskSession> _generateNewDailySession(String dateStr) async {
    final Map<String, List<Question>> pyqsBySubject = {};
    final Map<String, List<Question>> allBySubject = {};

    for (final subject in QuestionService.subjectFiles.keys) {
      final subjectQuestions = await QuestionService.loadQuestionsBySubject(subject);
      if (subjectQuestions.isNotEmpty) {
        allBySubject[subject] = List.from(subjectQuestions);
        final pyqs = subjectQuestions.where((q) => q.isPYQ || q.isHardOrPYQ).toList();
        if (pyqs.isNotEmpty) {
          pyqsBySubject[subject] = pyqs;
        } else {
          pyqsBySubject[subject] = List.from(subjectQuestions);
        }
      }
    }

    if (allBySubject.isEmpty) {
      return DailyTaskSession(date: dateStr, questionIds: []);
    }

    final prefs = await SharedPreferences.getInstance();
    final List<String> shownHistoryRaw = prefs.getStringList(_shownHistoryKey) ?? [];
    final Set<int> recentlyShownIds = shownHistoryRaw
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .toSet();

    final List<Question> selected = [];
    final Set<String> usedSubjects = {};

    // Get all available subjects and shuffle them for today
    final allSubjects = QuestionService.subjectFiles.keys.toList()..shuffle(Random());

    // Step 1: Pick 5 PYQ questions from 5 distinct subjects (50% PYQs)
    for (final subject in allSubjects) {
      if (selected.length >= 5) break;
      final candidates = (pyqsBySubject[subject] ?? [])
          .where((q) => !recentlyShownIds.contains(q.id) && !selected.any((s) => s.id == q.id))
          .toList();

      if (candidates.isNotEmpty) {
        candidates.shuffle(Random());
        selected.add(candidates.first);
        usedSubjects.add(subject);
      }
    }

    // Fallback for Step 1 if less than 5 PYQs found from distinct subjects:
    if (selected.length < 5) {
      for (final subject in allSubjects) {
        if (selected.length >= 5) break;
        final candidates = (allBySubject[subject] ?? [])
            .where((q) => !selected.any((s) => s.id == q.id))
            .toList();
        if (candidates.isNotEmpty) {
          candidates.shuffle(Random());
          selected.add(candidates.first);
          usedSubjects.add(subject);
        }
      }
    }

    // Step 2: Pick 5 questions from remaining unused subjects to cover all 14 subjects evenly
    final remainingSubjects = allSubjects.where((s) => !usedSubjects.contains(s)).toList()..shuffle(Random());

    for (final subject in remainingSubjects) {
      if (selected.length >= 10) break;
      final candidates = (allBySubject[subject] ?? [])
          .where((q) => !recentlyShownIds.contains(q.id) && !selected.any((s) => s.id == q.id))
          .toList();

      if (candidates.isNotEmpty) {
        candidates.shuffle(Random());
        selected.add(candidates.first);
        usedSubjects.add(subject);
      }
    }

    // Step 3: If still under 10 questions, fill from any remaining subjects
    int loopSafety = 0;
    while (selected.length < 10 && loopSafety < 30) {
      loopSafety++;
      for (final subject in allSubjects) {
        if (selected.length >= 10) break;
        final candidates = (allBySubject[subject] ?? [])
            .where((q) => !selected.any((s) => s.id == q.id))
            .toList();
        if (candidates.isNotEmpty) {
          candidates.shuffle(Random());
          selected.add(candidates.first);
        }
      }
    }

    final selectedIds = selected.take(10).map((q) => q.id).toList();

    // Update recently shown history (keep last 120 IDs to rotate properly)
    List<int> updatedHistory = [...selectedIds, ...recentlyShownIds];
    if (updatedHistory.length > 120) {
      updatedHistory = updatedHistory.sublist(0, 120);
    }
    await prefs.setStringList(_shownHistoryKey, updatedHistory.map((e) => e.toString()).toList());

    return DailyTaskSession(
      date: dateStr,
      questionIds: selectedIds,
    );
  }

  static Future<int> getTodayStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('daily_study_streak_v1') ?? 1;
  }

  static Future<void> incrementStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final streak = (prefs.getInt('daily_study_streak_v1') ?? 1) + 1;
    await prefs.setInt('daily_study_streak_v1', streak);
  }
}
