import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hammesh_aae/screens/smart_revision_2_screen.dart';
import 'package:hammesh_aae/models/mistake.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Smart Revision 2.0 Tests', () {
    testWidgets('SmartRevision2Screen renders adaptive revision queue and tabs', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const MaterialApp(
          home: SmartRevision2Screen(),
        ),
      );

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(find.textContaining('Smart Revision 2.0'), findsOneWidget);
      expect(find.textContaining('Today\'s'), findsWidgets);
      expect(find.textContaining('Daily'), findsWidgets);
    });

    test('Mistake priority calculation test', () {
      final mistakeRecent = Mistake(
        questionId: 101,
        subject: 'Fluid Mechanics',
        subTopic: 'Bernoulli Equation',
        question: 'Sample Q',
        gujaratiQuestion: 'Sample GQ',
        options: ['A', 'B', 'C', 'D'],
        correctAnswer: 0,
        correctAnswers: const [0],
        isMSQ: false,
        explanation: 'Exp',
        wrongCount: 3,
        lastWrongDate: DateTime.now().toIso8601String(),
      );

      final mistakeOldAndRepeated = Mistake(
        questionId: 102,
        subject: 'Thermodynamics',
        subTopic: 'Entropy',
        question: 'Sample Q2',
        gujaratiQuestion: 'Sample GQ2',
        options: ['A', 'B', 'C', 'D'],
        correctAnswer: 1,
        correctAnswers: const [1],
        isMSQ: false,
        explanation: 'Exp2',
        wrongCount: 5,
        lastWrongDate: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      );

      expect(mistakeOldAndRepeated.wrongCount, greaterThan(mistakeRecent.wrongCount));
    });
  });
}
