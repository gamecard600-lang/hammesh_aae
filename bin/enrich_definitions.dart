import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/study_material/master_study_material.json');
  if (!file.existsSync()) {
    stdout.writeln('Error: master_study_material.json not found!');
    return;
  }

  final content = file.readAsStringSync();
  final List<dynamic> subjects = jsonDecode(content);

  int enrichedCount = 0;

  for (final subj in subjects) {
    final List<dynamic> topics = subj['topics'] ?? [];
    for (final topic in topics) {
      final String overview = (topic['overview'] ?? '').toString();
      final String concept = (topic['concept'] ?? '').toString();
      final String detailedTheory = (topic['detailedTheory'] ?? '').toString();
      final List<dynamic> keyPoints = topic['keyPoints'] ?? [];
      final List<dynamic> importantPoints = topic['importantPoints'] ?? [];
      final List<dynamic> examPoints = topic['examPoints'] ?? [];

      final sources = [
        overview,
        concept,
        detailedTheory,
        ...keyPoints.map((e) => e.toString()),
        ...importantPoints.map((e) => e.toString()),
        ...examPoints.map((e) => e.toString()),
      ];

      final List<dynamic> rawDefs = topic['definitions'] ?? [];
      final newDefs = <dynamic>[];

      for (final def in rawDefs) {
        if (def is String) {
          final trimmed = def.trim();
          if (trimmed.isEmpty) continue;

          if (trimmed.contains(':') && trimmed.split(':')[0].trim().isNotEmpty && trimmed.split(':')[1].trim().isNotEmpty) {
            newDefs.add(trimmed);
          } else {
            final cleanTerm = trimmed.contains(':') ? trimmed.split(':')[0].trim() : trimmed;
            final lowerTerm = cleanTerm.toLowerCase();

            String foundMeaning = '';
            for (final src in sources) {
              final sentences = src.split(RegExp(r'(?<=[.!?])\s+'));
              for (final sentence in sentences) {
                if (sentence.toLowerCase().contains(lowerTerm)) {
                  foundMeaning = sentence.trim();
                  break;
                }
              }
              if (foundMeaning.isNotEmpty) break;
            }

            if (foundMeaning.isEmpty) {
              if (concept.trim().isNotEmpty) {
                foundMeaning = concept.trim();
              } else if (overview.trim().isNotEmpty) {
                foundMeaning = overview.trim();
              } else if (detailedTheory.trim().isNotEmpty) {
                foundMeaning = detailedTheory.trim().split(RegExp(r'[.!?]')).first;
              }
            }

            if (foundMeaning.isNotEmpty) {
              // Ensure sentence ends nicely
              if (!foundMeaning.endsWith('.') && !foundMeaning.endsWith('!') && !foundMeaning.endsWith('?')) {
                foundMeaning += '.';
              }
              newDefs.add('$cleanTerm: $foundMeaning');
              enrichedCount++;
            } else {
              newDefs.add(cleanTerm);
            }
          }
        } else if (def is Map) {
          final term = (def['term'] ?? '').toString().trim();
          final meaning = (def['definition'] ?? '').toString().trim();
          if (term.isNotEmpty && meaning.isNotEmpty) {
            newDefs.add('$term: $meaning');
            enrichedCount++;
          } else {
            newDefs.add(def);
          }
        } else {
          newDefs.add(def);
        }
      }

      topic['definitions'] = newDefs;
    }
  }

  final encoder = const JsonEncoder.withIndent('  ');
  file.writeAsStringSync(encoder.convert(subjects));
  stdout.writeln('Successfully enriched $enrichedCount definitions in master_study_material.json!');
}
