import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hammesh_aae/models/study_material.dart';
import 'package:hammesh_aae/widgets/topic_video_player_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Subject 4 (I.C. Engines) Video Learning Tests', () {
    test('Subject 4 has all 13 authoritative topics with visual learning and recall questions', () {
      final file = File('assets/study_material/master_study_material.json');
      expect(file.existsSync(), isTrue);

      final List decoded = jsonDecode(file.readAsStringSync());
      final s4 = decoded.firstWhere(
        (s) => s['subject'] == 'I.C. Engines' || s['subject'] == 'IC Engines',
        orElse: () => null,
      );

      expect(s4, isNotNull);
      final List topics = s4['topics'];
      expect(topics.length, equals(13));

      for (int i = 0; i < 13; i++) {
        final topic = topics[i];
        final expectedId = 32 + i;
        expect(topic['id'], equals(expectedId));

        final vl = topic['visualLearning'];
        expect(vl, isNotNull, reason: 'Topic ID $expectedId missing visualLearning');
        expect(vl['enabled'], isTrue);

        final List videos = vl['videos'];
        expect(videos.length, equals(2), reason: 'Topic ID $expectedId should have 2 videos');

        final conceptVideo = videos[0];
        expect(conceptVideo['title'], isNotEmpty);
        expect(conceptVideo['url'], isNotEmpty);

        final recallQs = conceptVideo['recallQuestions'] as List?;
        expect(recallQs, isNotNull);
        expect(recallQs!.isNotEmpty, isTrue, reason: 'Topic ID $expectedId should have recall questions');
      }
    });

    test('Dedicated offline MP4 video assets exist on disk for Pilot Topics', () {
      final requiredAssets = [
        'assets/videos/ic_engine_combustion_knocking.mp4',
        'assets/videos/ic_engine_testing_and_performance.mp4',
        'assets/videos/air_standard_cycles.mp4',
      ];

      for (final asset in requiredAssets) {
        final f = File(asset);
        expect(f.existsSync(), isTrue, reason: 'Missing video file: $asset');
        expect(f.lengthSync(), greaterThan(100000), reason: 'File $asset is empty or incomplete');
      }
    });

    testWidgets('TopicVideoPlayerWidget displays offline badge and recall question trigger', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const testVideo = StudyVideo(
        title: 'Testing & Performance of IC Engines - Gujarati Concept Lesson',
        url: 'https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/ic_engine_testing_and_performance.mp4',
        assetPath: 'assets/videos/ic_engine_testing_and_performance.mp4',
        description: 'Complete video lesson on IP, BP, FP, Morse Test and BSFC',
        videoId: 'vid_s4_t42_ep1',
        episodeNumber: 1,
        durationSeconds: 360,
        learningObjectives: ['Indicated Power calculation', 'Morse Test mechanics'],
        recallQuestions: [
          {
            'question': 'What is n for a 4-stroke engine?',
            'options': ['N', 'N/2', '2N', 'N/4'],
            'correctAnswer': 1,
            'explanation': 'In 4-stroke engines, there is 1 power stroke every 2 revolutions, so n = N/2.'
          }
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TopicVideoPlayerWidget(
                video: testVideo,
                topicName: 'Testing & Performance of IC Engines',
                subjectName: 'I.C. Engines',
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Testing & Performance of IC Engines - Gujarati Concept Lesson'), findsWidgets);
      expect(find.text('OFFLINE HD'), findsOneWidget);
      expect(find.text('EP 1'), findsOneWidget);
      expect(find.textContaining('Active Recall'), findsOneWidget);
      expect(find.textContaining('Practice MCQs'), findsOneWidget);
      expect(find.textContaining('AI Story Mode'), findsOneWidget);
    });
  });
}
