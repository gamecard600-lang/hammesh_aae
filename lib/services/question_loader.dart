import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/question.dart';
import '../data/subject_json_map.dart';

class QuestionLoader {
  static Future<List<Question>> loadQuestions(String path) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      final decoded = jsonDecode(jsonString);

      if (decoded is! List) {
        throw const FormatException(
          'JSON must contain a List of questions',
        );
      }

      return decoded
          .map<Question>(
            (item) => Question.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to load questions from $path: $e',
      );
    }
  }

  static Future<List<Question>> loadSubject(
    String subjectFile,
  ) async {
    return loadQuestions(
      'assets/questions/$subjectFile',
    );
  }

  static Future<List<Question>> loadBySubject(
    String subject,
  ) async {
    final file = SubjectJsonMap.files[subject];

    if (file == null) {
      throw Exception(
        'No JSON file mapped for subject: $subject',
      );
    }

    return loadSubject(file);
  }
}
