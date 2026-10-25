import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hammesh_aae/services/local_storage_service.dart';
import 'package:hammesh_aae/services/progress_service.dart';
import 'package:hammesh_aae/services/daily_task_service.dart';
import 'package:hammesh_aae/services/question_service.dart';
import 'package:hammesh_aae/services/answer_checker.dart';
import 'package:hammesh_aae/services/ai_study_assistant_service.dart';
import 'package:hammesh_aae/models/question.dart';
import 'package:hammesh_aae/models/exam_result.dart';
import 'package:hammesh_aae/models/exam_history.dart';
import 'package:hammesh_aae/models/progress.dart';
import 'package:hammesh_aae/models/ai_context.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature Update 2026-09-20 Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('Daily Task - 10 Daily Questions Generation', () async {
      final session = await DailyTaskService.getTodaySession();
      expect(session.questionIds.length, equals(10));

      final questions = await QuestionService.getQuestionsByIds(session.questionIds);
      expect(questions.length, equals(10));
    });

    test('Revision - Completed Topics Only Rule', () async {
      // Ensure initially 0 completed topics
      await LocalStorageService.saveStudyProgress([]);
      final progressBefore = await LocalStorageService.loadStudyProgress();
      final completedBefore = progressBefore.where((p) => p.completed).toList();
      expect(completedBefore.isEmpty, isTrue);

      // Mark 1 topic completed
      await LocalStorageService.markTopicCompleted(
        'Thermodynamics',
        'Thermodynamic Systems & Control Volume',
      );

      final progressAfter = await LocalStorageService.loadStudyProgress();
      final completedAfter = progressAfter.where((p) => p.completed).toList();
      expect(completedAfter.length, equals(1));
      expect(completedAfter.first.subject, equals('Thermodynamics'));
      expect(completedAfter.first.topic, equals('Thermodynamic Systems & Control Volume'));
    });

    test('Wrong Question Retry - Identification via AnswerChecker', () {
      final q1 = Question(
        id: 101,
        subject: 'Thermodynamics',
        subTopic: 'Thermodynamic Systems & Control Volume',
        question: 'What is entropy?',
        gujaratiQuestion: 'એન્ટ્રોપી શું છે?',
        options: ['A', 'B', 'C', 'D'],
        correctAnswer: 0,
        correctAnswers: [0],
        isMSQ: false,
        explanation: 'Test exp 1',
      );

      final q2 = Question(
        id: 102,
        subject: 'Thermodynamics',
        subTopic: 'Thermodynamic Systems & Control Volume',
        question: 'Which processes are reversible?',
        gujaratiQuestion: 'કઈ પ્રક્રિયા રિવર્સિબલ છે?',
        options: ['1', '2', '3', '4'],
        correctAnswer: 0,
        correctAnswers: [0, 2],
        isMSQ: true,
        explanation: 'Test exp 2',
      );

      final result = ExamResult(
        subject: 'Thermodynamics',
        subTopic: 'Test 1',
        totalQuestions: 2,
        correct: 0,
        wrong: 2,
        skipped: 0,
        score: 0,
        percentage: 0,
        accuracy: 0,
        questions: [q1, q2],
        selectedAnswers: [1, null], // Wrong answer for q1
        selectedMSQAnswers: [[], [0]], // Wrong answer for MSQ q2 (incomplete)
      );

      // Verify AnswerChecker identifies both as wrong
      final q1Correct = AnswerChecker.isCorrect(
        isMSQ: q1.isMSQ,
        selectedAnswer: result.selectedAnswers[0],
        selectedAnswers: result.selectedMSQAnswers[0],
        correctAnswer: q1.correctAnswer,
        correctAnswers: q1.correctAnswers,
      );
      expect(q1Correct, isFalse);

      final q2Correct = AnswerChecker.isCorrect(
        isMSQ: q2.isMSQ,
        selectedAnswer: result.selectedAnswers[1],
        selectedAnswers: result.selectedMSQAnswers[1],
        correctAnswer: q2.correctAnswer,
        correctAnswers: q2.correctAnswers,
      );
      expect(q2Correct, isFalse);
    });

    test('Topic Test Retry - Your Progress Rule', () async {
      const subject = 'Thermodynamics';
      const subTopic = 'First Law of Thermodynamics';

      // 1. Save Official Topic Test Attempt (10 Qs, 8 correct, 2 wrong)
      final officialProgress = Progress(
        subject: subject,
        subTopic: subTopic,
        totalQuestions: 10,
        correctAnswers: 8,
        wrongAnswers: 2,
        attemptedQuestions: 10,
      );
      await ProgressService.saveProgress(officialProgress);

      final officialHistory = ExamHistory(
        id: '1',
        subject: subject,
        subTopic: subTopic,
        date: DateTime.now().toIso8601String(),
        totalQuestions: 10,
        correct: 8,
        wrong: 2,
        skipped: 0,
        score: 8,
        percentage: 80,
        accuracy: 80,
        isPracticeRetry: false,
      );
      await LocalStorageService.addExamToHistory(officialHistory);

      // Verify official progress is recorded as 8/10 (80%)
      final savedProgress = await ProgressService.getProgress(subject, subTopic);
      expect(savedProgress, isNotNull);
      expect(savedProgress!.correctAnswers, equals(8));
      expect(savedProgress.totalQuestions, equals(10));

      // 2. Simulate Practice Retry Attempt (2 Qs, 2 correct)
      final retryHistory = ExamHistory(
        id: '2',
        subject: subject,
        subTopic: '$subTopic • Wrong Questions',
        date: DateTime.now().toIso8601String(),
        totalQuestions: 2,
        correct: 2,
        wrong: 0,
        skipped: 0,
        score: 2,
        percentage: 100,
        accuracy: 100,
        isPracticeRetry: true,
      );
      await LocalStorageService.addExamToHistory(retryHistory);

      // Verify Official Progress was NOT overwritten by retry attempt
      final postRetryProgress = await ProgressService.getProgress(subject, subTopic);
      expect(postRetryProgress!.correctAnswers, equals(8));
      expect(postRetryProgress.totalQuestions, equals(10));

      // Verify History contains both entries, but official history filter excludes the retry
      final allHistory = await LocalStorageService.loadExamHistory();
      expect(allHistory.length, equals(2));

      final officialOnly = allHistory.where((h) => !h.isPracticeRetry && !h.subTopic.contains('Wrong Questions')).toList();
      expect(officialOnly.length, equals(1));
      expect(officialOnly.first.correct, equals(8));
    });

    test('AI Assistant - Fallback Responses', () async {
      const aiContext = AiContext(
        subject: 'Thermodynamics',
        topic: 'Entropy',
        questionText: 'Calculate entropy change when heat is transferred at constant temperature.',
      );

      final numericalResponse = await AiStudyAssistantService.solveStepByStep(context: aiContext);
      expect(numericalResponse.contains('Given:'), isTrue);

      final mistakeResponse = await AiStudyAssistantService.explainMistake(context: aiContext);
      expect(mistakeResponse.contains('તમે પસંદ કરેલ જવાબ'), isTrue);
    });
  });
}
