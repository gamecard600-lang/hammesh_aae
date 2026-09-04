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

  /// Generates a randomized, balanced 10-question set for today prioritizing Hard Questions & PYQs while avoiding recent questions
  static Future<DailyTaskSession> _generateNewDailySession(String dateStr) async {
    final List<Question> allQuestions = [];

    for (final subject in QuestionService.subjectFiles.keys) {
      final subjectQuestions = await QuestionService.loadQuestionsBySubject(subject);
      allQuestions.addAll(subjectQuestions);
    }

    if (allQuestions.isEmpty) {
      return DailyTaskSession(date: dateStr, questionIds: []);
    }

    final prefs = await SharedPreferences.getInstance();
    final List<String> shownHistoryRaw = prefs.getStringList(_shownHistoryKey) ?? [];
    final Set<int> recentlyShownIds = shownHistoryRaw
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .toSet();

    // 1. First priority: Hard & PYQ questions that have NOT been recently shown
    List<Question> primaryCandidates = allQuestions
        .where((q) => q.isHardOrPYQ && !recentlyShownIds.contains(q.id))
        .toList();

    // 2. Second priority: Any unused questions that have NOT been recently shown
    if (primaryCandidates.length < 10) {
      final additional = allQuestions
          .where((q) => !recentlyShownIds.contains(q.id) && !primaryCandidates.contains(q))
          .toList();
      primaryCandidates.addAll(additional);
    }

    // 3. Fallback: If still under 10, include all Hard & PYQ questions
    if (primaryCandidates.length < 10) {
      final hardAndPyqAll = allQuestions.where((q) => q.isHardOrPYQ).toList();
      primaryCandidates = List.from(hardAndPyqAll);
    }

    // 4. Ultimate Fallback: All questions
    if (primaryCandidates.length < 10) {
      primaryCandidates = List.from(allQuestions);
    }

    // Shuffle and pick 10 questions with balanced subject distribution
    primaryCandidates.shuffle(Random());

    final Map<String, List<Question>> bySubject = {};
    for (var q in primaryCandidates) {
      bySubject.putIfAbsent(q.subject, () => []).add(q);
    }

    final List<Question> selected = [];
    final subjects = bySubject.keys.toList()..shuffle(Random());

    // Round-robin selection across subjects for balance
    int subjectIdx = 0;
    while (selected.length < 10 && primaryCandidates.isNotEmpty) {
      if (subjects.isEmpty) break;
      final sub = subjects[subjectIdx % subjects.length];
      if (bySubject[sub] != null && bySubject[sub]!.isNotEmpty) {
        final q = bySubject[sub]!.removeAt(0);
        if (!selected.any((s) => s.id == q.id)) {
          selected.add(q);
        }
      }
      subjectIdx++;

      if (bySubject.values.every((list) => list.isEmpty)) {
        break;
      }
    }

    // If still less than 10, fill from all questions
    if (selected.length < 10) {
      allQuestions.shuffle(Random());
      for (var q in allQuestions) {
        if (!selected.any((s) => s.id == q.id)) {
          selected.add(q);
          if (selected.length >= 10) break;
        }
      }
    }

    final selectedIds = selected.take(10).map((q) => q.id).toList();

    // Update recently shown history (keep last 150 IDs to avoid long term repeats)
    List<int> updatedHistory = [...selectedIds, ...recentlyShownIds];
    if (updatedHistory.length > 150) {
      updatedHistory = updatedHistory.sublist(0, 150);
    }
    await prefs.setStringList(
      _shownHistoryKey,
      updatedHistory.map((e) => e.toString()).toList(),
    );

    return DailyTaskSession(
      date: dateStr,
      questionIds: selectedIds,
    );
  }
}
