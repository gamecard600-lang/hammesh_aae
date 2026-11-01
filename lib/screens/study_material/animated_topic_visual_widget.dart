import 'package:flutter/material.dart';
import '../../models/study_material.dart';
import '../../widgets/topic_video_player_widget.dart';

class AnimatedTopicVisualWidget extends StatelessWidget {
  final StudyMaterial material;

  const AnimatedTopicVisualWidget({
    super.key,
    required this.material,
  });

  VisualLearning? get vl => material.visualLearning;

  @override
  Widget build(BuildContext context) {
    final videos = <StudyVideo>[...(vl?.videos ?? const [])];

    if (videos.isEmpty && vl?.videoUrl != null && vl!.videoUrl!.isNotEmpty) {
      videos.add(StudyVideo(
        title: '${material.topic} - Video Explanation',
        url: vl!.videoUrl!,
      ));
    }

    if (videos.isEmpty && material.subject == 'Thermodynamics' && material.topic.contains('Thermodynamic Systems')) {
      videos.add(const StudyVideo(
        title: 'Thermodynamic Systems & Control Volume - Gujarati Video Lesson',
        url: 'https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/thermodynamic_systems.mp4',
        assetPath: 'assets/videos/thermodynamic_systems.mp4',
        description: '3.5 min animated Gujarati video lesson explaining System, Surroundings, Open/Closed/Isolated Systems, Control Volume, and ṁ = ρAV formula with exam tips.',
      ));
    }

    // Always ensure at least 1 video entry exists for every topic
    if (videos.isEmpty) {
      final String topicSlug = material.topic.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
      videos.add(StudyVideo(
        title: '${material.topic} - Full Concept Lesson',
        url: 'https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/$topicSlug.mp4',
        description: '${material.topic} નો વિઝ્યુઅલ અને સિદ્ધાંત પાઠ એપ્લિકેશનમાં પ્લે કરો.',
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Row(
            children: [
              const Icon(Icons.play_circle_fill_rounded, color: Colors.amber, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Topic Video Learning',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...videos.map((v) {
          return TopicVideoPlayerWidget(
            video: v,
            topicName: material.topic,
            subjectName: material.subject,
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }
}
