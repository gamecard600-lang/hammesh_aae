class QuickRevision {
  final String subject;
  final String topic;
  final List<String> points;

  const QuickRevision({
    required this.subject,
    required this.topic,
    required this.points,
  });

  factory QuickRevision.fromJson(Map<String, dynamic> json) {
    return QuickRevision(
      subject: json['subject'] ?? '',
      topic: json['topic'] ?? '',
      points: List<String>.from(json['points'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'topic': topic,
      'points': points,
    };
  }
}
