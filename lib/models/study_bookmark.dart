class StudyBookmark {
  final String subject;
  final String topic;
  final String title;
  final List<String> tags;
  final String userNote;

  const StudyBookmark({
    required this.subject,
    required this.topic,
    required this.title,
    this.tags = const [],
    this.userNote = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'topic': topic,
      'title': title,
      'tags': tags,
      'userNote': userNote,
    };
  }

  factory StudyBookmark.fromJson(Map<String, dynamic> json) {
    List<String> safeList(dynamic list) {
      if (list is List) {
        return list.map((e) => e.toString()).toList();
      }
      return [];
    }

    return StudyBookmark(
      subject: json['subject'] ?? '',
      topic: json['topic'] ?? '',
      title: json['title'] ?? '',
      tags: safeList(json['tags']),
      userNote: json['userNote'] as String? ?? '',
    );
  }
}
