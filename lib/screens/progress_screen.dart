import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exam_history.dart';
import '../models/exam_result.dart';
import '../data/subjects.dart';
import '../services/local_storage_service.dart';
import '../services/question_service.dart';
import 'result_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<ExamHistory> _history = [];
  Map<String, int> _topicMistakes = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final history = await LocalStorageService.loadExamHistory();
    final mistakes = await LocalStorageService.loadTopicMistakes();
    
    if (mounted) {
      setState(() {
        _history = history;
        _topicMistakes = mistakes;
        _isLoading = false;
      });
    }
  }

  double get _avgScore {
    if (_history.isEmpty) return 0;
    return _history.map((e) => e.percentage).reduce((a, b) => a + b) / _history.length;
  }

  double get _bestScore {
    if (_history.isEmpty) return 0;
    return _history.map((e) => e.percentage).reduce((a, b) => a > b ? a : b);
  }

  double get _avgAccuracy {
    if (_history.isEmpty) return 0;
    return _history.map((e) => e.accuracy).reduce((a, b) => a + b) / _history.length;
  }

  int get _totalSolved {
    return _history.fold(0, (sum, e) => sum + e.correct + e.wrong);
  }

  List<MapEntry<String, int>> get _weakTopics {
    final sorted = _topicMistakes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  Map<String, double> get _subjectAverages {
    final Map<String, List<double>> subjectScores = {};
    for (var h in _history) {
      subjectScores.putIfAbsent(h.subject, () => []).add(h.percentage);
    }

    final Map<String, double> avgs = {};
    subjectScores.forEach((subject, scores) {
      avgs[subject] = scores.reduce((a, b) => a + b) / scores.length;
    });
    return avgs;
  }

  Future<void> _clearAllProgress() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Progress?'),
        content: const Text('આનાથી તમારી બધી જ ટેસ્ટ હિસ્ટ્રી અને મિસ્ટેક્સ ડિલીટ થઈ જશે.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await LocalStorageService.clearAll();
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearAllProgress,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildOverallStats(),
                  const SizedBox(height: 24),
                  _buildPerformanceChart(),
                  const SizedBox(height: 24),
                  _buildWeakTopics(),
                  const SizedBox(height: 24),
                  _buildSubjectPerformance(),
                  const SizedBox(height: 24),
                  _buildRecentHistory(),
                  const SizedBox(height: 32),
                  _buildDataManagement(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildOverallStats() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Overall Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('${_history.length}', 'Tests'),
                _buildStatItem('${_bestScore.toStringAsFixed(0)}%', 'Best'),
                _buildStatItem('${_avgScore.toStringAsFixed(0)}%', 'Avg'),
                _buildStatItem('${_avgAccuracy.toStringAsFixed(0)}%', 'Accuracy'),
              ],
            ),
            const SizedBox(height: 20),
            Text('Total Questions Solved: $_totalSolved', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    if (_history.isEmpty) return const SizedBox.shrink();

    // Take last 10 tests and reverse to show chronologically
    final recentHistory = _history.take(10).toList().reversed.toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📈 Score Trend (Last 10 Tests)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (recentHistory.length - 1).toDouble(),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: recentHistory.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.percentage);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildWeakTopics() {
    final weak = _weakTopics;
    if (weak.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('⚠ Weak Topics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
        const SizedBox(height: 10),
        ...weak.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            title: Text(e.key),
            trailing: Text('${e.value} mistakes', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        )),
      ],
    );
  }

  Widget _buildSubjectPerformance() {
    final subjectAvgs = _subjectAverages;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('વિષય મુજબ પરફોર્મન્સ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...technicalSubjects.map((s) {
          final avg = subjectAvgs[s.name] ?? 0;
          Color barColor = Colors.red;
          if (avg >= 80) {
            barColor = Colors.teal;
          } else if (avg >= 70) {
            barColor = Colors.blue;
          } else if (avg >= 50) {
            barColor = Colors.orange;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          s.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${avg.toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.bold, color: barColor)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: avg / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentHistory() {
    if (_history.isEmpty) return const SizedBox.shrink();
    final recent = _history.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Test History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...recent.map((h) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            dense: true,
            onTap: () async {
              final result = h.toExamResult();
              if (result.questions.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(result: result),
                  ),
                );
              } else {
                final questions = await QuestionService.loadQuestionsBySubject(h.subject);
                final fallbackResult = ExamResult(
                  subject: h.subject,
                  subTopic: h.subTopic,
                  totalQuestions: h.totalQuestions,
                  correct: h.correct,
                  wrong: h.wrong,
                  skipped: h.skipped,
                  score: h.score,
                  percentage: h.percentage,
                  accuracy: h.accuracy,
                  questions: questions.take(h.totalQuestions).toList(),
                  selectedAnswers: List.filled(h.totalQuestions, null),
                  selectedMSQAnswers: List.generate(h.totalQuestions, (_) => []),
                  date: h.date,
                );
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(result: fallbackResult),
                    ),
                  );
                }
              }
            },
            title: Text(h.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(h.subTopic),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${h.percentage.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                Text(h.date.contains('T') ? h.date.split('T')[0] : h.date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildDataManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showBackupDialog,
                icon: const Icon(Icons.backup),
                label: const Text('Backup'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade50, foregroundColor: Colors.blue),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showRestoreDialog,
                icon: const Icon(Icons.restore),
                label: const Text('Restore'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade50, foregroundColor: Colors.green),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showBackupDialog() async {
    final json = await LocalStorageService.generateBackupJson();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('તમારો બેકઅપ કોડ કોપી કરો:'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
              child: Text(json, maxLines: 5, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: json));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup copied to clipboard!')));
              Navigator.pop(context);
            },
            child: const Text('Copy All'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('બેકઅપ કોડ અહીં પેસ્ટ કરો:'),
            const SizedBox(height: 10),
            TextField(controller: controller, maxLines: 5, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Paste JSON here...'), style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              try {
                if (controller.text.isEmpty) return;
                await LocalStorageService.restoreFromBackupJson(controller.text);
                if (!mounted) return;
                navigator.pop();
                _loadData();
                messenger.showSnackBar(const SnackBar(content: Text('Data restored successfully!')));
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(const SnackBar(content: Text('Invalid backup data!')));
              }
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }
}
