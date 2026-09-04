import 'question.dart';

class ExamResult {
  final String subject;
  final String subTopic;
  final int totalQuestions;
  final int correct;
  final int wrong;
  final int skipped;
  final double score;
  final double percentage;
  final double accuracy;
  
  // Added for Review Engine
  final List<Question> questions;
  final List<int?> selectedAnswers;
  final List<List<int>> selectedMSQAnswers;
  final List<int> questionTimeSpent;
  final String? date;

  ExamResult({
    required this.subject,
    required this.subTopic,
    required this.totalQuestions,
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.score,
    required this.percentage,
    required this.accuracy,
    required this.questions,
    required this.selectedAnswers,
    required this.selectedMSQAnswers,
    this.questionTimeSpent = const [],
    this.date,
  });
}
