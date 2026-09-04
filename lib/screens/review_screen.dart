import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/answer_checker.dart';
import 'suggestion_report_screen.dart';

class ReviewScreen extends StatelessWidget {
  final List<Question> questions;
  final List<int?> selectedAnswers;
  final List<List<int>> selectedMSQAnswers;
  final List<int> questionTimeSpent;

  const ReviewScreen({
    super.key,
    required this.questions,
    required this.selectedAnswers,
    required this.selectedMSQAnswers,
    this.questionTimeSpent = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Answers'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final selected = selectedAnswers[index];
          final msqSelected = selectedMSQAnswers[index];

          final isCorrect = AnswerChecker.isCorrect(
            isMSQ: question.isMSQ,
            selectedAnswer: selected,
            selectedAnswers: msqSelected,
            correctAnswer: question.correctAnswer,
            correctAnswers: question.correctAnswers,
          );

          bool isNotAnswered = question.isMSQ 
              ? msqSelected.isEmpty 
              : selected == null;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isNotAnswered
                    ? Colors.grey.shade300
                    : isCorrect
                        ? Colors.green.shade300
                        : Colors.red.shade400,
                width: isCorrect || isNotAnswered ? 1 : 1.8,
              ),
            ),
            color: (!isCorrect && !isNotAnswered)
                ? Colors.red.shade50.withValues(alpha: 0.25)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Q${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Row(
                        children: [
                          if (questionTimeSpent.length > index && questionTimeSpent[index] > 0)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '⏱️ ${questionTimeSpent[index]}s',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isNotAnswered
                                  ? Colors.grey.shade200
                                  : isCorrect
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isNotAnswered
                                  ? 'Skipped'
                                  : isCorrect
                                      ? 'Correct'
                                      : 'Wrong',
                              style: TextStyle(
                                color: isNotAnswered
                                    ? Colors.grey
                                    : isCorrect
                                        ? Colors.green
                                        : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.report_problem_outlined, size: 18, color: Colors.orange),
                            tooltip: 'Report Question',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SuggestionReportScreen(
                                    initialCategory: 'Wrong MCQ / Answer',
                                    subject: question.subject,
                                    topic: question.subTopic,
                                    questionId: question.id,
                                    questionText: question.question,
                                    currentScreen: 'ReviewScreen',
                                  ),
                                ),
                              );
                            },
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.only(left: 8),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  if (question.gujaratiQuestion.isNotEmpty) ...[
                    Text(
                      question.gujaratiQuestion,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(height: 24),
                  
                  const Text(
                    'Your Answer:',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  _buildUserAnswer(question, selected, msqSelected),
                  
                  const SizedBox(height: 12),
                  
                  const Text(
                    'Correct Answer:',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  _buildCorrectAnswer(question),
                  
                  if (question.explanation.isNotEmpty) ...[
                    const Divider(height: 24),
                    const Text(
                      'Explanation:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      question.explanation,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserAnswer(Question question, int? selected, List<int> msqSelected) {
    if (question.isMSQ) {
      if (msqSelected.isEmpty) {
        return const Text('— Not Answered', style: TextStyle(color: Colors.grey));
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: msqSelected.map((idx) {
          bool isActuallyCorrect = question.correctAnswers.contains(idx);
          return Row(
            children: [
              Icon(
                isActuallyCorrect ? Icons.check : Icons.close,
                size: 16,
                color: isActuallyCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Expanded(child: Text(question.options[idx])),
            ],
          );
        }).toList(),
      );
    } else {
      if (selected == null || selected == -1) {
        return const Text('— Not Answered', style: TextStyle(color: Colors.grey));
      }
      bool isCorrect = selected == question.correctAnswer;
      return Row(
        children: [
          Icon(
            isCorrect ? Icons.check : Icons.close,
            size: 16,
            color: isCorrect ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '${String.fromCharCode(65 + selected)}. ${question.options[selected]}',
            ),
          ),
        ],
      );
    }
  }

  Widget _buildCorrectAnswer(Question question) {
    if (question.isMSQ) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: question.correctAnswers.map((idx) {
          return Row(
            children: [
              const Icon(Icons.check, size: 16, color: Colors.green),
              const SizedBox(width: 4),
              Expanded(child: Text(question.options[idx])),
            ],
          );
        }).toList(),
      );
    } else {
      return Row(
        children: [
          const Icon(Icons.check, size: 16, color: Colors.green),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '${String.fromCharCode(65 + question.correctAnswer)}. ${question.options[question.correctAnswer]}',
            ),
          ),
        ],
      );
    }
  }
}
