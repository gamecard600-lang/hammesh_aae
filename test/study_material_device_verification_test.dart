import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hammesh_aae/models/study_material.dart';
import 'package:hammesh_aae/services/study_material_loader.dart';
import 'package:hammesh_aae/screens/study_material/study_material_screen.dart';
import 'package:hammesh_aae/screens/study_material/animated_topic_visual_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Comprehensive Real Device Verification Test Suite', () {
    late List<StudyMaterial> allMaterials;

    setUpAll(() async {
      allMaterials = await StudyMaterialLoader.loadAllMaterials();
    });

    test('1. Verify Master Study Material loads all 14 subjects and 165 subtopics', () {
      expect(allMaterials.length, equals(165));

      final subjects = allMaterials.map((m) => m.subject).toSet();
      expect(subjects.length, equals(14));
    });

    test('2. Verify Detailed Theory completeness across all 165 topics', () {
      for (final m in allMaterials) {
        expect(m.detailedTheory.isNotEmpty, isTrue, reason: 'Topic ${m.topic} in ${m.subject} has empty detailed theory');
        expect(m.detailedTheory.length, greaterThan(300), reason: 'Topic ${m.topic} in ${m.subject} has truncated detailed theory (${m.detailedTheory.length} chars)');

        // Verify formula & numerical presence
        expect(m.formulas.isNotEmpty || m.detailedTheory.contains('સૂત્ર') || m.detailedTheory.contains('Formula'), isTrue,
            reason: 'Topic ${m.topic} missing formulas');
      }
    });

    test('3. Verify Specific Formula Accuracy (e.g. Dynamic Analysis of Linkages)', () {
      final dynTopic = allMaterials.firstWhere((m) => m.topic.contains('Dynamic Analysis of Linkages'));
      expect(dynTopic.detailedTheory.contains('Mi = -IG × α'), isTrue,
          reason: 'Inertia torque formula must use angular acceleration α');
      expect(dynTopic.detailedTheory.contains('Mi = -IG × aG'), isFalse,
          reason: 'Inertia torque formula must NOT use linear acceleration aG');
    });

    test('4. Verify Diagram Image Paths across all 165 subtopics', () {
      for (final m in allMaterials) {
        expect(m.imagePath.isNotEmpty, isTrue, reason: 'Topic ${m.topic} missing imagePath');
        expect(m.imagePath.startsWith('assets/images/diagrams/'), isTrue, reason: 'Topic ${m.topic} imagePath formatted incorrectly: ${m.imagePath}');
      }
    });

    testWidgets('5. Render StudyMaterialScreen for Thermodynamics topic', (WidgetTester tester) async {
      final thermoMaterial = allMaterials.firstWhere((m) => m.subject == 'Thermodynamics');

      await tester.pumpWidget(
        MaterialApp(
          home: StudyMaterialScreen(
            material: thermoMaterial,
            subjectMaterials: allMaterials.where((m) => m.subject == 'Thermodynamics').toList(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text(thermoMaterial.topic), findsWidgets);
      expect(find.text('2. Detailed Theory'), findsOneWidget);
      expect(find.text('📐 Engineering Diagram (ઇજનેરી આકૃતિ)'), findsOneWidget);
    });

    testWidgets('6. Render AnimatedTopicVisualWidget for Video Learning', (WidgetTester tester) async {
      final thermoMaterial = allMaterials.firstWhere((m) => m.subject == 'Thermodynamics');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnimatedTopicVisualWidget(material: thermoMaterial),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Topic Video Learning'), findsOneWidget);
    });

    test('7. Verify Formulas Database (551 formulas)', () async {
      final formulas = await StudyMaterialLoader.loadAllFormulas();
      expect(formulas.length, equals(551));
      for (final f in formulas) {
        expect(f.formula.isNotEmpty, isTrue);
        expect(f.subject.isNotEmpty, isTrue);
      }
    });

    test('8. Verify Quick Revision Database (165 topics)', () async {
      final revisions = await StudyMaterialLoader.loadAllQuickRevisions();
      expect(revisions.length, equals(165));
      for (final r in revisions) {
        expect(r.points.isNotEmpty, isTrue);
        expect(r.subject.isNotEmpty, isTrue);
      }
    });
  });
}
