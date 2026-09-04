import 'package:flutter/material.dart';
import '../models/mistake.dart';
import '../models/question.dart';
import '../models/practice_mode.dart';
import '../models/ai_context.dart';
import '../services/mistake_service.dart';
import 'review_screen.dart';
import 'question_practice_screen.dart';
import 'ai_assistant/ai_chat_dialog.dart';

class MistakesScreen extends StatefulWidget {
  const MistakesScreen({super.key});

  @override
  State<MistakesScreen> createState() => _MistakesScreenState();
}

class _MistakesScreenState extends State<MistakesScreen> {
  List<Mistake> mistakes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMistakes();
  }

  Future<void> _loadMistakes() async {
    final data = await MistakeService.loadMistakes();
    setState(() {
      mistakes = data;
      isLoading = false;
    });
  }

  Question _toQuestion(Mistake m) {
    return Question(
      id: m.questionId,
      subject: m.subject,
      subTopic: m.subTopic,
      question: m.question,
      gujaratiQuestion: m.gujaratiQuestion,
      options: m.options,
      correctAnswer: m.correctAnswer,
      correctAnswers: m.correctAnswers,
      isMSQ: m.isMSQ,
      explanation: m.explanation,
    );
  }

  void _startMistakePractice() {
    if (mistakes.isEmpty) return;

    final questions = mistakes.map((m) => _toQuestion(m)).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionPracticeScreen(
          questions: questions,
          subject: 'Mistakes',
          config: PracticeConfig.mistakePractice,
        ),
      ),
    ).then((_) => _loadMistakes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📕 My AI Mistakes'),
        actions: [
          if (mistakes.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.play_circle_outline, color: Colors.blue),
              tooltip: 'Revise My Mistakes',
              onPressed: _startMistakePractice,
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All?'),
                    content: const Text('Do you want to clear all recorded mistakes?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await MistakeService.clearMistakes();
                  _loadMistakes();
                }
              },
            ),
          ],
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : mistakes.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
                        SizedBox(height: 12),
                        Text(
                          'તમારી કોઈ ભૂલ નોંધાયેલી નથી!',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'જ્યારે તમે ટેસ્ટ કે પ્રેક્ટિસમાં ખોટો જવાબ આપશો ત્યારે અહીં ઓટોમેટિક AI Explanation સાથે સેવ થશે.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mistakes.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildTopHeader();
                    }
                    final mistake = mistakes[index - 1];
                    final question = _toQuestion(mistake);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    mistake.subject,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    mistake.subTopic,
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (mistake.wrongCount > 1) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Wrong ${mistake.wrongCount}x',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (mistake.gujaratiQuestion.isNotEmpty) ...[
                              Text(
                                mistake.gujaratiQuestion,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueAccent),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              mistake.question,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                            ),
                            const SizedBox(height: 8),
                            if (mistake.userWrongAnswer != null && mistake.options.length > mistake.userWrongAnswer!) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Text(
                                  'Your Answer: ${String.fromCharCode(65 + mistake.userWrongAnswer!)}. ${mistake.options[mistake.userWrongAnswer!]} ❌',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            if (mistake.options.length > mistake.correctAnswer) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Text(
                                  'Correct Answer: ${String.fromCharCode(65 + mistake.correctAnswer)}. ${mistake.options[mistake.correctAnswer]} ✅',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReviewScreen(
                                          questions: [question],
                                          selectedAnswers: [mistake.userWrongAnswer],
                                          selectedMSQAnswers: [mistake.userWrongAnswers],
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.visibility_outlined, size: 16),
                                  label: const Text('રિવ્યુ કરો', style: TextStyle(fontSize: 12)),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    AiChatDialog.show(
                                      context,
                                      contextData: AiContext(
                                        subject: mistake.subject,
                                        topic: mistake.subTopic,
                                        subtopic: mistake.subTopic,
                                        questionText: mistake.question,
                                        gujaratiQuestionText: mistake.gujaratiQuestion,
                                        options: mistake.options,
                                        correctAnswer: mistake.correctAnswer,
                                        existingExplanation: mistake.explanation,
                                      ),
                                      initialAction: AiQuickAction.whyWrong,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade50,
                                    foregroundColor: Colors.red.shade800,
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.psychology, size: 16),
                                  label: const Text('🤖 AI Explanation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book, color: Colors.red.shade700, size: 24),
              const SizedBox(width: 10),
              Text(
                '🤖 AI Mistake Notebook (${mistakes.length})',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red.shade900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'તમારા દ્વારા ખોટા પડેલા તમામ પ્રશ્નો અહીં સેવ છે. AI દ્વારા તમારી ભૂલ સમજો અને ફરીથી પ્રેક્ટિસ કરો.',
            style: TextStyle(fontSize: 12.5, height: 1.4, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startMistakePractice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Revise My Mistakes Now', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
