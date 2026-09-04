class StudyProgress {
  final String subject;
  final String topic;
  final bool completed;
  final int progress; // 0-100 percentage

  const StudyProgress({
    required this.subject,
    required this.topic,
    required this.completed,
    required this.progress,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'topic': topic,
      'completed': completed,
      'progress': progress,
    };
  }

  factory StudyProgress.fromJson(Map<String, dynamic> json) {
    return StudyProgress(
      subject: json['subject'] ?? '',
      topic: json['topic'] ?? '',
      completed: json['completed'] ?? false,
      progress: json['progress'] ?? 0,
    );
  }
}
