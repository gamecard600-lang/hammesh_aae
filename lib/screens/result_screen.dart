import 'package:flutter/material.dart';
import '../models/exam_result.dart';
import '../models/progress.dart';
import '../services/progress_service.dart';
import '../services/local_storage_service.dart';
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

    if (widget.result.correct > 0 || widget.result.percentage >= 40) {
      await LocalStorageService.markTopicCompleted(
        widget.result.subject,
        widget.result.subTopic,
      );
    }
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
                      _buildScoreItem('મેળવેલ ગુણ (Marks)', '${(widget.result.score < 0 ? 0.0 : widget.result.score).toStringAsFixed(2)}/${widget.result.totalQuestions}', Colors.blue),
                      _buildScoreItem('ટકા', '${widget.result.percentage < 0 ? 0 : widget.result.percentage.toStringAsFixed(0)}%', Colors.indigo),
                      _buildScoreItem('રેન્ક/ગ્રેડ', grade, Colors.amber.shade900),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              _buildNegativeMarkingCalculationCard(),
              
              const SizedBox(height: 16),
              
              // Stats Row
              Row(
                children: [
                  _StatBox(
                    label: 'સાચા (+1.00)',
                    value: '${widget.result.correct}',
                    color: Colors.green,
                    icon: Icons.check_circle_outline,
                  ),
                  const SizedBox(width: 10),
                  _StatBox(
                    label: 'ખોટા (-0.25)',
                    value: '${widget.result.wrong}',
                    color: Colors.red,
                    icon: Icons.highlight_off,
                  ),
                  const SizedBox(width: 10),
                  _StatBox(
                    label: 'અનઆન્સ્ડ (0.00)',
                    value: '${widget.result.skipped}',
                    color: Colors.orange,
                    icon: Icons.info_outline,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              _buildSpeedometerAndCutoffCard(),
              const SizedBox(height: 20),
              
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

  Widget _buildNegativeMarkingCalculationCard() {
    final double positiveMarks = widget.result.correct * 1.0;
    final double negativeDeduction = widget.result.wrong * 0.25;
    final double netMarks = positiveMarks - negativeDeduction;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? const Color(0xFF0F172A) : Colors.amber.shade50.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.amberAccent.withValues(alpha: 0.5) : Colors.amber.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate_outlined, color: Colors.amber, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '📊 ગુણ મેળવવાની ગણતરી (Negative Marking Breakdown)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.amberAccent : Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('✅ સાચા પ્રશ્નો (+1.00 માર્ક/પ્રશ્ન):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(
                  '+${positiveMarks.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('❌ ખોટા પ્રશ્નો (-0.25 નેગેટિવ કપાત):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(
                  '-${negativeDeduction.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('⚪ અણઉકેલાયેલ પ્રશ્નો (Skipped):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const Text(
                  '0.00',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.blue.shade900.withValues(alpha: 0.4) : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? Colors.blueAccent : Colors.blue.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🎯 ફાઇનલ મેળવેલ ચોખ્ખા ગુણ (Net Marks):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  Text(
                    '${(netMarks < 0 ? 0.0 : netMarks).toStringAsFixed(2)} / ${widget.result.totalQuestions}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2563EB)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '* GSSSB માનક નેગેટિવ માર્કિંગ પદ્ધતિ: સાચા જવાબ માટે +1.00 અને દરેક ખોટા જવાબ માટે 0.25 માર્ક્સ કપાત થાય છે.',
              style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedometerAndCutoffCard() {
    final times = widget.result.questionTimeSpent;
    int totalTime = 0;
    if (times.isNotEmpty) {
      totalTime = times.reduce((a, b) => a + b);
    }
    final int avgSec = widget.result.totalQuestions > 0
        ? (totalTime / widget.result.totalQuestions).round()
        : 30;

    String speedRating;
    Color speedColor;
    IconData speedIcon;

    if (avgSec <= 35) {
      speedRating = '🔥 Fast & Accurate Solver ($avgSec sec/MCQ)';
      speedColor = Colors.green;
      speedIcon = Icons.speed;
    } else if (avgSec <= 60) {
      speedRating = '⚡ Balanced Speed ($avgSec sec/MCQ)';
      speedColor = Colors.blue;
      speedIcon = Icons.timer;
    } else {
      speedRating = '⚠️ Need Speed Practice ($avgSec sec/MCQ)';
      speedColor = Colors.orange;
      speedIcon = Icons.warning_amber_rounded;
    }

    final pct = widget.result.percentage;
    String cutoffStatus;
    Color cutoffColor;
    String percentile;

    if (pct >= 70) {
      cutoffStatus = '🟢 SAFE ZONE (GSSSB Cut-off Cleared!)';
      cutoffColor = Colors.green;
      percentile = 'Top 95th Percentile';
    } else if (pct >= 50) {
      cutoffStatus = '🟡 BORDERLINE ZONE (Increase Accuracy)';
      cutoffColor = Colors.amber.shade900;
      percentile = 'Top 75th Percentile';
    } else {
      cutoffStatus = '🔴 IMPROVEMENT NEEDED';
      cutoffColor = Colors.red;
      percentile = 'Top 45th Percentile';
    }

    return Card(
      color: Colors.blueGrey.shade50.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blueGrey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⏱️ Speed & Cut-off Performance Analytics',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Divider(height: 16),
            Row(
              children: [
                Icon(speedIcon, color: speedColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    speedRating,
                    style: TextStyle(fontWeight: FontWeight.w600, color: speedColor, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.flag_outlined, color: cutoffColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$cutoffStatus • $percentile',
                    style: TextStyle(fontWeight: FontWeight.w600, color: cutoffColor, fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
