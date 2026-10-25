import 'dart:math';
import 'package:flutter/material.dart';
import '../models/mistake.dart';
import '../models/study_progress.dart';
import '../models/practice_mode.dart';
import '../services/mistake_service.dart';
import '../services/local_storage_service.dart';
import '../services/question_service.dart';
import 'question_practice_screen.dart';

/// Smart Revision 2.0: Adaptive spaced-repetition engine strictly restricted
/// to COMPLETED TOPICS ONLY. Categorized into Today's Revision, Daily Revision,
/// Overdue Revision, and Subject-wise Revision.
class SmartRevision2Screen extends StatefulWidget {
  const SmartRevision2Screen({super.key});

  @override
  State<SmartRevision2Screen> createState() => _SmartRevision2ScreenState();
}

class _SmartRevision2ScreenState extends State<SmartRevision2Screen> {
  bool _loading = true;
  List<Mistake> _todayQueue = [];
  List<Mistake> _dailyQueue = [];
  List<Mistake> _overdueQueue = [];
  Map<String, List<Mistake>> _subjectMap = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool _matchesCompletedTopic(String subject, String subTopic, List<StudyProgress> completedTopics) {
    if (completedTopics.isEmpty) return false;
    final qSub = subject.trim().toLowerCase();
    final qTopic = subTopic.trim().toLowerCase();

    return completedTopics.any((p) {
      if (!p.completed) return false;
      final pSub = p.subject.trim().toLowerCase();
      final pTopic = p.topic.trim().toLowerCase();

      bool subjectMatches = pSub.isEmpty ||
          qSub == pSub ||
          qSub.contains(pSub) ||
          pSub.contains(qSub);

      if (!subjectMatches) return false;

      return qTopic == pTopic ||
          (qTopic.isNotEmpty && pTopic.isNotEmpty && (qTopic.contains(pTopic) || pTopic.contains(qTopic)));
    });
  }

  Future<void> _load() async {
    final results = await Future.wait([
      MistakeService.loadMistakes(),
      LocalStorageService.loadStudyProgress(),
    ]);

    final mistakes = results[0] as List<Mistake>;
    final progress = results[1] as List<StudyProgress>;
    final completedTopics = progress.where((p) => p.completed && p.topic.trim().isNotEmpty).toList();

    // Strictly filter revision questions to COMPLETED TOPICS ONLY
    final eligibleMistakes = mistakes.where((m) =>
      _matchesCompletedTopic(m.subject, m.subTopic, completedTopics)
    ).toList();

    final now = DateTime.now();

    final List<Mistake> todayList = [];
    final List<Mistake> dailyList = [];
    final List<Mistake> overdueList = [];
    final Map<String, List<Mistake>> subMap = {};

    for (final m in eligibleMistakes) {
      DateTime last;
      try {
        last = DateTime.parse(m.lastWrongDate);
      } catch (_) {
        last = now;
      }
      final daysAgo = now.difference(last).inDays;

      if (daysAgo == 0 || (daysAgo <= 1 && m.wrongCount >= 2)) {
        todayList.add(m);
      } else if (daysAgo >= 4) {
        overdueList.add(m);
      } else {
        dailyList.add(m);
      }

      final subject = m.subject.isNotEmpty ? m.subject : 'General Technical';
      subMap.putIfAbsent(subject, () => []).add(m);
    }

    // Sort queues by priority
    todayList.sort((a, b) => _priority(b).compareTo(_priority(a)));
    dailyList.sort((a, b) => _priority(b).compareTo(_priority(a)));
    overdueList.sort((a, b) => _priority(b).compareTo(_priority(a)));

    // Fallback: If Today's queue is empty but completed-topic mistakes exist, take top priority items
    if (todayList.isEmpty && eligibleMistakes.isNotEmpty) {
      final sortedAll = List<Mistake>.from(eligibleMistakes)..sort((a, b) => _priority(b).compareTo(_priority(a)));
      todayList.addAll(sortedAll.take(10));
    }

    if (!mounted) return;
    setState(() {
      _todayQueue = todayList;
      _dailyQueue = dailyList;
      _overdueQueue = overdueList;
      _subjectMap = subMap;
      _loading = false;
    });
  }

  int _priority(Mistake m) {
    final wrong = m.wrongCount.clamp(1, 10).toInt();
    DateTime last;
    try {
      last = DateTime.parse(m.lastWrongDate);
    } catch (_) {
      last = DateTime.now();
    }
    final days = DateTime.now().difference(last).inDays;
    final dueBoost = days >= 8 ? 4 : days >= 4 ? 3 : days >= 2 ? 2 : 1;
    return (wrong * 10) + dueBoost;
  }

