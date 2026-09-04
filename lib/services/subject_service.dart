import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/subject.dart';
import 'question_service.dart';

class SubjectService {
  static Future<List<Subject>> loadSubjects() async {
    try {
      final jsonString = await rootBundle.loadString('assets/questions/subjects.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((json) {
        final name = json['name'] as String;
        return Subject(
          name: name,
          jsonFile: QuestionService.subjectFiles[name] ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading subjects: $e');
      return [];
    }
  }
}
