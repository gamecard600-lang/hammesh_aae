import '../models/question.dart';

List<Question> getRelatedQuestions({
  required List<Question> questions,
  required String subject,
  required String topic,
}) {
  final trimmedSubject = subject.trim().toLowerCase();
  final trimmedTopic = topic.trim().toLowerCase();

  return questions.where((q) {
    return q.subject.trim().toLowerCase() == trimmedSubject &&
        q.subTopic.trim().toLowerCase() == trimmedTopic;
  }).toList();
}
