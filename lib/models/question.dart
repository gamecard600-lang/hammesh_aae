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
    final raw = json['correctAnswers'];
    final List<int> correctAnswers = raw is List ? raw.whereType<num>().map((e) => e.toInt()).toList() : <int>[];
    final fallback = json['correctAnswer'] is num ? (json['correctAnswer'] as num).toInt() : null;
    if (correctAnswers.isEmpty && fallback != null) correctAnswers.add(fallback);

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

  /// Identifies if a question is explicitly a Previous Year Question (PYQ)
  bool get isPYQ {
    final text = '$question $gujaratiQuestion $explanation $subTopic'.toLowerCase();
    return explanation.contains('[cite:') ||
        text.contains('pyq') ||
        text.contains('gsssb') ||
        text.contains('gpsc') ||
        text.contains('ssc') ||
        text.contains('gate') ||
        text.contains('p.y.q') ||
        text.contains('previous year');
  }

  /// Identifies if a question is an Expected / High Probability question
  bool get isExpected {
    final text = '$question $gujaratiQuestion $explanation $subTopic'.toLowerCase();
    return text.contains('expected') ||
        text.contains('predicted') ||
        text.contains('high yield') ||
        text.contains('high probability');
  }

  /// Identifies if a question is a Previous Year Question (PYQ) or High Difficulty / Conceptual
  bool get isHardOrPYQ {
    final text = '$question $gujaratiQuestion $explanation $subTopic'.toLowerCase();
    final bool hasPyqCite = isPYQ ||
        text.contains('exam');

    final bool isComplex = isMSQ ||
        explanation.length > 40 ||
        options.any((opt) => RegExp(r'\d+').hasMatch(opt));

    return hasPyqCite || isComplex;
  }
}