  String _status(Mistake m) {
    DateTime last;
    try {
      last = DateTime.parse(m.lastWrongDate);
    } catch (_) {
      return 'Review now';
    }
    final days = DateTime.now().difference(last).inDays;
    if (days >= 8) return 'Final check due';
    if (days >= 4) return 'Revision due';
    if (days >= 2) return 'Retry due';
    return 'Today\'s priority';
  }

  Future<void> _startRevisionForQueue(List<Mistake> queue, String title) async {
    final selected = queue.take(15).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('વધુ પ્રશ્નો મેળવવા માટે પહેલા વધુ Topic Complete કરો.')),
      );
      return;
    }

    final questions = await QuestionService.getQuestionsByIds(
      selected.map((m) => m.questionId).toList(),
    );

    if (!mounted) return;
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('વધુ પ્રશ્નો મેળવવા માટે પહેલા વધુ Topic Complete કરો.')),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionPracticeScreen(
          questions: questions,
          subject: 'Smart Revision 2.0',
          subTopic: title,
          config: PracticeConfig.topicTest,
        ),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Smart Revision 2.0 - Spaced Repetition'),
          actions: [
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Queue',
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.teal,
            labelColor: Colors.teal.shade800,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                icon: const Icon(Icons.today, size: 18),
                text: 'Today\'s (${_todayQueue.length})',
              ),
              Tab(
                icon: const Icon(Icons.date_range, size: 18),
                text: 'Daily (${_dailyQueue.length})',
              ),
              Tab(
                icon: const Icon(Icons.update, size: 18),
                text: 'Overdue (${_overdueQueue.length})',
              ),
              Tab(
                icon: const Icon(Icons.category, size: 18),
                text: 'By Subject (${_subjectMap.length})',
              ),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildQueueTab("Today's Revision Dose (આજનો રિવિઝન)", _todayQueue, Colors.teal),
                  _buildQueueTab("Daily Revision Queue (દૈનિક રિવિઝન)", _dailyQueue, Colors.blue),
                  _buildQueueTab("Overdue Revision (અગાઉનું રિવિઝન)", _overdueQueue, Colors.orange),
                  _buildSubjectTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildQueueTab(String title, List<Mistake> queue, Color color) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: color.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: color.withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: color, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    queue.isEmpty
                        ? 'વધુ પ્રશ્નો મેળવવા માટે પહેલા વધુ Topic Complete કરો.'
                        : '${queue.length} question${queue.length == 1 ? '' : 's'} ready for adaptive revision.',
                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                  ),
                  if (queue.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _startRevisionForQueue(queue, title),
                        icon: const Icon(Icons.play_arrow),
                        label: Text('Start $title (${min(15, queue.length)})'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (queue.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: const [
                    Icon(Icons.lock_clock_outlined, color: Colors.orange, size: 48),
                    SizedBox(height: 10),
                    Text(
                      'વધુ પ્રશ્નો મેળવવા માટે પહેલા વધુ Topic Complete કરો.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Complete study topics to unlock adaptive revision queue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            ...queue.map((m) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _priority(m) >= 30 ? Colors.red.shade50 : color.withValues(alpha: 0.15),
                      child: Icon(
                        _priority(m) >= 30 ? Icons.priority_high : Icons.replay,
                        color: _priority(m) >= 30 ? Colors.red : color,
                      ),
                    ),
                    title: Text(
                      m.subTopic.isEmpty ? 'General Question' : m.subTopic,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text('${m.subject}\nWrong ${m.wrongCount}× • ${_status(m)}'),
                    isThreeLine: true,
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildSubjectTab() {
    if (_subjectMap.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_clock_outlined, color: Colors.orange, size: 48),
              SizedBox(height: 12),
              Text(
                'વધુ પ્રશ્નો મેળવવા માટે પહેલા વધુ Topic Complete કરો.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    final subjects = _subjectMap.keys.toList()..sort();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final sub = subjects[index];
          final queue = _subjectMap[sub] ?? [];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal.shade50,
                child: Text('${index + 1}', style: TextStyle(color: Colors.teal.shade900, fontWeight: FontWeight.bold)),
              ),
              title: Text(sub, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: Text('${queue.length} mistake questions due'),
              trailing: ElevatedButton(
                onPressed: () => _startRevisionForQueue(queue, '$sub Revision'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Start'),
              ),
            ),
          );
        },
      ),
    );
  }
}
