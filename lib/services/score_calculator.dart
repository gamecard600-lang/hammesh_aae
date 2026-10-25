class ScoreCalculator {
  static double calculate({
    required int totalQuestions,
    required int correct,
    required int wrong,
    required int skipped,
    required double marksPerQuestion,
    required double negativeMarking,
  }) {
    final positiveMarks = correct * marksPerQuestion;
    final negativeMarks = wrong * negativeMarking;

    return positiveMarks - negativeMarks;
  }

  static double percentage({
    required double score,
    required int totalQuestions,
    required double marksPerQuestion,
  }) {
    final totalMarks = totalQuestions * marksPerQuestion;

    if (totalMarks <= 0) return 0;

    return (score / totalMarks) * 100;
  }
}
