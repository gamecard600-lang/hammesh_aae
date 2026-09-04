import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/question.dart';

class QuestionService {
  static final Map<String, List<Question>> _cache = {};

  static const Map<String, String> subjectFiles = {
    'Thermodynamics': 'thermodynamics.json',
    'Fluid Mechanics': 'fluid_mechanics.json',
    'Power Engineering': 'power_engineering.json',
    'I.C. Engines': 'ic_engines.json',
    'Refrigeration & Air Conditioning': 'refrigeration_air_conditioning.json',
    'Engineering Mechanics': 'engineering_mechanics.json',
    'Mechanics of Materials': 'mechanics_of_materials.json',
    'Kinematics & Theory of Machines': 'kinematics_theory_of_machines.json',
    'Engineering Materials': 'engineering_materials.json',
    'Manufacturing Processes': 'manufacturing_processes.json',
    'Metrology & Inspection': 'metrology_inspection.json',
    'Computer Integrated Manufacturing': 'computer_integrated_manufacturing.json',
    'Operations Research': 'operations_research.json',
    'Current Trends & Recent Advancements': 'current_trends_recent_advancements.json',
  };

  static Future<List<Question>> loadQuestionsBySubject(String subject) async {
    if (_cache.containsKey(subject)) {
      return _cache[subject]!;
    }

    final fileName = subjectFiles[subject];
    if (fileName == null) {
      debugPrint('Warning: No file mapping for subject: $subject');
      return [];
    }

    try {
      String jsonString;
      
      // Check for locally downloaded content update first
      try {
        final docDir = await getApplicationDocumentsDirectory();
        final updatedFile = File('${docDir.path}/updated_content/questions/$fileName');
        if (await updatedFile.exists()) {
          jsonString = await updatedFile.readAsString();
        } else {
          jsonString = await rootBundle.loadString('assets/questions/$fileName');
        }
      } catch (_) {
        jsonString = await rootBundle.loadString('assets/questions/$fileName');
      }

      final dynamic decoded = json.decode(jsonString);

      if (decoded is! List) {
        return [];
      }

      final questions = decoded
          .whereType<Map<String, dynamic>>()
          .map((json) => Question.fromJson(json))
          .toList();

      _cache[subject] = questions;
      return questions;
    } catch (e) {
      debugPrint('Error loading questions for $subject: $e');
      return [];
    }
  }

  static Future<Question?> getQuestionById(int id) async {
    for (final subject in subjectFiles.keys) {
      final questions = await loadQuestionsBySubject(subject);
      final found = questions.where((q) => q.id == id);
      if (found.isNotEmpty) return found.first;
    }
    return null;
  }

  static Future<List<Question>> getQuestionsByIds(List<int> ids) async {
    final List<Question> result = [];
    for (final id in ids) {
      final q = await getQuestionById(id);
      if (q != null) result.add(q);
    }
    return result;
  }

  static Future<List<Question>> loadQuestionsBySubTopic(
    String subject,
    String subTopic,
  ) async {
    final questions = await loadQuestionsBySubject(subject);
    final trimmedSubTopic = subTopic.trim();

    return questions
        .where((question) => question.subTopic == trimmedSubTopic)
        .toList();
  }

  static Future<List<Question>> loadQuestionsBySubjects(List<String> subjects) async {
    final List<Question> combined = [];
    for (final subject in subjects) {
      final questions = await loadQuestionsBySubject(subject);
      combined.addAll(questions);
    }
    return combined;
  }

  static void clearCache() {
    _cache.clear();
  }
}
