import 'package:flutter/material.dart';
import '../../models/quick_revision.dart';
import '../../services/study_material_loader.dart';

class QuickRevisionScreen extends StatefulWidget {
  const QuickRevisionScreen({super.key});

  @override
  State<QuickRevisionScreen> createState() => _QuickRevisionScreenState();
}

class _QuickRevisionScreenState extends State<QuickRevisionScreen> {
  List<QuickRevision> revisions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRevisions();
  }

  Future<void> _loadRevisions() async {
    final loaded = await StudyMaterialLoader.loadAllQuickRevisions();
    setState(() {
      revisions = loaded;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Revision'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : revisions.isEmpty
              ? const Center(child: Text('No revision points available.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: revisions.length,
                  itemBuilder: (context, index) {
                    final r = revisions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        leading: const Icon(Icons.bolt, color: Colors.amber),
                        title: Text(
                          r.topic,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(r.subject),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...r.points.map((point) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.check_circle_outline,
                                              size: 18, color: Colors.green),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(point)),
                                        ],
                                      ),
                                    )),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.lightbulb_outline, size: 20, color: Colors.amber),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Focus on these points for last-minute preparation.',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
