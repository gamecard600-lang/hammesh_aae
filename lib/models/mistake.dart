class Mistake {
  final int questionId;
  final String subject;
  final String subTopic;
  final String question;
  final String gujaratiQuestion;
  final List<String> options;
  final int correctAnswer;
  final List<int> correctAnswers;
  final bool isMSQ;
  final String explanation;
  final int wrongCount;
  final String lastWrongDate;
  final int? userWrongAnswer;
  final List<int> userWrongAnswers;

  Mistake({
    required this.questionId,
    required this.subject,
    required this.subTopic,
    required this.question,
    required this.gujaratiQuestion,
    required this.options,
    required this.correctAnswer,
    required this.correctAnswers,
    required this.isMSQ,
    required this.explanation,
    this.wrongCount = 1,
    String? lastWrongDate,
    this.userWrongAnswer,
    this.userWrongAnswers = const [],
  }) : lastWrongDate = lastWrongDate ?? DateTime.now().toIso8601String();

  Mistake copyWith({
    int? wrongCount,
    String? lastWrongDate,
    int? userWrongAnswer,
    List<int>? userWrongAnswers,
    String? explanation,
  }) {
    return Mistake(
      questionId: questionId,
      subject: subject,
      subTopic: subTopic,
      question: question,
      gujaratiQuestion: gujaratiQuestion,
      options: options,
      correctAnswer: correctAnswer,
      correctAnswers: correctAnswers,
      isMSQ: isMSQ,
      explanation: explanation ?? this.explanation,
      wrongCount: wrongCount ?? this.wrongCount,
      lastWrongDate: lastWrongDate ?? this.lastWrongDate,
      userWrongAnswer: userWrongAnswer ?? this.userWrongAnswer,
      userWrongAnswers: userWrongAnswers ?? this.userWrongAnswers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'subject': subject,
      'subTopic': subTopic,
      'question': question,
      'gujaratiQuestion': gujaratiQuestion,
      'options': options,
      'correctAnswer': correctAnswer,
      'correctAnswers': correctAnswers,
      'isMSQ': isMSQ,
      'explanation': explanation,
      'wrongCount': wrongCount,
      'lastWrongDate': lastWrongDate,
      'userWrongAnswer': userWrongAnswer,
      'userWrongAnswers': userWrongAnswers,
    };
  }

  factory Mistake.fromJson(Map<String, dynamic> json) {
    final correctAnswers = (json['correctAnswers'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        [
          (json['correctAnswer'] as num?)?.toInt() ?? 0
        ];

    final isMSQ = json['isMSQ'] as bool? ?? correctAnswers.length > 1;

    final userWrongAnswers = (json['userWrongAnswers'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        [];

    return Mistake(
      questionId: (json['questionId'] as num?)?.toInt() ?? 0,
      subject: json['subject'] as String? ?? '',
      subTopic: json['subTopic'] as String? ?? '',
      question: json['question'] as String? ?? '',
      gujaratiQuestion: json['gujaratiQuestion'] as String? ?? '',
      options: (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
      correctAnswer: (json['correctAnswer'] as num?)?.toInt() ?? correctAnswers.first,
      correctAnswers: correctAnswers,
      isMSQ: isMSQ,
      explanation: json['explanation'] as String? ?? '',
      wrongCount: (json['wrongCount'] as num?)?.toInt() ?? 1,
      lastWrongDate: json['lastWrongDate'] as String? ?? DateTime.now().toIso8601String(),
      userWrongAnswer: (json['userWrongAnswer'] as num?)?.toInt(),
      userWrongAnswers: userWrongAnswers,
    );
  }
}
