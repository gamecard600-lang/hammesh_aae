class AiContext {
  final String? subject;
  final String? topic;
  final String? subtopic;
  final String? studyMaterialText;
  final String? questionText;
  final String? gujaratiQuestionText;
  final List<String>? options;
  final dynamic correctAnswer; // int or List<int>
  final dynamic userSelectedAnswer; // int or List<int>
  final String? existingExplanation;
  final String? userPerformanceSummary;

  const AiContext({
    this.subject,
    this.topic,
    this.subtopic,
    this.studyMaterialText,
    this.questionText,
    this.gujaratiQuestionText,
    this.options,
    this.correctAnswer,
    this.userSelectedAnswer,
    this.existingExplanation,
    this.userPerformanceSummary,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'topic': topic,
      'subtopic': subtopic,
      'studyMaterialText': studyMaterialText,
      'questionText': questionText,
      'gujaratiQuestionText': gujaratiQuestionText,
      'options': options,
      'correctAnswer': correctAnswer,
      'userSelectedAnswer': userSelectedAnswer,
      'existingExplanation': existingExplanation,
      'userPerformanceSummary': userPerformanceSummary,
    };
  }

  String toFormattedPrompt() {
    final StringBuffer sb = StringBuffer();
    if (subject != null && subject!.isNotEmpty) {
      sb.writeln('Subject: $subject');
    }
    if (topic != null && topic!.isNotEmpty) {
      sb.writeln('Topic: $topic');
    }
    if (subtopic != null && subtopic!.isNotEmpty) {
      sb.writeln('Subtopic: $subtopic');
    }
    if (studyMaterialText != null && studyMaterialText!.isNotEmpty) {
      sb.writeln('Study Material Context:\n$studyMaterialText');
    }
    if (questionText != null && questionText!.isNotEmpty) {
      sb.writeln('Question: $questionText');
    }
    if (gujaratiQuestionText != null && gujaratiQuestionText!.isNotEmpty) {
      sb.writeln('Gujarati Question: $gujaratiQuestionText');
    }
    if (options != null && options!.isNotEmpty) {
      sb.writeln('Options:');
      for (int i = 0; i < options!.length; i++) {
        sb.writeln('  ${String.fromCharCode(65 + i)}. ${options![i]}');
      }
    }
    if (correctAnswer != null) {
      sb.writeln('Correct Answer Index/Key: $correctAnswer');
    }
    if (userSelectedAnswer != null) {
      sb.writeln('User Selected Answer Index/Key: $userSelectedAnswer');
    }
    if (existingExplanation != null && existingExplanation!.isNotEmpty) {
      sb.writeln('Existing App Explanation: $existingExplanation');
    }
    if (userPerformanceSummary != null && userPerformanceSummary!.isNotEmpty) {
      sb.writeln('User Performance Context: $userPerformanceSummary');
    }
    return sb.toString();
  }
}
