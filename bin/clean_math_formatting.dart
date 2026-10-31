import 'dart:convert';
import 'dart:io';

void main() {
  print('================================================================================');
  print('🧹 FINAL CLEANING OF ALL LATEX MARKUP IN MASTER STUDY MATERIAL');
  print('================================================================================\n');

  final masterFile = File('assets/study_material/master_study_material.json');
  if (!masterFile.existsSync()) {
    print('Error: master_study_material.json not found!');
    exit(1);
  }

  final List<dynamic> masterData = jsonDecode(masterFile.readAsStringSync());

  int cleanedTopics = 0;
  int totalReplacements = 0;

  for (int sIdx = 0; sIdx < masterData.length; sIdx++) {
    final s = masterData[sIdx] as Map<String, dynamic>;
    final List topics = s['topics'] as List? ?? [];

    for (int tIdx = 0; tIdx < topics.length; tIdx++) {
      final t = topics[tIdx] as Map<String, dynamic>;

      bool topicModified = false;

      void cleanField(String key) {
        if (t[key] is String) {
          final String original = t[key];
          final String cleaned = convertLatexToUnicode(original);
          if (original != cleaned) {
            t[key] = cleaned;
            topicModified = true;
            totalReplacements++;
          }
        } else if (t[key] is List) {
          final List list = t[key];
          for (int i = 0; i < list.length; i++) {
            if (list[i] is String) {
              final String original = list[i];
              final String cleaned = convertLatexToUnicode(original);
              if (original != cleaned) {
                list[i] = cleaned;
                topicModified = true;
                totalReplacements++;
              }
            }
          }
        }
      }

      cleanField('overview');
      cleanField('concept');
      cleanField('detailedTheory');
      cleanField('definitions');
      cleanField('keyPoints');
      cleanField('formulas');
      cleanField('solvedExamples');
      cleanField('importantPoints');
      cleanField('examPoints');
      cleanField('commonMistakes');
      cleanField('quickRevision');

      if (topicModified) {
        cleanedTopics++;
      }
    }
  }

  // Save back to master_study_material.json
  masterFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(masterData),
    encoding: utf8,
  );

  print('================================================================================');
  print('✅ FINAL SANITIZATION COMPLETE!');
  print('   Topics Updated: $cleanedTopics');
  print('   Fields Cleaned: $totalReplacements');
  print('================================================================================\n');
}

String convertLatexToUnicode(String text) {
  String result = text;

  // Replace backslashed spaces
  result = result.replaceAll(r'\ ', ' ');

  // Replace un-prefixed frac{A}{B}
  result = result.replaceAllMapped(RegExp(r'frac\{([^{}]+)\}\{([^{}]+)\}'), (match) {
    String num = match.group(1)!.trim().replaceAll(r'\ ', ' ');
    String den = match.group(2)!.trim().replaceAll(r'\ ', ' ');
    return '($num / $den)';
  });

  if (!result.contains('\\') && !result.contains('\$')) return result;

  // 0. Remove inline dollar delimiters $ ... $
  result = result.replaceAllMapped(RegExp(r'\$([^$]+)\$'), (m) => m.group(1)!);

  // 1. Remove display brackets \[ and \]
  result = result.replaceAll(RegExp(r'\\\[\s*'), '');
  result = result.replaceAll(RegExp(r'\s*\\\]'), '');

  // 2. Iteratively process \frac{num}{den} -> (num / den)
  while (result.contains(r'\frac')) {
    final prev = result;
    result = result.replaceAllMapped(RegExp(r'\\frac\{([^{}]+)\}\{([^{}]+)\}'), (match) {
      String num = match.group(1)!.trim();
      String den = match.group(2)!.trim();
      num = num.replaceAll(RegExp(r'\\text\{([^}]+)\}'), r'$1');
      den = den.replaceAll(RegExp(r'\\text\{([^}]+)\}'), r'$1');
      return '($num / $den)';
    });
    if (result == prev) break;
  }

  // 3. Remove remaining \text{...}, \mathrm{...}, \mathbf{...}
  result = result.replaceAllMapped(RegExp(r'\\(text|mathrm|mathbf)\{([^}]+)\}'), (match) {
    return match.group(2)!;
  });

  // 4. Square roots \sqrt{X} -> √(X)
  result = result.replaceAllMapped(RegExp(r'\\sqrt\{([^}]+)\}'), (match) {
    return '√(${match.group(1)!})';
  });

  // 5. Greek, math operators and symbols
  result = result
      .replaceAll(r'\dot{m}', 'ṁ')
      .replaceAll(r'\dot{V}', 'V̇')
      .replaceAll(r'\rho', 'ρ')
      .replaceAll(r'\times', '×')
      .replaceAll(r'\eta', 'η')
      .replaceAll(r'\Delta', 'Δ')
      .replaceAll(r'\theta', 'θ')
      .replaceAll(r'\tau', 'τ')
      .replaceAll(r'\nu', 'ν')
      .replaceAll(r'\beta', 'β')
      .replaceAll(r'\epsilon', 'ε')
      .replaceAll(r'\mu', 'μ')
      .replaceAll(r'\sigma', 'σ')
      .replaceAll(r'\pi', 'π')
      .replaceAll(r'\gamma', 'γ')
      .replaceAll(r'\delta', 'δ')
      .replaceAll(r'\partial', '∂')
      .replaceAll(r'\sum', 'Σ')
      .replaceAll(r'\int', '∫')
      .replaceAll(r'\oint', '∮')
      .replaceAll(r'\approx', '≈')
      .replaceAll(r'\ne', '≠')
      .replaceAll(r'\neq', '≠')
      .replaceAll(r'\le', '≤')
      .replaceAll(r'\ge', '≥')
      .replaceAll(r'≤ft', '')
      .replaceAll(r'\left', '')
      .replaceAll(r'\right', '')
      .replaceAll(r'\mp', '∓')
      .replaceAll(r'\pm', '±')
      .replaceAll(r'\implies', '⇒')
      .replaceAll(r'\propto', '∝')
      .replaceAll(r'\Theta', 'Θ')
      .replaceAll(r'\sin', 'sin')
      .replaceAll(r'\cos', 'cos')
      .replaceAll(r'\tan', 'tan')
      .replaceAll(r'\ln', 'ln')
      .replaceAll(r'\quad', ' ')
      .replaceAll(r'\circ', '°')
      .replaceAll(r'^\circ', '°')
      .replaceAll(r'\cdot', '·')
      .replaceAll(r'\lambda', 'λ')
      .replaceAll(r'\infty', '∞')
      .replaceAll(r'\%', '%');

  // Remove any leftover standalone backslashes before plain letters
  result = result.replaceAllMapped(RegExp(r'\\([a-zA-Z]+)'), (m) => m.group(1)!);

  // Clean up any double spaces or orphan braces
  result = result.replaceAll(RegExp(r' +'), ' ');

  return result;
}
