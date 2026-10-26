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

    if (videos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Row(
            children: [
              const Icon(Icons.ondemand_video, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '🎬 Topic Video Learning',
                  style: TextStyle(
                    fontSize: 16,
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
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }
}
