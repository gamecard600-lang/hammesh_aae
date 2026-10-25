import 'package:flutter/material.dart';

import '../../data/subjects.dart';
import 'study_material_topic_list_screen.dart';
import '../progress_screen.dart';

class StudyMaterialSubjectsScreen extends StatelessWidget {
  final String category;

  const StudyMaterialSubjectsScreen({
    super.key,
    this.category = 'Technical',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Study Material - $category')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue.shade50.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.blue.shade200),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bar_chart, color: Colors.blue, size: 26),
              ),
              title: const Text('Performance & Progress Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: const Text('Score trends, weak topics & test history analytics'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen())),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Technical Subjects',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          ...technicalSubjects.map((subject) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text('${technicalSubjects.indexOf(subject) + 1}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudyMaterialTopicListScreen(subject: subject))),
                ),
              )),
        ],
      ),
    );
  }
}
