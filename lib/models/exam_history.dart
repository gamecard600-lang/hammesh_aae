import 'question.dart';
import 'exam_result.dart';

class ExamHistory {
  final String id;
  final String subject;
  final String subTopic;
  final String date;
  final int totalQuestions;
  final int correct;
  final int wrong;
  final int skipped;
  final double score;
  final double percentage;
  final double accuracy;

  final List<Question> questions;
  final List<int?> selectedAnswers;
  final List<List<int>> selectedMSQAnswers;
  final List<int> questionTimeSpent;

  ExamHistory({
    required this.id,
    required this.subject,
    required this.subTopic,
    required this.date,
    required this.totalQuestions,
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.score,
    required this.percentage,
    required this.accuracy,
    this.questions = const [],
    this.selectedAnswers = const [],
    this.selectedMSQAnswers = const [],
    this.questionTimeSpent = const [],
  });

  ExamResult toExamResult() {
    return ExamResult(
      subject: subject,
      subTopic: subTopic,
      totalQuestions: totalQuestions,
      correct: correct,
      wrong: wrong,
      skipped: skipped,
      score: score,
      percentage: percentage,
      accuracy: accuracy,
      questions: questions,
      selectedAnswers: selectedAnswers,
      selectedMSQAnswers: selectedMSQAnswers,
      questionTimeSpent: questionTimeSpent,
      date: date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'subTopic': subTopic,
      'date': date,
      'totalQuestions': totalQuestions,
      'correct': correct,
      'wrong': wrong,
      'skipped': skipped,
      'score': score,
      'percentage': percentage,
      'accuracy': accuracy,
      'questions': questions.map((q) => q.toJson()).toList(),
      'selectedAnswers': selectedAnswers,
      'selectedMSQAnswers': selectedMSQAnswers,
      'questionTimeSpent': questionTimeSpent,
    };
  }

  factory ExamHistory.fromJson(Map<String, dynamic> json) {
    List<Question> questionsList = [];
    if (json['questions'] is List) {
      questionsList = (json['questions'] as List)
          .map((item) => Question.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    List<int?> selAnswers = [];
    if (json['selectedAnswers'] is List) {
      selAnswers = (json['selectedAnswers'] as List)
          .map<int?>((e) => e == null ? null : (e as num).toInt())
          .toList();
    }

    List<List<int>> selMSQAnswers = [];
    if (json['selectedMSQAnswers'] is List) {
      selMSQAnswers = (json['selectedMSQAnswers'] as List)
          .map<List<int>>((sub) => sub is List
              ? sub.map<int>((e) => (e as num).toInt()).toList()
              : [])
          .toList();
    }

    List<int> timeSpent = [];
    if (json['questionTimeSpent'] is List) {
      timeSpent = (json['questionTimeSpent'] as List)
          .map<int>((e) => (e as num).toInt())
          .toList();
    }

    return ExamHistory(
      id: json['id'] ?? '',
      subject: json['subject'] ?? '',
      subTopic: json['subTopic'] ?? '',
      date: json['date'] ?? '',
      totalQuestions: (json['totalQuestions'] ?? 0) as int,
      correct: (json['correct'] ?? 0) as int,
      wrong: (json['wrong'] ?? 0) as int,
      skipped: (json['skipped'] ?? 0) as int,
      score: (json['score'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      questions: questionsList,
      selectedAnswers: selAnswers,
      selectedMSQAnswers: selMSQAnswers,
      questionTimeSpent: timeSpent,
    );
  }
}
