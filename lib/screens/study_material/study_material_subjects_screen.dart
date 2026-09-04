import 'package:flutter/material.dart';

import '../../data/subjects.dart';
import 'study_material_topic_list_screen.dart';

class StudyMaterialSubjectsScreen extends StatelessWidget {
  final String category;

  const StudyMaterialSubjectsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Study Material - $category'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: technicalSubjects.length,
        itemBuilder: (context, index) {
          final subject = technicalSubjects[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text('${index + 1}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
              ),
              title: Text(
                subject.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
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
          );
        },
      ),
    );
  }
}
