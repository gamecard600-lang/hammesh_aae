import '../models/recommendation.dart';
import '../models/exam_history.dart';

class RecommendationService {
  static List<Recommendation> generate({
    required Map<String, int> topicMistakes,
    required List<ExamHistory> history,
  }) {
    if (topicMistakes.isEmpty) {
      return [
        const Recommendation(
          title: 'તૈયારી શરૂ કરો',
          subtitle: 'વધુ પ્રશ્નોની પ્રેક્ટિસ કરીને તમારી નબળાઈ જાણો.',
          topic: '',
          subject: '',
          questionCount: 20,
        ),
      ];
    }

    // Sort topics by mistake count
    final sortedMistakes = topicMistakes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final recommendations = <Recommendation>[];

    for (var entry in sortedMistakes.take(3)) {
      final subTopic = entry.key;
      final mistakeCount = entry.value;

      // Find the subject for this subTopic from history
      String subject = '';
      try {
        subject = history.firstWhere((h) => h.subTopic == subTopic).subject;
      } catch (_) {
        // If not in history (maybe from practice mode), we might need another way
        // For now, let's assume it's in history or skip if unknown
        continue;
      }

      recommendations.add(
        Recommendation(
          title: 'નબળો ટોપિક: $subTopic',
          subtitle: '$mistakeCount ભૂલો મળી. ૧૫ પ્રશ્નોની પ્રેક્ટિસ કરો.',
          topic: subTopic,
          subject: subject,
          questionCount: 15,
        ),
      );
    }

    if (recommendations.isEmpty) {
      return [
        const Recommendation(
          title: 'તમારી તૈયારી ચાલુ રાખો',
          subtitle: 'નવા મોક ટેસ્ટ આપીને તમારી સ્પીડ વધારો.',
          topic: '',
          subject: '',
          questionCount: 25,
        ),
      ];
    }

    return recommendations;
  }
}
