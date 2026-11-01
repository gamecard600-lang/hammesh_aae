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
  final String? examSource;

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
    this.examSource,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final raw = json['correctAnswers'];
    final List<int> correctAnswers = raw is List ? raw.whereType<num>().map((e) => e.toInt()).toList() : <int>[];
    final fallback = json['correctAnswer'] is num ? (json['correctAnswer'] as num).toInt() : null;
    if (correctAnswers.isEmpty && fallback != null) correctAnswers.add(fallback);

    final bool isMSQ = json['isMSQ'] as bool? ?? correctAnswers.length > 1;

    String exp = (json['explanation'] as String? ?? '').trim();
    String? src = (json['examSource'] ?? json['exam_source'] ?? json['pyqReference'] ?? json['source'])?.toString().trim();
    if (src != null && src.isEmpty) src = null;

    // Extract exam source from explanation if not explicitly set in json
    if (src == null || src.isEmpty) {
      final citeMatch = RegExp(r'(?:📌\s*)?\[(?:Exam Source / PYQ Reference:?\s*\[?|cite:\s*)([^\]]+)\]\]?', caseSensitive: false).firstMatch(exp);
      if (citeMatch != null) {
        final extracted = citeMatch.group(1)!.trim();
        if (extracted.isNotEmpty && extracted != '1' && extracted != '2' && extracted != '3' && extracted != '4' && extracted != '5' && extracted != '6' && extracted != '7' && extracted != '8' && extracted != '9' && extracted != '10') {
          src = extracted;
        }
      }
    }

    // Strip trailing [Exam Source / PYQ Reference: ...] line from explanation to prevent duplicate display at bottom
    exp = exp.replaceAll(RegExp(r'(?:📌\s*)?\[Exam Source / PYQ Reference:?\s*\[?[^\]]+\]\]?', caseSensitive: false), '').trim();

    // Check if json explicitly flagged isPYQ
    final bool explicitPyq = json['isPYQ'] == true || json['is_pyq'] == true;

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
      explanation: exp,
      examSource: src ?? (explicitPyq ? 'GSSSB AAE Genuine PYQ' : null),
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
      if (examSource != null && examSource!.isNotEmpty) 'examSource': examSource,
    };
  }

  /// Identifies if a question is explicitly a Previous Year Question (PYQ)
  bool get isPYQ => examSource != null && examSource!.isNotEmpty;

  /// Identifies if a question is an Expected / High Probability question
  bool get isExpected {
    final text = '$question $gujaratiQuestion $explanation $subTopic'.toLowerCase();
    return !isPYQ && (text.contains('expected') ||
        text.contains('predicted') ||
        text.contains('high yield') ||
        text.contains('high probability'));
  }

  /// Identifies if a question is a Previous Year Question (PYQ) or High Difficulty / Conceptual
  bool get isHardOrPYQ {
    final bool isComplex = isMSQ ||
        explanation.length > 40 ||
        options.any((opt) => RegExp(r'\d+').hasMatch(opt));

    return isPYQ || isComplex;
  }
}
