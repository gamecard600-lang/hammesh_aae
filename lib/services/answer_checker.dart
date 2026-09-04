class AnswerChecker {
  static bool isCorrect({
    required bool isMSQ,
    required int? selectedAnswer,
    required List<int> selectedAnswers,
    required int correctAnswer,
    required List<int> correctAnswers,
  }) {
    if (isMSQ) {
      final selected = List<int>.from(selectedAnswers);
      final correct = List<int>.from(correctAnswers);

      selected.sort();
      correct.sort();

      return selected.length == correct.length &&
          _listsEqual(selected, correct);
    }

    return selectedAnswer == correctAnswer;
  }

  static bool _listsEqual(
    List<int> a,
    List<int> b,
  ) {
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }
}
