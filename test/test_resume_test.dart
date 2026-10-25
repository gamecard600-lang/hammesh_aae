import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hammesh_aae/models/question.dart';
import 'package:hammesh_aae/models/question_status.dart';
import 'package:hammesh_aae/models/practice_mode.dart';
import 'package:hammesh_aae/models/test_session.dart';
import 'package:hammesh_aae/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final List<Question> sampleQuestions = [
    Question(
      id: 101,
      subject: 'Fluid Mechanics',
      subTopic: 'Properties of Fluids',
      question: 'What is the unit of dynamic viscosity?',
      gujaratiQuestion: 'ડાયનેમિક વિસ્કોસિટીનો એકમ શું છે?',
      options: ['Pa·s', 'N/m', 'J/s', 'W/m·K'],
      correctAnswer: 0,
      correctAnswers: const [],
      isMSQ: false,
      explanation: 'Pa·s or N·s/m² is the SI unit of dynamic viscosity.',
    ),
    Question(
      id: 102,
      subject: 'Thermodynamics',
      subTopic: 'First Law',
      question: 'First law of thermodynamics relates to?',
      gujaratiQuestion: 'થર્મોડાયનેમિક્સનો પ્રથમ નિયમ કોની સાથે સંબંધિત છે?',
      options: ['Energy Conservation', 'Entropy', 'Temperature', 'Pressure'],
      correctAnswer: 0,
      correctAnswers: const [],
      isMSQ: false,
      explanation: 'First law represents conservation of energy.',
    ),
  ];

  test('TestSession toJson and fromJson preserves all session state', () {
    final session = TestSession(
      id: 'mock_123',
      sessionType: 'mockTest',
      subject: 'Mock Test',
      subTopic: null,
      config: PracticeConfig.mockTest,
      questions: sampleQuestions,
      currentIndex: 1,
      selectedAnswers: [0, null],
      selectedMSQAnswers: [[], []],
      statuses: [QuestionStatus.answered, QuestionStatus.unanswered],
      questionTimeSpentSeconds: [15, 0],
      remainingSeconds: 3500,
      lastUpdated: DateTime.now().toIso8601String(),
    );

    final json = session.toJson();
    final restored = TestSession.fromJson(json);

    expect(restored.sessionType, equals('mockTest'));
    expect(restored.subject, equals('Mock Test'));
    expect(restored.questions.length, equals(2));
    expect(restored.questions[0].id, equals(101));
    expect(restored.questions[1].id, equals(102));
    expect(restored.currentIndex, equals(1));
    expect(restored.selectedAnswers[0], equals(0));
    expect(restored.selectedAnswers[1], isNull);
    expect(restored.statuses[0], equals(QuestionStatus.answered));
    expect(restored.statuses[1], equals(QuestionStatus.unanswered));
    expect(restored.remainingSeconds, equals(3500));
  });

  test('LocalStorageService saves, loads and clears Mock Test session', () async {
    final session = TestSession(
      id: 'mock_999',
      sessionType: 'mockTest',
      subject: 'Mock Test',
      subTopic: null,
      config: PracticeConfig.mockTest,
      questions: sampleQuestions,
      currentIndex: 1,
      selectedAnswers: [0, null],
      selectedMSQAnswers: [[], []],
      statuses: [QuestionStatus.answered, QuestionStatus.unanswered],
      questionTimeSpentSeconds: [20, 5],
      remainingSeconds: 3200,
      lastUpdated: DateTime.now().toIso8601String(),
    );

    await LocalStorageService.saveTestSession(session);

    final loaded = await LocalStorageService.loadTestSession('mockTest');
    expect(loaded, isNotNull);
    expect(loaded!.currentIndex, equals(1));
    expect(loaded.questions.length, equals(2));
    expect(loaded.selectedAnswers[0], equals(0));

    // Clear session
    await LocalStorageService.clearTestSession('mockTest');
    final cleared = await LocalStorageService.loadTestSession('mockTest');
    expect(cleared, isNull);
  });

  test('LocalStorageService saves, loads and clears Practice session', () async {
    final session = TestSession(
      id: 'prac_555',
      sessionType: 'practice',
      subject: 'Fluid Mechanics',
      subTopic: 'Properties of Fluids',
      config: PracticeConfig.practice,
      questions: [sampleQuestions[0]],
      currentIndex: 0,
      selectedAnswers: [0],
      selectedMSQAnswers: [[]],
      statuses: [QuestionStatus.answered],
      questionTimeSpentSeconds: [10],
      remainingSeconds: 0,
      lastUpdated: DateTime.now().toIso8601String(),
    );

    await LocalStorageService.saveTestSession(session);

    final loaded = await LocalStorageService.loadTestSession('practice');
    expect(loaded, isNotNull);
    expect(loaded!.subject, equals('Fluid Mechanics'));
    expect(loaded.subTopic, equals('Properties of Fluids'));
    expect(loaded.currentIndex, equals(0));

    // Clear practice session
    await LocalStorageService.clearTestSession('practice');
    final cleared = await LocalStorageService.loadTestSession('practice');
    expect(cleared, isNull);
  });
}
