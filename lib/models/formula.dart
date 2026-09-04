class Formula {
  final String subject;
  final String topic;
  final String title;
  final String formula;
  final String description;

  const Formula({
    required this.subject,
    required this.topic,
    required this.title,
    required this.formula,
    required this.description,
  });

  factory Formula.fromJson(Map<String, dynamic> json) {
    return Formula(
      subject: json['subject'] ?? '',
      topic: json['topic'] ?? '',
      title: json['title'] ?? '',
      formula: json['formula'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'topic': topic,
      'title': title,
      'formula': formula,
      'description': description,
    };
  }
}
