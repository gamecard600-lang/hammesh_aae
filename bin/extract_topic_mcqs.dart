import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/questions/thermodynamics.json');
  if (!file.existsSync()) {
    print('Error: thermodynamics.json not found!');
    exit(1);
  }

  final List<dynamic> data = jsonDecode(file.readAsStringSync());
  final mcqs = data.where((q) => q['subTopic'] == 'Thermodynamic Systems & Control Volume').toList();

  print('=== MCQS MAPPED TO "Thermodynamic Systems & Control Volume" ===');
  print('Total MCQs: ${mcqs.length}\n');

  for (int i = 0; i < mcqs.length; i++) {
    final q = mcqs[i];
    final id = q['id'];
    final gq = q['gujaratiQuestion'] ?? q['question'];
    final options = q['options'] as List? ?? [];
    final correctIdx = q['correctAnswer'] ?? 0;
    final exp = q['explanation'] ?? '';

    print('MCQ #${i + 1} (ID $id):');
    print('  Q: $gq');
    print('  Options:');
    for (int optIdx = 0; optIdx < options.length; optIdx++) {
      final mark = optIdx == correctIdx ? '✅' : '  ';
      print('    $mark [${String.fromCharCode(65 + optIdx)}] ${options[optIdx]}');
    }
    print('  Explanation: $exp\n');
  }
}
