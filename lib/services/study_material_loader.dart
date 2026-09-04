import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/study_material.dart';
import '../models/formula.dart';
import '../models/quick_revision.dart';

class StudyMaterialLoader {
  static List<dynamic>? _cachedMasterData;

  static void reloadContent() {
    _cachedMasterData = null;
  }

  static Future<void> _ensureMasterDataLoaded() async {
    if (_cachedMasterData != null) return;

    try {
      String jsonString;
      try {
        final docDir = await getApplicationDocumentsDirectory();
        final updatedFile = File('${docDir.path}/updated_content/master_study_material.json');
        if (await updatedFile.exists()) {
          jsonString = await updatedFile.readAsString();
        } else {
          jsonString = await rootBundle.loadString(
            'assets/study_material/master_study_material.json',
          );
        }
      } catch (_) {
        jsonString = await rootBundle.loadString(
          'assets/study_material/master_study_material.json',
        );
      }
      _cachedMasterData = jsonDecode(jsonString);
    } catch (e) {
      debugPrint('Error loading master study material JSON: $e');
    }
  }

  static Future<List<StudyMaterial>> loadSubject(
    String subjectName,
  ) async {
    try {
      await _ensureMasterDataLoaded();
      if (_cachedMasterData == null) return [];

      final normalizedInput = subjectName.trim().toLowerCase();

      final subjectEntry = _cachedMasterData!.firstWhere(
        (element) {
          final entryName = (element['subject'] as String? ?? '').trim().toLowerCase();
          return entryName == normalizedInput;
        },
        orElse: () => null,
      );

      if (subjectEntry == null || subjectEntry['topics'] == null) {
        debugPrint('No study material found for: $subjectName');
        return [];
      }

      final List<dynamic> topicsJson = subjectEntry['topics'];
      final materials = <StudyMaterial>[];

      for (final item in topicsJson) {
        if (item is! Map) continue;

        try {
          final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item);
          itemMap['subject'] = subjectEntry['subject'] ?? subjectName;

          materials.add(
            StudyMaterial.fromJson(itemMap),
          );
        } catch (e) {
          debugPrint('Error parsing study material item: $e');
        }
      }

      debugPrint('Successfully loaded ${materials.length} topics for $subjectName');
      return materials;
    } catch (e) {
      debugPrint('Error loading study material for $subjectName: $e');
      return [];
    }
  }

  static Future<List<Formula>> loadAllFormulas() async {
    try {
      final jsonString = await rootBundle.loadString('assets/study_material/formulas.json');
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => Formula.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error loading formulas: $e');
      return [];
    }
  }

  static Future<List<QuickRevision>> loadAllQuickRevisions() async {
    try {
      final jsonString = await rootBundle.loadString('assets/study_material/quick_revision.json');
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => QuickRevision.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error loading quick revisions: $e');
      return [];
    }
  }

  static Future<List<StudyMaterial>> loadAllMaterials() async {
    try {
      await _ensureMasterDataLoaded();
      if (_cachedMasterData == null) return [];

      final List<StudyMaterial> all = [];
      for (final subjectEntry in _cachedMasterData!) {
        final subjectName = subjectEntry['subject'] as String? ?? '';
        final List<dynamic> topicsJson = subjectEntry['topics'] ?? [];

        for (final item in topicsJson) {
          if (item is! Map) continue;
          try {
            final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item);
            itemMap['subject'] = subjectName;
            all.add(StudyMaterial.fromJson(itemMap));
          } catch (e) {
            debugPrint('Error parsing study material item: $e');
          }
        }
      }
      return all;
    } catch (e) {
      debugPrint('Error loading all study materials: $e');
      return [];
    }
  }
}
