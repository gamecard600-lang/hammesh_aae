import 'package:flutter/material.dart';
import '../models/exam_result.dart';
import '../models/progress.dart';
import '../services/progress_service.dart';
import 'review_screen.dart';
import 'question_practice_screen.dart';

class ResultScreen extends StatefulWidget {
  final ExamResult result;

  const ResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    _saveResult();
  }

  Future<void> _saveResult() async {
    final progress = Progress(
      subject: widget.result.subject,
      subTopic: widget.result.subTopic,
      totalQuestions: widget.result.totalQuestions,
      correctAnswers: widget.result.correct,
      wrongAnswers: widget.result.wrong,
      attemptedQuestions: widget.result.correct + widget.result.wrong,
    );

    await ProgressService.saveProgress(progress);
  }

  @override
  Widget build(BuildContext context) {
    String grade = 'A';
    if (widget.result.percentage < 50) {
      grade = 'C';
    } else if (widget.result.percentage < 75) {
      grade = 'B';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ટેસ્ટ પરિણામ'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.result.subject} - ${widget.result.subTopic}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              if (widget.result.date != null && widget.result.date!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'તારીખ: ${widget.result.date!.replaceFirst('T', ' ').split('.').first}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 12),
              
              // Score Card
              Card(
                elevation: 0,
                color: Colors.blue.shade50.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.blue.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildScoreItem('સ્કોર', '${widget.result.score.toStringAsFixed(0)}/${widget.result.totalQuestions}', Colors.blue),
                      _buildScoreItem('ટકા', '${widget.result.percentage.toStringAsFixed(0)}%', Colors.indigo),
                      _buildScoreItem('રેન્ક/ગ્રેડ', grade, Colors.amber.shade900),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Stats Row
              Row(
                children: [
                  _StatBox(
                    label: 'સાચા',
                    value: '${widget.result.correct}',
                    color: Colors.green,
                    icon: Icons.check_circle_outline,
                  ),
                  const SizedBox(width: 10),
                  _StatBox(
                    label: 'ખોટા',
                    value: '${widget.result.wrong}',
                    color: Colors.red,
                    icon: Icons.highlight_off,
                  ),
                  const SizedBox(width: 10),
                  _StatBox(
                    label: 'અનઆન્સ્ડ',
                    value: '${widget.result.skipped}',
                    color: Colors.orange,
                    icon: Icons.info_outline,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewScreen(
                        questions: widget.result.questions,
                        selectedAnswers: widget.result.selectedAnswers,
                        selectedMSQAnswers: widget.result.selectedMSQAnswers,
                        questionTimeSpent: widget.result.questionTimeSpent,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('પ્રશ્નોનું વિગતવાર વિશ્લેષણ જુઓ'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuestionPracticeScreen(
                        questions: widget.result.questions,
                        subject: widget.result.subject,
                        subTopic: widget.result.subTopic,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('પુન: ટેસ્ટ'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                icon: const Icon(Icons.home_outlined),
                label: const Text('હોમ પર જાઓ'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
