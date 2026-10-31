import 'dart:convert';
import 'dart:io';

void main() {
  print('================================================================================');
  print('🚀 REBUILDING CLEAN MASTER STUDY MATERIAL (GLOBAL IDS 1 TO 165)');
  print('================================================================================\n');

  final subjectsFile = File('assets/questions/subjects.json');
  if (!subjectsFile.existsSync()) {
    print('Error: subjects.json not found!');
    exit(1);
  }

  final List subjectsData = jsonDecode(subjectsFile.readAsStringSync());

  final List<Map<String, dynamic>> cleanMasterData = [];

  int globalTopicId = 1;

  for (int sIdx = 0; sIdx < subjectsData.length; sIdx++) {
    final s = subjectsData[sIdx] as Map<String, dynamic>;
    final String subjectName = s['name'] ?? s['subject'] ?? '';
    final List authTopics = s['topics'] as List? ?? s['subTopics'] as List? ?? [];

    print('Subject ${sIdx + 1}: $subjectName (${authTopics.length} topics, Starting Global ID: $globalTopicId)');

    final List<Map<String, dynamic>> topicList = [];

    for (int tIdx = 0; tIdx < authTopics.length; tIdx++) {
      final t = authTopics[tIdx];
      final String topicTitle = t is Map ? (t['title'] ?? t['name'] ?? t['topic']) : t.toString();
      final int topicId = globalTopicId;

      final String conceptUrl = (topicId == 1)
          ? 'https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/thermodynamic_systems.mp4'
          : (topicId == 32
              ? 'https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/ic_engine_combustion_knocking.mp4'
              : (topicId == 42
                  ? 'https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/ic_engine_testing_and_performance.mp4'
                  : (topicId == 43
                      ? 'https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/air_standard_cycles.mp4'
                      : 'https://www.youtube.com/watch?v=video_t_${topicId}_concept')));

      final String assetPath = (topicId == 1)
          ? 'assets/videos/thermodynamic_systems.mp4'
          : (topicId == 32
              ? 'assets/videos/ic_engine_combustion_knocking.mp4'
              : (topicId == 42
                  ? 'assets/videos/ic_engine_testing_and_performance.mp4'
                  : (topicId == 43 ? 'assets/videos/air_standard_cycles.mp4' : '')));

      topicList.add({
        'id': topicId,
        'topic': topicTitle,
        'title': topicTitle,
        'overview': '$topicTitle ની વ્યાખ્યા, મુખ્ય કાર્યકારી સિદ્ધાંત અને ગણિતીય પાયો. (GSSSB AAE, SSC JE, RRB JE & State AE/JE Syllabi Mapped)',
        'concept': '$topicTitle નો મુખ્ય કાર્યકારી સિદ્ધાંત, ચોક્કસ વ્યાખ્યાઓ અને ગાણિતીક સૂત્રો જે પરીક્ષામાં સીધા પૂછાય છે.',
        'definitions': [
          '$topicTitle: $subjectName નો પાયાનો માનક ટેકનિકલ કોન્સેપ્ટ જે સિસ્ટમની વર્તણૂક વ્યાખ્યાયિત કરે છે.',
          'સહાયક પરિમાણ: સિસ્ટમની એફિશિયન્સી અથવા વર્ક આઉટપુટ માપતો અચળાંક/ગુણોત્તર (SI Unit: Pa, N/m², J/kg, m³/s).'
        ],
        'detailedTheory': '''
૧. સૈદ્ધાંતિક પૃથ્થકરણ (Detailed Engineering Theory):
$topicTitle એ $subjectName નો અત્યંત મહત્વપૂર્ણ સૈદ્ધાંતિક અને ગણિતીય વિષયાંક છે. GSSSB AAE, SSC JE અને RRB JE પરીક્ષાઓ માટે તેની ઊંડાણપૂર્વક સમઝ નીચે મુજબ છે:
- મુખ્ય કાર્યકારી કાયદો અને તેની ધારણાઓ (Assumptions & Operating Principles).
- સિસ્ટમમાં થતા ભૌતિક અને પ્રક્રિયાગત ફેરફારો.

૨. વર્ગીકરણ અને વ્યવહારિક ઉપયોગો (Classifications & Applications):
- વિવિધ પ્રકારો, મટીરીયલ્સ અને ગણિતીય સંબંધો.
- ઔદ્યોગિક પાવર પ્લાન્ટ્સ, મેન્યુફેક્ચરિંગ અને મશીનરીમાં વ્યવહારિક ઉપયોગ.
'''.trim(),
        'keyPoints': [
          '$topicTitle -> પાયાનો કાયદો અને સમીકરણ.',
          'SI Units -> N/m², Pa, Joules, Watts, m³/s.',
          'Important Condition -> Valid under elastic / steady state limit.'
        ],
        'formulas': [
          'સ્માર્ટ ફોર્મ્યુલા: Formula = \\frac{\\text{Input / Numerator}}{\\text{Output / Denominator}}',
          'SI એકમો: N/m², Pa, bar, kW, kJ/kg, m³/s.'
        ],
        'solvedExamples': [
          'દાખલા ઉકેલ ($topicTitle):\nઆપેલ વિગતો (Given Data): A = 100 units, B = 20 units.\nઉકેલ: Result = A / B = 100 / 20 = 5.0 SI Units.'
        ],
        'importantPoints': [
          '$topicTitle નો ઉપયોગ એન્જિનિયરિંગ ક્ષેત્રે વ્યાપકપણે થાય છે.'
        ],
        'examPoints': [
          '🎯 GSSSB AAE Golden Point: $topicTitle ની મૂળભૂત વ્યાખ્યા અને સીધું સૂત્ર.',
          '🎯 SSC JE / RRB JE Exam Point: તાપમાન, દબાણ અથવા સ્પીડ સાથે બદલાતો મુખ્ય સંબંધ અને એકમ કન્વર્ઝન.'
        ],
        'commonMistakes': [
          '⚠️ GSSSB / SSC JE Exam Trap: $topicTitle માં SI એકમો (N/m², Pa, bar, kW) અને ગેજ વિરુદ્ધ એબ્સોલ્યુટ દબાણ વચ્ચે ભૂલ ન કરવી.'
        ],
        'quickRevision': [
          '$topicTitle -> પાયાનો કાયદો અને સમીકરણ.'
        ],
        'mcqs': [],
        'msqs': [],
        'visualLearning': {
          'enabled': true,
          'visualRequired': true,
          'type': 'diagram',
          'animationKey': 'anim_topic_$topicId',
          'title': topicTitle,
          'purpose': 'Visualizing $topicTitle working principle and diagram',
          'mobileLayout': 'vertical_card',
          'sequence': ['૧. $topicTitle નો મુખ્ય વર્કિંગ ડાયાગ્રામ જુઓ.'],
          'diagrams': ['$topicTitle Diagram'],
          'rule': 'Full animated Gujarati story with GSSSB exam traps.',
          'videoUrl': conceptUrl,
          'videos': [
            {
              'title': '$topicTitle - Full Concept Explanation',
              'url': conceptUrl,
              'assetPath': assetPath,
              'description': 'Full animated Gujarati video lesson for $topicTitle.',
              'recallQuestions': [
                {
                  'question': 'What is the main principle of $topicTitle?',
                  'options': ['Option A', 'Option B', 'Option C', 'Option D'],
                  'correctAnswer': 0,
                  'explanation': 'Key explanation for $topicTitle.'
                }
              ]
            },
            {
              'title': '$topicTitle - Numerical & Practical Problem Solving',
              'url': 'https://www.youtube.com/watch?v=video_t_${topicId}_num',
              'assetPath': '',
              'description': 'Step-by-step numerical solving for $topicTitle.'
            }
          ],
          'imageUrl': 'assets/images/diagrams/subj_${sIdx + 1}_topic_${tIdx + 1}.png'
        }
      });

      globalTopicId++;
    }

    cleanMasterData.add({
      'subject': subjectName,
      'topics': topicList,
    });
  }

  final masterFile = File('assets/study_material/master_study_material.json');
  masterFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(cleanMasterData),
    encoding: utf8,
  );

  print('\n================================================================================');
  print('✅ SUCCESSFULLY REBUILT CLEAN MASTER STUDY MATERIAL (GLOBAL IDS 1 TO 165)');
  print('================================================================================');
}
