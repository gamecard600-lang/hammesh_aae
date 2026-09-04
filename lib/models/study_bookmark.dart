class StudyBookmark {
  final String subject;
  final String topic;
  final String title;

  const StudyBookmark({
    required this.subject,
    required this.topic,
    required this.title,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'topic': topic,
      'title': title,
    };
  }

  factory StudyBookmark.fromJson(Map<String, dynamic> json) {
    return StudyBookmark(
      subject: json['subject'] ?? '',
      topic: json['topic'] ?? '',
      title: json['title'] ?? '',
    );
  }
}
