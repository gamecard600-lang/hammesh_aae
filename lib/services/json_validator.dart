import 'dart:convert';
import 'package:flutter/services.dart';

class JsonValidationResult {
  final String file;
  final bool valid;
  final int questionCount;
  final List<String> errors;

  JsonValidationResult({
    required this.file,
    required this.valid,
    required this.questionCount,
    required this.errors,
  });
}

class JsonValidator {
  static Future<JsonValidationResult> validate(
    String file,
  ) async {
    final errors = <String>[];
    int questionCount = 0;

    try {
      final raw = await rootBundle.loadString(
        'assets/questions/$file',
      );

      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        errors.add('Root must be a JSON List');
      } else {
        questionCount = decoded.length;

        for (int i = 0; i < decoded.length; i++) {
          final q = decoded[i];

          if (q is! Map) {
            errors.add('Question ${i + 1}: invalid object');
            continue;
          }

          if (q['id'] == null) {
            errors.add('Question ${i + 1}: missing id');
          }

          if (q['question'] == null) {
            errors.add('Question ${i + 1}: missing question');
          }

          if (q['options'] is! List ||
              (q['options'] as List).isEmpty) {
            errors.add(
              'Question ${i + 1}: options missing/empty',
            );
          }

          if (q['correctAnswer'] == null &&
              q['correctAnswers'] == null) {
            errors.add(
              'Question ${i + 1}: correct answer missing',
            );
          }

          if (q['explanation'] == null) {
            errors.add(
              'Question ${i + 1}: explanation missing',
            );
          }
        }
      }
    } catch (e) {
      errors.add('JSON load/parse error: $e');
    }

    return JsonValidationResult(
      file: file,
      valid: errors.isEmpty,
      questionCount: questionCount,
      errors: errors,
    );
  }
}
