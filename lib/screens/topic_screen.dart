import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../models/question.dart';
import '../models/practice_mode.dart';
import '../services/question_service.dart';
import 'question_practice_screen.dart';

class TopicScreen extends StatefulWidget {
  final Subject subject;

  const TopicScreen({
    super.key,
    required this.subject,
  });

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  List<String> subTopics = [];
  Map<String, int> subTopicCounts = {};
  List<Question> allQuestions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSubTopics();
  }

  Future<void> loadSubTopics() async {
    final questions = await QuestionService.loadQuestionsBySubject(widget.subject.name);
    
    final Map<String, int> counts = {};
    for (var q in questions) {
      final topic = q.subTopic;
      counts[topic] = (counts[topic] ?? 0) + 1;
    }

    final topics = counts.keys.toList()..sort();

    setState(() {
      allQuestions = questions;
      subTopicCounts = counts;
      subTopics = topics;
      isLoading = false;
    });
  }

  void openPractice(List<Question> questions, String? subTopic, PracticeConfig config) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionPracticeScreen(
          questions: questions,
          subject: widget.subject.name,
          subTopic: subTopic,
          config: config,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.name),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (allQuestions.isNotEmpty) ...[
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.all_inclusive, color: Colors.white),
                          ),
                          title: const Text(
                            'All Questions Practice',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text('${allQuestions.length} Total Questions'),
                          trailing: const Icon(Icons.play_arrow, color: Colors.blue),
                          onTap: () => openPractice(allQuestions, 'All Questions', PracticeConfig.practice),
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Icon(Icons.timer, color: Colors.white),
                          ),
                          title: const Text(
                            'Full Subject Mock Test',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('Timer + Negative Marking'),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () => openPractice(allQuestions, 'Subject Mock', PracticeConfig.subjectTest),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Topics',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                ],
                if (subTopics.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'આ Subject માટે sub-topics ઉપલબ્ધ નથી.',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  )
                else
                  ...subTopics.map((subTopic) {
                    final count = subTopicCounts[subTopic] ?? 0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${subTopics.indexOf(subTopic) + 1}'),
                        ),
                        title: Text(
                          subTopic,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text('$count Questions'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.timer_outlined, color: Colors.orange),
                              tooltip: 'Topic Test',
                              onPressed: () async {
                                final questions = await QuestionService.loadQuestionsBySubTopic(widget.subject.name, subTopic);
                                openPractice(questions, subTopic, PracticeConfig.topicTest);
                              },
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 18),
                          ],
                        ),
                        onTap: () async {
                          final questions = await QuestionService.loadQuestionsBySubTopic(widget.subject.name, subTopic);
                          openPractice(questions, subTopic, PracticeConfig.practice);
                        },
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
