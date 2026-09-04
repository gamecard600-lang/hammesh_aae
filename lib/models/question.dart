class Question {
  final int id;
  final String subject;
  final String subTopic;
  final String question;
  final String gujaratiQuestion;
  final List<String> options;
  final int correctAnswer;
  final List<int> correctAnswers;
  final bool isMSQ;
  final String explanation;

  const Question({
    required this.id,
    required this.subject,
    required this.subTopic,
    required this.question,
    required this.gujaratiQuestion,
    required this.options,
    required this.correctAnswer,
    required this.correctAnswers,
    required this.isMSQ,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final List<int> correctAnswers = json['correctAnswers'] is List
        ? (json['correctAnswers'] as List)
            .map<int>((e) => (e as num?)?.toInt() ?? 0)
            .toList()
        : [
            (json['correctAnswer'] as num?)?.toInt() ?? 0
          ];

    final bool isMSQ = json['isMSQ'] as bool? ?? correctAnswers.length > 1;

    return Question(
      id: (json['id'] as num?)?.toInt() ?? 0,
      subject: (json['subject'] as String? ?? '').trim(),
      subTopic: (json['subTopic'] as String? ?? '').trim(),
      question: (json['question'] as String? ?? '').trim(),
      gujaratiQuestion: (json['gujaratiQuestion'] as String? ?? '').trim(),
      options: json['options'] is List
          ? (json['options'] as List)
              .map<String>((e) => e?.toString().trim() ?? '')
              .toList()
          : [],
      correctAnswer: (json['correctAnswer'] as num?)?.toInt() ??
          (correctAnswers.isNotEmpty ? correctAnswers.first : 0),
      correctAnswers: correctAnswers,
      isMSQ: isMSQ,
      explanation: (json['explanation'] as String? ?? '').trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'subTopic': subTopic,
      'question': question,
      'gujaratiQuestion': gujaratiQuestion,
      'options': options,
      'correctAnswer': correctAnswer,
      'correctAnswers': correctAnswers,
      'isMSQ': isMSQ,
      'explanation': explanation,
    };
  }

  /// Identifies if a question is a Previous Year Question (PYQ) or High Difficulty / Conceptual
  bool get isHardOrPYQ {
    final text = '$question $gujaratiQuestion $explanation $subTopic'.toLowerCase();
    final bool hasPyqCite = explanation.contains('[cite:') ||
        text.contains('pyq') ||
        text.contains('gsssb') ||
        text.contains('gpsc') ||
        text.contains('gate') ||
        text.contains('ssc') ||
        text.contains('exam');

    final bool isComplex = isMSQ ||
        explanation.length > 40 ||
        options.any((opt) => RegExp(r'\d+').hasMatch(opt));

    return hasPyqCite || isComplex;
  }
}
