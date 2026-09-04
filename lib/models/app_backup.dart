import 'exam_history.dart';
import 'study_progress.dart';
import 'study_bookmark.dart';

class AppBackup {
  final int version;
  final String createdAt;
  final Set<int> bookmarks;
  final Set<int> mistakes;
  final Map<String, int> topicMistakes;
  final List<ExamHistory> examHistory;
  final List<StudyProgress> studyProgress;
  final List<StudyBookmark> studyBookmarks;

  AppBackup({
    required this.version,
    required this.createdAt,
    required this.bookmarks,
    required this.mistakes,
    required this.topicMistakes,
    required this.examHistory,
    required this.studyProgress,
    required this.studyBookmarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'createdAt': createdAt,
      'bookmarks': bookmarks.toList(),
      'mistakes': mistakes.toList(),
      'topicMistakes': topicMistakes,
      'examHistory': examHistory.map((e) => e.toJson()).toList(),
      'studyProgress': studyProgress.map((e) => e.toJson()).toList(),
      'studyBookmarks': studyBookmarks.map((e) => e.toJson()).toList(),
    };
  }

  factory AppBackup.fromJson(Map<String, dynamic> json) {
    return AppBackup(
      version: json['version'] ?? 1,
      createdAt: json['createdAt'] ?? '',
      bookmarks: (json['bookmarks'] as List?)?.map((e) => e as int).toSet() ?? {},
      mistakes: (json['mistakes'] as List?)?.map((e) => e as int).toSet() ?? {},
      topicMistakes: Map<String, int>.from(json['topicMistakes'] ?? {}),
      examHistory: (json['examHistory'] as List?)
              ?.map((e) => ExamHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      studyProgress: (json['studyProgress'] as List?)
              ?.map((e) => StudyProgress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      studyBookmarks: (json['studyBookmarks'] as List?)
              ?.map((e) => StudyBookmark.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
