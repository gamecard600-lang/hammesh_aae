import '../models/study_material.dart';

class StudyMaterialSearchService {
  static List<StudyMaterial> search({
    required List<StudyMaterial> materials,
    required String query,
    String? subject,
  }) {
    final q = query.trim().toLowerCase();

    return materials.where((m) {
      // Apply subject filter if selected
      if (subject != null && m.subject != subject) {
        return false;
      }

      if (q.isEmpty) return true;

      final titleMatch = m.title.toLowerCase().contains(q);
      final subjectMatch = m.subject.toLowerCase().contains(q);
      final topicMatch = m.topic.toLowerCase().contains(q);
      final overviewMatch = m.overview.toLowerCase().contains(q);
      
      final keyPointsMatch = m.keyPoints.any((p) => p.toLowerCase().contains(q));
      final formulasMatch = m.formulas.any((f) => f.toLowerCase().contains(q));
      final importantPointsMatch = m.importantPoints.any((p) => p.toLowerCase().contains(q));
      final examPointsMatch = m.examPoints.any((p) => p.toLowerCase().contains(q));

      return titleMatch || 
             subjectMatch || 
             topicMatch || 
             overviewMatch || 
             keyPointsMatch || 
             formulasMatch || 
             importantPointsMatch || 
             examPointsMatch;
    }).toList();
  }
}
