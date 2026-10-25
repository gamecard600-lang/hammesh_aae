import 'dart:convert';

class StoryScene {
  final int sceneNumber;
  final String title;
  final String narration;
  final String keyTakeaway;
  final String visualSymbol;
  final String colorThemeHex;

  StoryScene({
    required this.sceneNumber,
    required this.title,
    required this.narration,
    required this.keyTakeaway,
    required this.visualSymbol,
    this.colorThemeHex = '#1E88E5',
  });

  factory StoryScene.fromJson(Map<String, dynamic> json) {
    return StoryScene(
      sceneNumber: json['scene_number'] ?? 1,
      title: json['title'] ?? 'Concept Scene',
      narration: json['narration'] ?? '',
      keyTakeaway: json['key_takeaway'] ?? '',
      visualSymbol: json['visual_symbol'] ?? '💡',
      colorThemeHex: json['color_theme_hex'] ?? '#1E88E5',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scene_number': sceneNumber,
      'title': title,
      'narration': narration,
      'key_takeaway': keyTakeaway,
      'visual_symbol': visualSymbol,
      'color_theme_hex': colorThemeHex,
    };
  }
}

class ConceptStory {
  final String topic;
  final String subject;
  final String overallMoral;
  final List<StoryScene> scenes;

  ConceptStory({
    required this.topic,
    required this.subject,
    required this.overallMoral,
    required this.scenes,
  });

  factory ConceptStory.fromJson(Map<String, dynamic> json) {
    var rawScenes = json['scenes'] as List? ?? [];
    List<StoryScene> parsedScenes = rawScenes
        .map((s) => StoryScene.fromJson(Map<String, dynamic>.from(s)))
        .toList();

    return ConceptStory(
      topic: json['topic'] ?? 'Engineering Concept',
      subject: json['subject'] ?? 'Mechanical Engineering',
      overallMoral: json['overall_moral'] ?? 'Understand concepts visually!',
      scenes: parsedScenes,
    );
  }

  static ConceptStory createFallbackStory(String topic, String subject) {
    return ConceptStory(
      topic: topic,
      subject: subject,
      overallMoral: 'Visualizing engineering principles helps master exam questions!',
      scenes: [
        StoryScene(
          sceneNumber: 1,
          title: '🎬 The Everyday Scenario',
          narration: 'Imagine operating a high-pressure valve in an industrial plant. As fluid speeds up through a narrow pipe, pressure drops!',
          keyTakeaway: 'Fluid velocity increases ➔ Static pressure decreases.',
          visualSymbol: '🌊',
          colorThemeHex: '#0288D1',
        ),
        StoryScene(
          sceneNumber: 2,
          title: '🧠 Core Engineering Law',
          narration: 'This behavior is governed by Bernoulli\'s Principle (Energy Conservation along a Streamline). Total Mechanical Energy remains constant.',
          keyTakeaway: 'P/ρg + v²/2g + z = Constant',
          visualSymbol: '⚙️',
          colorThemeHex: '#2E7D32',
        ),
        StoryScene(
          sceneNumber: 3,
          title: '⚠️ Exam Trap to Watch Out',
          narration: 'Don\'t confuse total pressure with static pressure! Dynamic pressure increases when velocity increases.',
          keyTakeaway: 'Total Pressure = Static Pressure + Dynamic Pressure',
          visualSymbol: '⚠️',
          colorThemeHex: '#E65100',
        ),
        StoryScene(
          sceneNumber: 4,
          title: '🎯 Summary & Memory Shortcut',
          narration: 'Narrow Pipe = High Speed = Low Pressure. High Speed means Low Pressure in fluid dynamics!',
          keyTakeaway: 'Narrow Pipe ➔ Velocity ↑ ➔ Pressure ↓',
          visualSymbol: '🏆',
          colorThemeHex: '#6A1B9A',
        ),
      ],
    );
  }
}
