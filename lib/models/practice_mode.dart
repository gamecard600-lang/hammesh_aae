enum PracticeMode {
  practice,
  topicTest,
  subjectTest,
  mockTest,
  mistakePractice,
  bookmarkPractice,
}

class PracticeConfig {
  final PracticeMode mode;
  final bool timerEnabled;
  final bool negativeMarking;
  final bool instantResult;
  final int? questionLimit;
  final int? durationMinutes;

  const PracticeConfig({
    required this.mode,
    required this.timerEnabled,
    required this.negativeMarking,
    required this.instantResult,
    this.questionLimit,
    this.durationMinutes,
  });

  static const practice = PracticeConfig(
    mode: PracticeMode.practice,
    timerEnabled: false,
    negativeMarking: false,
    instantResult: true,
  );

  static const topicTest = PracticeConfig(
    mode: PracticeMode.topicTest,
    timerEnabled: true,
    negativeMarking: true,
    instantResult: true,
  );

  static const subjectTest = PracticeConfig(
    mode: PracticeMode.subjectTest,
    timerEnabled: true,
    negativeMarking: true,
    instantResult: true,
  );

  static const mockTest = PracticeConfig(
    mode: PracticeMode.mockTest,
    timerEnabled: true,
    negativeMarking: true,
    instantResult: false,
    questionLimit: 100,
    durationMinutes: 60,
  );

  static const mistakePractice = PracticeConfig(
    mode: PracticeMode.mistakePractice,
    timerEnabled: false,
    negativeMarking: false,
    instantResult: true,
  );

  static const bookmarkPractice = PracticeConfig(
    mode: PracticeMode.bookmarkPractice,
    timerEnabled: false,
    negativeMarking: false,
    instantResult: true,
  );
}
