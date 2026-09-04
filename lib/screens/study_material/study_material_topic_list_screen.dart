import 'package:flutter/material.dart';
import '../../models/subject.dart';
import '../../models/study_material.dart';
import '../../models/study_progress.dart';
import '../../services/local_storage_service.dart';
import 'study_material_screen.dart';
import '../../services/study_material_loader.dart';

class StudyMaterialTopicListScreen extends StatefulWidget {
  final Subject subject;

  const StudyMaterialTopicListScreen({
    super.key,
    required this.subject,
  });

  @override
  State<StudyMaterialTopicListScreen> createState() => _StudyMaterialTopicListScreenState();
}

class _StudyMaterialTopicListScreenState extends State<StudyMaterialTopicListScreen> {
  List<StudyMaterial> materials = [];
  List<StudyProgress> progressList = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      debugPrint(
        'Study Material file: ${widget.subject.jsonFile}',
      );

      final loadedMaterials =
          await StudyMaterialLoader.loadSubject(
        widget.subject.name,
      );

      debugPrint(
        'Study Material count: ${loadedMaterials.length}',
      );

      final loadedProgress =
          await LocalStorageService.loadStudyProgress();

      if (!mounted) return;

      setState(() {
        materials = loadedMaterials;
        progressList = loadedProgress;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Study Material ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.name),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Error: $error', textAlign: TextAlign.center),
                ))
              : materials.isEmpty
                  ? const Center(child: Text('No study material available for this subject.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: materials.length,
                      itemBuilder: (context, index) {
                        final material = materials[index];
                        final isCompleted = progressList.any((p) =>
                            p.subject == material.subject &&
                            p.topic == material.topic &&
                            p.completed);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Icon(
                              isCompleted ? Icons.check_circle : Icons.book,
                              color: isCompleted ? Colors.green : Colors.blue,
                            ),
                            title: Text(
                              material.topic,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                color: isCompleted ? Colors.grey : null,
                              ),
                            ),
                            subtitle: Text(material.title),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudyMaterialScreen(
                                    material: material,
                                    subjectMaterials: materials,
                                  ),
                                ),
                              ).then((_) => _loadData());
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
