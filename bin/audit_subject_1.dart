import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/study_material/master_study_material.json');
  if (!file.existsSync()) {
    print('File not found!');
    return;
  }
  final List master = jsonDecode(file.readAsStringSync());
  final thermo = master.firstWhere((element) => element['subject'] == 'Thermodynamics', orElse: () => null);
  if (thermo == null) {
    print('Thermodynamics subject not found');
    return;
  }
  final List topics = thermo['topics'];
  print('Total Thermodynamics topics in master_study_material.json: ${topics.length}');
  for (int i = 0; i < topics.length; i++) {
    final t = topics[i];
    print('--- Topic ${i + 1}: ID ${t['id']} | ${t['title'] ?? t['topic']} ---');
    print('Overview length: ${(t['overview'] as String? ?? '').length}');
    print('DetailedTheory length: ${(t['detailedTheory'] as String? ?? '').length}');
    print('Formulas count: ${(t['formulas'] as List? ?? []).length}');
    print('Solved Examples count: ${(t['solvedExamples'] as List? ?? []).length}');
    print('Visual/Videos count: ${(t['visualLearning']?['videos'] as List? ?? []).length}');
  }
}
