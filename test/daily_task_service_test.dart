import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hammesh_aae/services/daily_task_service.dart';
import 'package:hammesh_aae/services/question_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DailyTaskService Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('getTodaySession generates 10 daily questions across subjects', () async {
      final session = await DailyTaskService.getTodaySession();
      expect(session.questionIds.length, equals(10));

      final questions = await QuestionService.getQuestionsByIds(session.questionIds);
      expect(questions.length, equals(10));
    });

    test('getTodaySession persists session for today', () async {
      final session1 = await DailyTaskService.getTodaySession();
      final session2 = await DailyTaskService.getTodaySession();

      expect(session1.date, equals(session2.date));
      expect(session1.questionIds, equals(session2.questionIds));
    });
  });
}
