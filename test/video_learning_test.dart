import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hammesh_aae/models/study_material.dart';
import 'package:hammesh_aae/screens/study_material/animated_topic_visual_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Video Learning Integration Tests', () {
    test('StudyMaterial model correctly parses StudyVideo and VisualLearning', () {
      final json = {
        'id': 101,
        'subject': 'Thermodynamics',
        'topic': 'Carnot Cycle',
        'title': 'Carnot Cycle Analysis',
        'overview': 'Overview text',
        'concept': 'Concept text',
        'definitions': [],
        'detailedTheory': '',
        'keyPoints': [],
        'formulas': [],
        'solvedExamples': [],
        'importantPoints': [],
        'examPoints': [],
        'commonMistakes': [],
        'quickRevision': [],
        'mcqs': [],
        'msqs': [],
        'visualLearning': {
          'enabled': true,
          'visualRequired': true,
          'type': 'cycle',
          'animationKey': 'carnot_cycle',
          'title': 'Carnot Cycle Visual',
          'purpose': 'Understand reversible cycle',
          'mobileLayout': '',
          'sequence': ['1-2 Isothermal Expansion', '2-3 Isentropic Expansion'],
          'diagrams': ['pv', 'ts'],
          'rule': 'Strict thermodynamics rule',
          'videos': [
            {
              'title': 'Carnot Cycle Full Lecture',
              'url': 'https://www.youtube.com/watch?v=carnot_lecture',
              'description': 'Full topic video lecture'
            },
            {
              'title': 'Carnot Cycle Numerical Problem',
              'url': 'https://www.youtube.com/watch?v=carnot_numerical',
              'description': 'Step-by-step problem solving'
            }
          ]
        }
      };

      final material = StudyMaterial.fromJson(json);

      expect(material.visualLearning, isNotNull);
      final vl = material.visualLearning!;
      expect(vl.enabled, isTrue);
      expect(vl.videos.length, equals(2));
      expect(vl.videos[0].title, equals('Carnot Cycle Full Lecture'));
      expect(vl.videos[0].url, equals('https://www.youtube.com/watch?v=carnot_lecture'));
      expect(vl.videos[0].description, equals('Full topic video lecture'));
      expect(vl.videos[1].title, equals('Carnot Cycle Numerical Problem'));
    });

    testWidgets('AnimatedTopicVisualWidget renders Video Learning and lists videos directly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final material = StudyMaterial(
        id: 1,
        subject: 'Thermodynamics',
        topic: 'Otto Cycle',
        title: 'Otto Cycle Analysis',
        overview: '',
        concept: '',
        definitions: [],
        detailedTheory: '',
        keyPoints: [],
        formulas: [],
        solvedExamples: [],
        importantPoints: [],
        examPoints: [],
        commonMistakes: [],
        quickRevision: [],
        mcqs: [],
        msqs: [],
        visualLearning: VisualLearning(
          enabled: true,
          visualRequired: true,
          type: 'cycle',
          animationKey: 'otto_cycle',
          title: 'Otto Cycle Working',
          purpose: 'Piston engine simulation',
          mobileLayout: '',
          sequence: ['Suction', 'Compression', 'Power', 'Exhaust'],
          diagrams: ['pv', 'ts'],
          rule: '',
          videos: const [
            StudyVideo(
              title: 'Otto Cycle Detailed Explanation',
              url: 'https://www.youtube.com/watch?v=otto_video',
              description: 'Interactive lecture on Otto cycle',
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnimatedTopicVisualWidget(material: material),
            ),
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.textContaining('Online Media'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Topic Video Learning'), findsOneWidget);
      expect(find.text('Otto Cycle Detailed Explanation'), findsWidgets);
      expect(find.text('Interactive lecture on Otto cycle'), findsWidgets);
    });
  });
}
