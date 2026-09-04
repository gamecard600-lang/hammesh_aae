import 'package:flutter/material.dart';
import '../../models/exam_history.dart';
import '../../models/study_progress.dart';
import '../../services/ai_study_assistant_service.dart';
import '../../services/local_storage_service.dart';

class AiStudyPlanScreen extends StatefulWidget {
  const AiStudyPlanScreen({super.key});

  @override
  State<AiStudyPlanScreen> createState() => _AiStudyPlanScreenState();
}

class _AiStudyPlanScreenState extends State<AiStudyPlanScreen> {
  bool _isLoading = true;
  Map<String, int> _topicMistakes = {};
  List<ExamHistory> _history = [];
  List<StudyProgress> _progress = [];

  String _weakAreasAnalysis = '';
  String _studyPlanText = '';
  bool _isGeneratingAnalysis = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      LocalStorageService.loadTopicMistakes(),
      LocalStorageService.loadExamHistory(),
      LocalStorageService.loadStudyProgress(),
    ]);

    _topicMistakes = results[0] as Map<String, int>;
    _history = results[1] as List<ExamHistory>;
    _progress = results[2] as List<StudyProgress>;

    setState(() {
      _isLoading = false;
    });

    _generateAiInsights();
  }

  Future<void> _generateAiInsights() async {
    setState(() {
      _isGeneratingAnalysis = true;
    });

    final weakFuture = AiStudyAssistantService.analyzeWeakAreas(
      topicMistakes: _topicMistakes,
      history: _history,
    );

    final planFuture = AiStudyAssistantService.generateStudyPlan(
      topicMistakes: _topicMistakes,
      history: _history,
      progress: _progress,
    );

    final outcomes = await Future.wait([weakFuture, planFuture]);

    if (!mounted) return;
    setState(() {
      _weakAreasAnalysis = outcomes[0];
      _studyPlanText = outcomes[1];
      _isGeneratingAnalysis = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach & Study Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateAiInsights,
            tooltip: 'રિફ્રેશ કરો',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMotivationalHeader(),
                const SizedBox(height: 16),
                _buildWeakTopicsSummaryCard(),
                const SizedBox(height: 20),
                _buildAiSectionCard(
                  title: '🎯 AI Weakness Coach (નબળા ટોપિક્સ)',
                  icon: Icons.psychology,
                  iconColor: Colors.orange,
                  content: _weakAreasAnalysis,
                  isLoading: _isGeneratingAnalysis,
                ),
                const SizedBox(height: 20),
                _buildAiSectionCard(
                  title: '📅 Personalized Daily Study Plan',
                  icon: Icons.event_note,
                  iconColor: Colors.blue,
                  content: _studyPlanText,
                  isLoading: _isGeneratingAnalysis,
                ),
                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _buildMotivationalHeader() {
    double avgAccuracy = 0;
    if (_history.isNotEmpty) {
      avgAccuracy = _history.fold<double>(0, (p, e) => p + e.accuracy) / _history.length;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.indigo.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              const Text(
                '🎯 AI Achievement Insights',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            avgAccuracy > 0
                ? 'તમારી સરેરાશ ટેસ્ટ Accuracy ${avgAccuracy.toStringAsFixed(1)}% છે! નબળા ટોપિક્સ પર ધ્યાન આપીને તેને 85%+ સુધી લઈ જાઓ.'
                : 'નિયમિત ટોપિક વાઈઝ ટેસ્ટ આપીને તમારો પર્સનલાઈઝડ AI સ્ટડી પ્લાન મેળવો.',
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildWeakTopicsSummaryCard() {
    final sortedMistakes = _topicMistakes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🤖 My Weak Areas Breakdown',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            if (sortedMistakes.isEmpty)
              const Text('હજુ કોઈ નબળા ટોપિક નોંધાયા નથી. ખુબ સરસ!', style: TextStyle(color: Colors.grey))
            else
              ...sortedMistakes.take(5).map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '• ${e.key}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            '${e.value} મિસ્ટેક્સ',
                            style: TextStyle(fontSize: 11, color: Colors.red.shade700, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildAiSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String content,
    required bool isLoading,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('AI એનાલિસિસ કરી રહ્યું છે...', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              SelectableText(
                content.isNotEmpty ? content : 'એનાલિસિસ ડેટા ઉપલબ્ધ નથી.',
                style: const TextStyle(fontSize: 13.5, height: 1.5),
              ),
          ],
        ),
      ),
    );
  }
}
