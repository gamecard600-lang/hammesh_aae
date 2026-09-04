import 'package:flutter/material.dart';
import '../../models/study_bookmark.dart';
import '../../services/local_storage_service.dart';
import '../../services/study_material_loader.dart';
import 'study_material_screen.dart';

class SavedMaterialScreen extends StatefulWidget {
  const SavedMaterialScreen({super.key});

  @override
  State<SavedMaterialScreen> createState() => _SavedMaterialScreenState();
}

class _SavedMaterialScreenState extends State<SavedMaterialScreen> {
  List<StudyBookmark> bookmarks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final loaded = await LocalStorageService.loadStudyBookmarks();
    setState(() {
      bookmarks = loaded;
      isLoading = false;
    });
  }

  Future<void> _openMaterial(StudyBookmark bookmark) async {
    // We need to find the full StudyMaterial object. 
    // This is a bit complex because materials are split into subject files.
    // In a real app, we might want to store a mapping or search through all files.
    // For now, we'll try to load the subject file and find the topic.
    
    // We need the filename for the subject. In this app, it's usually name.json (lowercase).
    // But let's assume we can get it from the QuestionService mapping or similar logic.
    // For simplicity, let's just try subject.toLowerCase().replaceAll(' ', '_') + '.json'
    
    final subjectName = bookmark.subject;
    
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final materials = await StudyMaterialLoader.loadSubject(subjectName);
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading

      final material = materials.firstWhere(
        (m) => m.topic.trim() == bookmark.topic.trim(),
        orElse: () => throw Exception('Material not found'),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudyMaterialScreen(
            material: material,
            subjectMaterials: materials,
          ),
        ),
      ).then((_) => _loadBookmarks());
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open material: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Study Material'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookmarks.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No saved study materials yet.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final b = bookmarks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.book, size: 20),
                        ),
                        title: Text(b.topic, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(b.subject),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            await LocalStorageService.toggleStudyBookmark(b);
                            _loadBookmarks();
                          },
                        ),
                        onTap: () => _openMaterial(b),
                      ),
                    );
                  },
                ),
    );
  }
}
