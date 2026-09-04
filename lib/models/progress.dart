class Progress {
  final String subject;
  final String subTopic;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int attemptedQuestions;

  Progress({
    required this.subject,
    required this.subTopic,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.attemptedQuestions,
  });

  double get accuracy {
    if (attemptedQuestions == 0) return 0;
    return (correctAnswers / attemptedQuestions) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'subTopic': subTopic,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'attemptedQuestions': attemptedQuestions,
    };
  }

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      subject: json['subject'] ?? '',
      subTopic: json['subTopic'] ?? '',
      totalQuestions: json['totalQuestions'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      wrongAnswers: json['wrongAnswers'] ?? 0,
      attemptedQuestions: json['attemptedQuestions'] ?? 0,
    );
  }
}
