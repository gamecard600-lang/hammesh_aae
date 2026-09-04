import '../models/mistake.dart';
import 'local_storage_service.dart';
import 'question_service.dart';

class MistakeService {
  static Future<List<Mistake>> loadMistakes() async {
    final fullList = await LocalStorageService.loadFullMistakes();
    if (fullList.isNotEmpty) return fullList;

    // Fallback for legacy stored IDs
    final ids = await LocalStorageService.loadMistakes();
    if (ids.isEmpty) return [];

    final questions = await QuestionService.getQuestionsByIds(ids.toList());
    final legacyList = questions.map((q) => Mistake(
      questionId: q.id,
      subject: q.subject,
      subTopic: q.subTopic,
      question: q.question,
      gujaratiQuestion: q.gujaratiQuestion,
      options: q.options,
      correctAnswer: q.correctAnswer,
      correctAnswers: q.correctAnswers,
      isMSQ: q.isMSQ,
      explanation: q.explanation,
      wrongCount: 1,
      lastWrongDate: DateTime.now().toIso8601String(),
    )).toList();

    if (legacyList.isNotEmpty) {
      await LocalStorageService.saveFullMistakes(legacyList);
    }

    return legacyList;
  }

  static Future<void> addOrUpdateMistake(Mistake mistake) async {
    final list = await loadMistakes();
    final index = list.indexWhere((m) => m.questionId == mistake.questionId);

    final nowStr = DateTime.now().toIso8601String();

    if (index != -1) {
      final existing = list[index];
      list[index] = existing.copyWith(
        wrongCount: existing.wrongCount + 1,
        lastWrongDate: nowStr,
        userWrongAnswer: mistake.userWrongAnswer ?? existing.userWrongAnswer,
        userWrongAnswers: mistake.userWrongAnswers.isNotEmpty
            ? mistake.userWrongAnswers
            : existing.userWrongAnswers,
        explanation: mistake.explanation.isNotEmpty
            ? mistake.explanation
            : existing.explanation,
      );
    } else {
      list.insert(
        0,
        mistake.copyWith(
          wrongCount: 1,
          lastWrongDate: nowStr,
        ),
      );
    }

    await LocalStorageService.saveFullMistakes(list);
  }

  static Future<void> addMistake(Mistake mistake) async {
    await addOrUpdateMistake(mistake);
  }

  static Future<void> removeMistake(int questionId) async {
    final list = await loadMistakes();
    list.removeWhere((m) => m.questionId == questionId);
    await LocalStorageService.saveFullMistakes(list);
  }

  static Future<void> clearMistakes() async {
    await LocalStorageService.saveFullMistakes([]);
    await LocalStorageService.saveMistakes({});
  }
}
