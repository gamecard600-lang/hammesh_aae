import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/ai_context.dart';
import '../models/exam_history.dart';
import '../models/study_progress.dart';
import 'local_storage_service.dart';

class AiStudyAssistantService {
  static const List<String> _modelCandidates = [
    'gemini-1.5-flash',
    'gemini-2.0-flash',
    'gemini-1.5-pro',
    'gemini-2.5-flash',
  ];

  /// Central Gemini API Call Routine
  static Future<String> _generateContent({
    required String prompt,
    required String systemInstruction,
  }) async {
    final rawKey = await LocalStorageService.loadAiApiKey();
    final apiKey = rawKey.trim().replaceAll('"', '').replaceAll("'", '');

    if (apiKey.isEmpty) {
      return _generateSmartOfflineFallback(prompt);
    }

    String lastErrorMessage = '';

    for (final model in _modelCandidates) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );

        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': '$systemInstruction\n\n$prompt'}
                    ]
                  }
                ],
                'generationConfig': {
                  'temperature': 0.3,
                  'maxOutputTokens': 1200,
                }
              }),
            )
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final String? text =
              decoded['candidates']?[0]?['content']?['parts']?[0]?['text'];
          if (text != null && text.trim().isNotEmpty) {
            return text.trim();
          }
        } else {
          final errorBody = response.body;
          debugPrint('Gemini API Error ($model - ${response.statusCode}): $errorBody');

          if (response.statusCode == 400 && errorBody.contains('API_KEY_INVALID')) {
            return '🔑 **Invalid Gemini API Key!**\n\nPlease check your API key in Settings ➔ Configure Gemini API Key.\nGet a free API Key from: https://aistudio.google.com/app/apikey';
          }
          if (response.statusCode == 429) {
            return '⏳ **Gemini API Limit Reached (429 Rate Limit)**\n\nPlease wait 1 minute before asking again.';
          }

          lastErrorMessage = 'API Error (${response.statusCode}): ${_extractMessage(errorBody)}';
        }
      } catch (e) {
        debugPrint('AI Request Exception ($model): $e');
        lastErrorMessage = 'Connection Error: $e';
      }
    }

    if (lastErrorMessage.isNotEmpty) {
      return '⚠️ **AI Response Failed:**\n$lastErrorMessage\n\n*Please verify your API key at https://aistudio.google.com/app/apikey*';
    }

    return _generateSmartOfflineFallback(prompt);
  }

  static String _extractMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded['error']?['message']?.toString() ?? body;
    } catch (_) {
      return body;
    }
  }

  static String _getSystemInstruction() {
    return '''
You are the "AAE Study Assistant", an expert AI Tutor designed specifically for GSSSB AAE (Additional Assistant Engineer) Mechanical Engineering Exam aspirants.

STRICT GUIDELINES:
1. Language: Use Gujarati primarily, but keep technical terms in English (e.g. Entropy, Thermodynamics, Heat Transfer, Stress, Strain, Rankine Cycle, Clearance Volume). Do NOT translate technical terms unnecessarily.
2. Accuracy: Ensure high technical accuracy for competitive exam preparation. Do NOT invent facts or formulas. Verify all calculations step-by-step.
3. Context Honor: Prioritize any provided Study Material or Question Explanation context. Never contradict the provided study material.
4. Formatting: Use clear bullet points, bold headings, and clean markdown formatting.
''';
  }

  /// 1. Topic Doubt Assistant / General Ask AI
  static Future<String> askDoubt({
    required AiContext context,
    required String userQuery,
    List<Map<String, String>> chatHistory = const [],
  }) async {
    final StringBuffer prompt = StringBuffer();
    prompt.writeln('CONTEXT:');
    prompt.writeln(context.toFormattedPrompt());

    if (chatHistory.isNotEmpty) {
      prompt.writeln('\nPREVIOUS CONVERSATION CONTEXT:');
      for (final msg in chatHistory.take(4)) {
        prompt.writeln('${msg['role'] == 'user' ? 'User' : 'Assistant'}: ${msg['text']}');
      }
    }

    prompt.writeln('\nUSER QUESTION:');
    prompt.writeln(userQuery);

    prompt.writeln('\nPlease provide a concise, exam-oriented explanation in Gujarati with English technical terms.');

    return await _generateContent(
      prompt: prompt.toString(),
      systemInstruction: _getSystemInstruction(),
    );
  }

  /// 2. Explain This (Concept / Paragraph / Formula)
  static Future<String> explainConcept({
    required AiContext context,
    required String conceptText,
  }) async {
    final prompt = '''
CONTEXT:
${context.toFormattedPrompt()}

TEXT TO EXPLAIN:
"$conceptText"

Please explain this in Gujarati (with English technical terms) using EXACTLY the following structure:

1. 💡 **Simple Explanation (સરળ સમજૂતી):**
[Explain simply in 2-3 sentences]

2. ⚙️ **Technical Explanation (ટેકનિકલ સમજૂતી):**
[Precise engineering description & principle]

3. 🌍 **Example (રિયલ લાઈફ / પ્રેક્ટિકલ ઉદાહરણ):**
[Real life or practical engineering example]

4. 🎯 **Exam Point (પરીક્ષા લક્ષી પોઈન્ટ):**
[Key point / formula / memory tip for GSSSB exam]
''';

    return await _generateContent(
      prompt: prompt.toString(),
      systemInstruction: _getSystemInstruction(),
    );
  }

  /// 3. Wrong Answer -> AI Mistake Explanation
  static Future<String> explainMistake({
    required AiContext context,
  }) async {
    final prompt = '''
EXAM MISTAKE ANALYSIS REQUEST:
${context.toFormattedPrompt()}

Please analyze the user's mistake in Gujarati (with English technical terms) strictly in this format:

1. ❌ **તમે પસંદ કરેલ જવાબ (User Selected):**
2. ✅ **સાચો જવાબ (Correct Answer):**
3. ⚠️ **તમારી ભૂલ શું હતી? (Mistake Analysis):**
4. 🧠 **સાચો કન્સેપ્ટ (Correct Concept):**
5. 🎯 **Exam / Memory Trick (યાદ રાખવાની શોર્ટ ટ્રીક):**
''';

    return await _generateContent(
      prompt: prompt.toString(),
      systemInstruction: _getSystemInstruction(),
    );
  }

  /// 4. Why Not Other Options?
  static Future<String> explainOtherOptions({
    required AiContext context,
  }) async {
    final prompt = '''
MCQ OPTIONS BREAKDOWN REQUEST:
${context.toFormattedPrompt()}

Explain in Gujarati (with English technical terms) why each option is correct or incorrect for this question:
- Option A: [Why right or wrong]
- Option B: [Why right or wrong]
- Option C: [Why right or wrong]
- Option D: [Why right or wrong]
''';

    return await _generateContent(
      prompt: prompt.toString(),
      systemInstruction: _getSystemInstruction(),
    );
  }

  /// 5. Step-by-Step Problem Solver (Numerical Questions)
  static Future<String> solveStepByStep({
    required AiContext context,
  }) async {
    final prompt = '''
NUMERICAL PROBLEM SOLVER REQUEST:
${context.toFormattedPrompt()}

Solve this numerical question step-by-step in Gujarati (with English technical terms) strictly using this structure:

```
Given:
Find:
Formula:
Substitution:
Calculation:
Final Answer:
Exam Shortcut:
```
''';

    return await _generateContent(
      prompt: prompt.toString(),
      systemInstruction: _getSystemInstruction(),
    );
  }

  /// 6. Quick Revision Generator
  static Future<String> generateQuickRevision({
    required AiContext context,
  }) async {
    final prompt = '''
TOPIC QUICK REVISION REQUEST:
${context.toFormattedPrompt()}

Generate an instant quick revision summary in Gujarati (with English technical terms) covering:
• 📌 **Important Concepts**
• 📐 **Important Formulas**
• 📖 **Key Definitions**
• ⚠️ **Common Mistakes**
• 🎯 **Exam Traps**
• ⚡ **Short Tricks**
''';

    return await _generateContent(
      prompt: prompt.toString(),
      systemInstruction: _getSystemInstruction(),
    );
  }

  /// 7. Weakness Coach Analysis
  static Future<String> analyzeWeakAreas({
    required Map<String, int> topicMistakes,
    required List<ExamHistory> history,
  }) async {
    final prompt = '''
USER PERFORMANCE DATA:
Topic Mistakes Count: ${jsonEncode(topicMistakes)}
Recent Tests Count: ${history.length}
Recent Test Scores: ${history.take(5).map((e) => '${e.subTopic}: ${e.accuracy.toStringAsFixed(1)}% accuracy').join(', ')}

Act as an AI Weakness Coach for GSSSB AAE Mechanical Exam. Analyze the user's weak areas and provide actionable guidance in Gujarati (with English technical terms):
1. 🎯 **ટોપ priority વિષયો / ટોપિક્સ (High Priority Weakness)**
2. 📈 **Accuracy પૃથ્થકરણ (Accuracy Insights)**
3. 💡 **સુધારા માટે પ્રેક્ટિકલ સલાહ (Actionable Advice)**
''';

    return await _generateContent(
      prompt: prompt.toString(),
      systemInstruction: _getSystemInstruction(),
    );
  }

  /// 8. Personalized Study Plan
  static Future<String> generateStudyPlan({
    required Map<String, int> topicMistakes,
    required List<ExamHistory> history,
    required List<StudyProgress> progress,
  }) async {
    final completedCount = progress.where((p) => p.completed).length;
    final prompt = '''
USER STUDY PROFILE:
- Completed Topics: $completedCount / 165
- Topic Mistakes Breakdown: ${jsonEncode(topicMistakes)}
- Average Recent Test Accuracy: ${history.isEmpty ? 'N/A' : (history.fold<double>(0, (p, e) => p + e.accuracy) / history.length).toStringAsFixed(1)}%

Generate a personalized Daily Study Plan in Gujarati (with English technical terms) tailored to fix weak areas and boost exam confidence.
Formatting example:
```text
Today's Study Plan

1. Weak Topic Focus (30 min)
2. Practice MCQs (20 min)
3. Mistake Revision (15 min)
4. Formula Revision (10 min)
```
''';

    return await _generateContent(
      prompt: prompt.toString(),
      systemInstruction: _getSystemInstruction(),
    );
  }

  /// 9. Exam Trap Detector
  static Future<String> detectExamTraps({
    required AiContext context,
  }) async {
    final prompt = '''
EXAM TRAP DETECTOR REQUEST:
${context.toFormattedPrompt()}

Identify the common exam traps, confusion points, or tricky tricks examiners use for this topic/question. Provide clear warnings in Gujarati (with English technical terms).
Example:
⚠️ **Common Exam Trap**
Heat ≠ Temperature
Heat = Energy Transfer (Joules)
Temperature = Thermal State (Kelvin/Celsius)
''';

    return await _generateContent(
      prompt: prompt.toString(),
      systemInstruction: _getSystemInstruction(),
    );
  }

  /// Smart Offline / Fallback Generator if AI key is unavailable or offline
  static String _generateSmartOfflineFallback(String prompt) {
    if (prompt.contains('NUMERICAL PROBLEM SOLVER')) {
      return '''
🤖 **AI Numerical Solver (Offline Mode)**
*AI temporarily unavailable (Set API key in Settings for live AI).*

**General Numerical Solver Template:**
```
Given: Identify values from the question text
Find: Required engineering property/variable
Formula: Apply relevant thermodynamic/mechanical relation
Substitution: Substitute given values carefully with SI units
Calculation: Double check arithmetic & conversion factors
Final Answer: Verify order of magnitude
Exam Shortcut: Dimensional analysis / ratio method
```
''';
    } else if (prompt.contains('EXAM MISTAKE ANALYSIS')) {
      return '''
🤖 **AI Mistake Analysis (Offline Mode)**
*AI temporarily unavailable (Set API key in Settings for live AI).*

1. ❌ **તમે પસંદ કરેલ જવાબ:** Check question options.
2. ✅ **સાચો જવાબ:** Check highlighted correct answer.
3. ⚠️ **સામાન્ય ભૂલ:** Check unit conversion, formula application, or question wording (NOT / EXCEPT).
4. 🧠 **મુખ્ય કન્સેપ્ટ:** Review explanation provided in study material.
5. 🎯 **Exam Tip:** Keep basic definitions clear and avoid hasty selection.
''';
    } else if (prompt.contains('MCQ OPTIONS BREAKDOWN')) {
      return '''
🤖 **Options Breakdown (Offline Mode)**
*AI temporarily unavailable (Set API key in Settings for live AI).*

- Refer to the detailed question explanation to understand why the highlighted answer is correct.
- Eliminate options that violate fundamental physical principles (e.g. 2nd Law of Thermodynamics, Conservation of Energy).
''';
    } else {
      return '''
🤖 **AAE Study Assistant (Offline / Standby)**

*AI connection temporarily unavailable. Your study/test continues normally.*

💡 **Study Tip:**
- Make sure to review the explanation provided below the question.
- Check formula sheet & personal notes for quick recap.
- Add API key in App Settings to enable live AI responses.
''';
    }
  }
}
