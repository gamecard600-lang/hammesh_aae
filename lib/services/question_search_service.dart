import '../models/question.dart';

class QuestionSearchService {
  static List<Question> search({
    required List<Question> questions,
    required String query,
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return questions;

    return questions.where((question) {
      return question.question.toLowerCase().contains(q) ||
          question.gujaratiQuestion.toLowerCase().contains(q) ||
          question.subject.toLowerCase().contains(q) ||
          question.subTopic.toLowerCase().contains(q);
    }).toList();
  }

  static List<Question> applyFilters({
    required List<Question> questions,
    String? subject,
    String? topic,
    String query = '',
  }) {
    var result = questions;

    if (subject != null && subject.isNotEmpty) {
      result = result.where((q) => q.subject == subject).toList();
    }

    if (topic != null && topic.isNotEmpty) {
      result = result.where((q) => q.subTopic == topic).toList();
    }

    if (query.isNotEmpty) {
      result = search(questions: result, query: query);
    }

    return result;
  }
}
