import 'dart:convert';
import 'dart:io';

void main() {
  print('================================================================================');
  print('🔧 REPAIRING TOPIC 1: THERMODYNAMIC SYSTEMS & CONTROL VOLUME FROM PDF PAGE 3-4');
  print('================================================================================\n');

  final masterFile = File('assets/study_material/master_study_material.json');
  if (!masterFile.existsSync()) {
    print('master_study_material.json missing!');
    exit(1);
  }

  final List<dynamic> masterData = jsonDecode(masterFile.readAsStringSync());

  // Find Subject 1 (Thermodynamics)
  final int s1Index = masterData.indexWhere(
    (s) => (s['subject'] as String? ?? '').trim().toLowerCase().contains('thermodynamics'),
  );

  if (s1Index == -1) {
    print('Subject 1 not found!');
    exit(1);
  }

  final List topics = masterData[s1Index]['topics'] as List? ?? [];
  final int t1Index = topics.indexWhere((t) => t['id'] == 1);

  if (t1Index == -1) {
    print('Topic ID 1 not found!');
    exit(1);
  }

  // Exact, source-based PDF content for Topic 1: Thermodynamic Systems & Control Volume
  final Map<String, dynamic> topic1Repaired = {
    "id": 1,
    "topic": "Thermodynamic Systems & Control Volume",
    "title": "Thermodynamic Systems & Control Volume",
    "overview": "અવકાશમાં પસંદ કરેલ નિશ્ચિત દળ (matter) અથવા ચોક્કસ વિસ્તાર (region in space) જેના પર થર્મોડાયનેમિક વિશ્લેષણ કેન્દ્રિત કરવામાં આવે છે તેને થર્મોડાયનેમિક સિસ્ટમ કહે છે.",
    "concept": "તંત્ર (System), પર્યાવરણ (Surroundings), સીમા (Boundary) અને વિશ્વ (Universe = System + Surroundings) નો મૂળભૂત ભૌતિક સંગમ. સીમા ઓળંગીને થતા દળ (Mass) અને ઊર્જા (Energy - Heat Q & Work W) ના આદાન-પ્રદાનના આધારે તંત્રોનું વર્ગીકરણ કરાય છે.",
    "definitions": [
      "Thermodynamic System: અવકાશમાં પસંદ કરેલ નિશ્ચિત દળ (matter) અથવા ચોક્કસ વિસ્તાર (region in space) જેના પર થર્મોડાયનેમિક વિશ્લેષણ કેન્દ્રિત કરાય છે.",
      "Surroundings: સિસ્ટમ સિવાયના બાહ્ય સમગ્ર વિસ્તારને Surroundings (પર્યાવરણ) કહેવાય છે.",
      "Boundary: સિસ્ટમ અને પર્યાવરણને અલગ પાડતી વાસ્તવિક કે કાલ્પનિક સીમાને Boundary કહે છે.",
      "Universe: સિસ્ટમ અને પર્યાવરણના સમન્વયથી બનતું સમગ્ર વિશ્વ (Universe = System + Surroundings).",
      "Control Volume (C.V.): ખુલ્લી સિસ્ટમના અભ્યાસ માટે અવકાશમાં કલ્પના કરવામાં આવેલા નિશ્ચિત કદને Control Volume કહે છે.",
      "Control Surface (C.S.): કંટ્રોલ વોલ્યુમની બાહ્ય સીમાને Control Surface કહે છે."
    ],
    "detailedTheory": '''
૧. થર્મોડાયનેમિક તંત્રોનું વર્ગીકરણ (Classification of Thermodynamic Systems):

(૧) Closed System (Control Mass / બંધ તંત્ર):
- દળ વહન (Mass Transfer): ના (દળ સીમા ઓળંગતું નથી, m = constant).
- ઊર્જા વહન (Energy Transfer): હા (ઉષ્મા Q અને કાર્ય W નું આદાન-પ્રદાન શક્ય છે).
- લાક્ષણિકતાઓ & ઉદાહરણો: સિસ્ટમનું દળ નિશ્ચિત રહે છે. સીમા ઓળંગીને ઉષ્મા અને કાર્યનું આદાન-પ્રદાન થઈ શકે છે.
- વ્યવહારિક ઉદાહરણો: વાલ્વ વગરનું પિસ્ટન-સિલિન્ડર, બોમ્બ કેલોરીમીટર, પ્રેશર કૂકર (સીટી વાગ્યા પહેલાં).

(૨) Open System (Control Volume / ખુલ્લું તંત્ર):
- દળ વહન (Mass Transfer): હા (દળ કંટ્રોલ સરફેસ ઓળંગે છે, m_in, m_out ≠ 0).
- ઊર્જા વહન (Energy Transfer): હા (ઉષ્મા Q અને કાર્ય W નું આદાન-પ્રદાન શક્ય છે).
- લાક્ષણિકતાઓ & ઉદાહરણો: દળ અને ઊર્જા બંને સીમા ઓળંગીને વહી શકે છે.
- Steady Flow ની શરત: સ્થિર પ્રવાહ (Steady Flow) ની સ્થિતિમાં કંટ્રોલ વોલ્યુમ અંદર સંગ્રહિત દળ અચળ રહે છે (dm_cv / dt = 0), છતાં તે Open System જ કહેવાય છે કારણ કે દળ સીમા ઓળંગે છે.
- વ્યવહારિક ઉદાહરણો: સ્ટીમ ટર્બાઇન, કમ્પ્રેસર, સેન્ટ્રીફ્યુગલ પંપ, બોઇલર, નોઝલ, હીટ એક્સચેન્જર.

(૩) Isolated System (અલગ કરેલું તંત્ર):
- દળ વહન (Mass Transfer): ના (દળ સીમા ઓળંગતું નથી).
- ઊર્જા વહન (Energy Transfer): ના (કોઈ ઉષ્મા Q કે કાર્ય W નું આદાન-પ્રદાન થતું નથી, E = constant).
- વ્યવહારિક ઉદાહરણો: સમગ્ર વિશ્વ (Universe), સંપૂર્ણ ઇન્સ્યુલેટેડ અને બંધ થર્મોસ ફ્લાસ્ક.

૨. સીમાના પ્રકારો (Types of Boundaries):
- Fixed vs. Movable: કન્ટેનરની નક્કર દીવાલ Fixed છે, જ્યારે પિસ્ટન Movable boundary દર્શાવે છે.
- Real vs. Imaginary: પાઇપની નક્કર સપાટી Real વાસ્તવિક છે, જ્યારે પાઇપના ઇનલેટ/આઉટલેટ પર કલ્પના કરેલી સપાટી Imaginary કાલ્પનિક છે.
- Diathermic vs. Adiabatic: ડાયાથર્મિક સપાટી ઉષ્માનું વહન થવા દે છે (Q ≠ 0); એડિયાબેટિક સપાટી સંપૂર્ણ અવાહક છે (Q = 0).
'''.trim(),
    "keyPoints": [
      "Universe = System + Surroundings.",
      "Closed System -> Control Mass (Mass = Const, Energy Transfer = Yes).",
      "Open System -> Control Volume (Mass Transfer = Yes, Energy Transfer = Yes).",
      "Isolated System -> Mass = Const, Energy = Const (Q = 0, W = 0).",
      "Steady Flow in C.V. -> dm_cv / dt = 0 (Mass inside CV remains constant).",
      "Diathermic Boundary -> Q ≠ 0 | Adiabatic Boundary -> Q = 0."
    ],
    "formulas": [
      "Universe Relation: Universe = System + Surroundings",
      "Mass Conservation for Closed System: m_{system} = constant",
      "Mass Flow Rate in Open System: \\dot{m} = \\rho * A * V \\text{ (kg/s)}",
      "Steady Flow Control Volume Mass Balance: \\frac{dm_{cv}}{dt} = \\dot{m}_{in} - \\dot{m}_{out} = 0"
    ],
    "solvedExamples": [
      "દાખલા ઉકેલ (Mass Flow Rate in Open System Control Volume):\nઆપેલ વિગતો (Given Data):\n- ફ્લુઇડ ડેન્સિટી ρ = 1000 kg/m³ (પાણી)\n- પાઇપનો ક્રોસ સેક્શનલ એરિયા A = 0.01 m²\n- પ્રવાહનો વેગ V = 2 m/s\nશોધવાનું મૂલ્ય: માસ ફ્લો રેટ (ṁ)\nઉકેલ:\nformula: ṁ = ρ * A * V\nṁ = 1000 * 0.01 * 2 = 20 kg/s.\nઅંતિમ જવાબ: માસ ફ્લો રેટ ṁ = 20 kg/s."
    ],
    "importantPoints": [
      "વાલ્વ વગરનું પિસ્ટન-સિલિન્ડર ક્લોઝ્ડ સિસ્ટમ છે, પરંતુ જો વાલ્વ ખૂલે અને ગેસ અંદર પ્રવેશે કે બહાર નીકળે તો તે ઓપન સિસ્ટમ બને છે.",
      "આપણું સમગ્ર વિશ્વ (Universe) એ કાયદેસરની આઇસોલેટેડ સિસ્ટમ છે, જેની બહાર કોઈ પર્યાવરણ અસ્તિત્વ ધરાવતું નથી."
    ],
    "examPoints": [
      "GSSSB Golden Question: A region in space identified for thermodynamic analysis is called -> Control Volume.",
      "GSSSB Golden Question: Centrifugal pump and Steam Turbine are examples of -> Open System (Control Volume).",
      "GSSSB Golden Question: Pressure cooker before whistling is an example of -> Closed System.",
      "GSSSB Golden Question: The entire Universe is considered as an -> Isolated System."
    ],
    "commonMistakes": [
      "⚠️ GSSSB Exam Trap: પિસ્ટન-સિલિન્ડર વિથ વાલ્વ ને ક્લોઝ્ડ સિસ્ટમ માનવું (વાલ્વ ખોલતાં ગેસ બહાર આવે તેથી તે ઓપન સિસ્ટમ બને છે!).",
      "⚠️ GSSSB Exam Trap: કંટ્રોલ વોલ્યુમમાં અંદર જમા દળ અચળ રહે (dm_cv/dt = 0) તો તેને ક્લોઝ્ડ ગણવું (દળ સીમા ઓળંગતું હોવાથી તે ઓપન સિસ્ટમ જ કહેવાય!)."
    ],
    "quickRevision": [
      "Closed = Mass Const, Energy Transfer.",
      "Open = Mass & Energy Transfer.",
      "Isolated = Neither Mass nor Energy Transfer.",
      "ṁ = ρ A V (kg/s)."
    ],
    "mcqs": [],
    "msqs": [],
    "visualLearning": {
      "enabled": true,
      "visualRequired": true,
      "type": "diagram",
      "animationKey": "thermo_sys_anim",
      "title": "Thermodynamic Systems & Control Volume",
      "purpose": "Visualizing Closed System Control Mass vs Open System Control Volume Boundary Interactions",
      "mobileLayout": "vertical_card",
      "sequence": [
        "૧. Closed System માં Mass Const પણ Energy Q અને W આદાન-પ્રદાન જુઓ.",
        "૨. Open System (Control Volume) માં Mass in/out અને Control Surface જુઓ.",
        "૩. ṁ = 20 kg/s ની ગણતરી ચકાસો."
      ],
      "diagrams": ["Closed, Open and Isolated Systems Diagram"],
      "rule": "Full animated Gujarati narrative story with GSSSB exam traps.",
      "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/thermodynamic_systems.mp4",
      "videos": [
        {
          "title": "Thermodynamic Systems & Control Volume - Full Concept Explanation",
          "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/thermodynamic_systems.mp4",
          "assetPath": "assets/videos/thermodynamic_systems.mp4",
          "description": "Full animated Gujarati video lesson covering System, Surroundings, Boundary, Closed/Open/Isolated systems, Control Volume, and ṁ = ρAV.",
          "recallQuestions": [
            {
              "question": "Which of the following is an example of an Open System?",
              "options": ["Bomb Calorimeter", "Steam Turbine", "Thermos Flask", "Piston Cylinder without Valves"],
              "correctAnswer": 1,
              "explanation": "Steam Turbine is an open system because both mass (steam) and energy (heat/work) cross the control surface."
            }
          ]
        },
        {
          "title": "Thermodynamic Systems & Control Volume - Numerical Problem Solving",
          "url": "https://www.youtube.com/watch?v=video_t_1_num",
          "assetPath": "",
          "description": "Step-by-step numerical solving for mass flow rate ṁ = ρAV in control volume analysis."
        }
      ],
      "imageUrl": "assets/images/diagrams/subj_1_topic_1.png"
    }
  };

  // Replace Topic 1 in masterData
  masterData[s1Index]['topics'][t1Index] = topic1Repaired;

  // Save back to master_study_material.json
  masterFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(masterData),
    encoding: utf8,
  );

  print('✅ Successfully updated Topic 1 (Thermodynamic Systems & Control Volume) with pure PDF content!');
}
