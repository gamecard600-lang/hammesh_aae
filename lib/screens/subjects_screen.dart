import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../models/practice_mode.dart';
import '../data/subjects.dart';
import '../services/question_service.dart';
import 'topic_screen.dart';
import 'question_practice_screen.dart';
import 'study_material/study_material_topic_list_screen.dart';

class SubjectsScreen extends StatefulWidget {
  final String category;

  const SubjectsScreen({
    super.key,
    required this.category,
  });

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  List<Subject> subjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSubjects();
  }

  void loadSubjects() {
    if (widget.category == 'Technical') {
      setState(() {
        subjects = technicalSubjects;
        isLoading = false;
      });
    } else {
      // Handle other categories or empty list
      setState(() {
        subjects = [];
        isLoading = false;
      });
    }
  }

  Future<void> openFullPractice(Subject subject) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final questions = await QuestionService.loadQuestionsBySubject(subject.name);

    if (!mounted) return;
    Navigator.pop(context); // Remove loading dialog

    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('આ Subject માટે પ્રશ્નો ઉપલબ્ધ નથી.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionPracticeScreen(
          questions: questions,
          subject: subject.name,
          config: PracticeConfig.subjectTest,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text(
                subject.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu_book, color: Colors.purple),
                    tooltip: 'Study Material',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudyMaterialTopicListScreen(
                            subject: subject,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.quiz, color: Colors.blue),
                    tooltip: 'Full Practice',
                    onPressed: () => openFullPractice(subject),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TopicScreen(
                      subject: subject,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
