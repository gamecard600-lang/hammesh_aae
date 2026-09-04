class DailyTaskSession {
  final String date; // Format: 'YYYY-MM-DD'
  final List<int> questionIds;
  final Map<int, int> selectedAnswers; // questionId -> selectedOption Index
  final bool completed;
  final int correctCount;
  final int wrongCount;
  final double score;
  final double accuracy;
  final int timeTakenSeconds;

  DailyTaskSession({
    required this.date,
    required this.questionIds,
    this.selectedAnswers = const {},
    this.completed = false,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.score = 0.0,
    this.accuracy = 0.0,
    this.timeTakenSeconds = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'questionIds': questionIds,
      'selectedAnswers': selectedAnswers.map((k, v) => MapEntry(k.toString(), v)),
      'completed': completed,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'score': score,
      'accuracy': accuracy,
      'timeTakenSeconds': timeTakenSeconds,
    };
  }

  factory DailyTaskSession.fromJson(Map<String, dynamic> json) {
    final Map<int, int> answers = {};
    if (json['selectedAnswers'] is Map) {
      (json['selectedAnswers'] as Map).forEach((k, v) {
        final qId = int.tryParse(k.toString());
        final ans = (v as num?)?.toInt();
        if (qId != null && ans != null) {
          answers[qId] = ans;
        }
      });
    }

    return DailyTaskSession(
      date: json['date'] as String? ?? '',
      questionIds: json['questionIds'] is List
          ? (json['questionIds'] as List).map((e) => (e as num).toInt()).toList()
          : [],
      selectedAnswers: answers,
      completed: json['completed'] as bool? ?? false,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      wrongCount: (json['wrongCount'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      timeTakenSeconds: (json['timeTakenSeconds'] as num?)?.toInt() ?? 0,
    );
  }
}
