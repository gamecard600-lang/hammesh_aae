import 'question.dart';
import 'question_status.dart';
import 'practice_mode.dart';

class TestSession {
  final String id;
  final String sessionType; // 'mockTest' or 'practice'
  final String subject;
  final String? subTopic;
  final PracticeConfig config;
  final List<Question> questions;
  final int currentIndex;
  final List<int?> selectedAnswers;
  final List<List<int>> selectedMSQAnswers;
  final List<QuestionStatus> statuses;
  final List<int> questionTimeSpentSeconds;
  final int remainingSeconds;
  final String lastUpdated;

  TestSession({
    required this.id,
    required this.sessionType,
    required this.subject,
    this.subTopic,
    required this.config,
    required this.questions,
    required this.currentIndex,
    required this.selectedAnswers,
    required this.selectedMSQAnswers,
    required this.statuses,
    required this.questionTimeSpentSeconds,
    required this.remainingSeconds,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionType': sessionType,
      'subject': subject,
      'subTopic': subTopic,
      'config': {
        'mode': config.mode.name,
        'timerEnabled': config.timerEnabled,
        'negativeMarking': config.negativeMarking,
        'instantResult': config.instantResult,
        'questionLimit': config.questionLimit,
        'durationMinutes': config.durationMinutes,
      },
      'questions': questions.map((q) => q.toJson()).toList(),
      'currentIndex': currentIndex,
      'selectedAnswers': selectedAnswers,
      'selectedMSQAnswers': selectedMSQAnswers,
      'statuses': statuses.map((s) => s.name).toList(),
      'questionTimeSpentSeconds': questionTimeSpentSeconds,
      'remainingSeconds': remainingSeconds,
      'lastUpdated': lastUpdated,
    };
  }

  factory TestSession.fromJson(Map<String, dynamic> json) {
    // Parse PracticeConfig
    final configMap = json['config'] as Map<String, dynamic>? ?? {};
    final modeName = configMap['mode'] as String? ?? 'practice';
    final mode = PracticeMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => PracticeMode.practice,
    );
    final config = PracticeConfig(
      mode: mode,
      timerEnabled: configMap['timerEnabled'] as bool? ?? false,
      negativeMarking: configMap['negativeMarking'] as bool? ?? false,
      instantResult: configMap['instantResult'] as bool? ?? true,
      questionLimit: configMap['questionLimit'] as int?,
      durationMinutes: configMap['durationMinutes'] as int?,
    );

    // Parse Questions
    List<Question> questionsList = [];
    if (json['questions'] is List) {
      questionsList = (json['questions'] as List)
          .map((q) => Question.fromJson(Map<String, dynamic>.from(q)))
          .toList();
    }

    // Parse selectedAnswers
    List<int?> selAnswers = [];
    if (json['selectedAnswers'] is List) {
      selAnswers = (json['selectedAnswers'] as List)
          .map<int?>((e) => e == null ? null : (e as num).toInt())
          .toList();
    }

    // Parse selectedMSQAnswers
    List<List<int>> selMSQ = [];
    if (json['selectedMSQAnswers'] is List) {
      selMSQ = (json['selectedMSQAnswers'] as List)
          .map<List<int>>((sub) => sub is List
              ? sub.map<int>((e) => (e as num).toInt()).toList()
              : [])
          .toList();
    }

    // Parse statuses
    List<QuestionStatus> statList = [];
    if (json['statuses'] is List) {
      statList = (json['statuses'] as List).map((s) {
        final str = s.toString();
        return QuestionStatus.values.firstWhere(
          (qs) => qs.name == str,
          orElse: () => QuestionStatus.unanswered,
        );
      }).toList();
    }

    // Parse questionTimeSpentSeconds
    List<int> timeSpent = [];
    if (json['questionTimeSpentSeconds'] is List) {
      timeSpent = (json['questionTimeSpentSeconds'] as List)
          .map<int>((e) => (e as num).toInt())
          .toList();
    }

    return TestSession(
      id: json['id'] as String? ?? '',
      sessionType: json['sessionType'] as String? ?? 'practice',
      subject: json['subject'] as String? ?? '',
      subTopic: json['subTopic'] as String?,
      config: config,
      questions: questionsList,
      currentIndex: (json['currentIndex'] as num?)?.toInt() ?? 0,
      selectedAnswers: selAnswers,
      selectedMSQAnswers: selMSQ,
      statuses: statList,
      questionTimeSpentSeconds: timeSpent,
      remainingSeconds: (json['remainingSeconds'] as num?)?.toInt() ?? 0,
      lastUpdated: json['lastUpdated'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
