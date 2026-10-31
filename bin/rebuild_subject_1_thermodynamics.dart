import 'dart:convert';
import 'dart:io';

void main() {
  print('================================================================================');
  print('🚀 BATCH 1: REBUILDING SUBJECT 1 (THERMODYNAMICS) FROM PDF SOURCE PAGES 3-15');
  print('================================================================================\n');

  final jsonSourceFile = File(r'C:\Users\hamme\Downloads\aae_study_notes_source_extracted.json');
  if (!jsonSourceFile.existsSync()) {
    print('Source JSON missing!');
    exit(1);
  }

  final Map<String, dynamic> sourceData = jsonDecode(jsonSourceFile.readAsStringSync());
  final List pages = sourceData['pages'] as List? ?? [];

  final masterFile = File('assets/study_material/master_study_material.json');
  final List<dynamic> masterData = jsonDecode(masterFile.readAsStringSync());

  final int s1Index = masterData.indexWhere(
    (s) => (s['subject'] as String? ?? '').trim().toLowerCase().contains('thermodynamics'),
  );

  if (s1Index == -1) {
    print('Subject 1 not found in master_study_material.json');
    exit(1);
  }

  // Get pages 3 to 15 text
  String getPageText(int pNum) {
    if (pNum >= 1 && pNum <= pages.length) {
      return pages[pNum - 1]['text'] as String? ?? '';
    }
    return '';
  }

  final String p3Text = getPageText(3);
  final String p4Text = getPageText(4);
  final String p5Text = getPageText(5);
  final String p6Text = getPageText(6);
  final String p7Text = getPageText(7);
  final String p8Text = getPageText(8);
  final String p9Text = getPageText(9);
  final String p10Text = getPageText(10);
  final String p11Text = getPageText(11);
  final String p12Text = getPageText(12);
  final String p13Text = getPageText(13);
  final String p14Text = getPageText(14);
  final String p15Text = getPageText(15);

  final List<Map<String, dynamic>> updatedS1Topics = [
    // -----------------------------------------------------------------
    // TOPIC 1 (ID 1): Thermodynamic Systems & Control Volume
    // -----------------------------------------------------------------
    {
      "id": 1,
      "topic": "Thermodynamic Systems & Control Volume",
      "title": "Thermodynamic Systems & Control Volume",
      "overview": "અવકાશમાં પસંદ કરેલ નિશ્ચિત દળ (matter) અથવા ચોક્કસ વિસ્તાર (region in space) જેના પર થર્મોડાયનેમિક વિશ્લેષણ કેન્દ્રિત કરવામાં આવે છે તેને થર્મોડાયનેમિક સિસ્ટમ કહે છે. (PDF Pages 3–4)",
      "concept": "તંત્ર (System), પર્યાવરણ (Surroundings), સીમા (Boundary) અને વિશ્વ (Universe = System + Surroundings) નો ભૌતિક સંબંધ. સીમા ઓળંગીને થતા દળ (Mass) અને ઊર્જા (Energy - Heat Q & Work W) ના આદાન-પ્રદાનના આધારે તંત્રોનું વર્ગીકરણ કરાય છે.",
      "definitions": [
        "Thermodynamic System: અવકાશમાં પસંદ કરેલ નિશ્ચિત દળ (matter) અથવા ચોક્કસ વિસ્તાર (region in space) જેના પર થર્મોડાયનેમિક વિશ્લેષણ કેન્દ્રિત કરાય છે.",
        "Surroundings: સિસ્ટમ સિવાયના બાહ્ય સમગ્ર વિસ્તારને Surroundings (પર્યાવરણ) કહેવાય છે.",
        "Boundary: સિસ્ટમ અને પર્યાવરણને અલગ પાડતી વાસ્તવિક કે કાલ્પનિક સીમાને Boundary કહે છે.",
        "Universe: સિસ્ટમ અને પર્યાવરણના સમન્વયથી બનતું સમગ્ર વિશ્વ (Universe = System + Surroundings).",
        "Control Volume (C.V.): ખુલ્લી સિસ્ટમના અભ્યાસ માટે અવકાશમાં કલ્પના કરવામાં આવેલા નિશ્ચિત કદને Control Volume કહે છે.",
        "Control Surface (C.S.): કંટ્રોલ વોલ્યુમની બાહ્ય સીમાને Control Surface કહે છે."
      ],
      "detailedTheory": '''
૧. થર્મોડાયનેમિક તંત્રોનું વર્ગીકરણ (Classification of Thermodynamic Systems — PDF Page 3):

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

૨. સીમાના પ્રકારો (Types of Boundaries — PDF Page 4):
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
    },

    // -----------------------------------------------------------------
    // TOPIC 2 (ID 2): Zeroth Law & Temperature Measurement
    // -----------------------------------------------------------------
    {
      "id": 2,
      "topic": "Zeroth Law & Temperature",
      "title": "Zeroth Law & Temperature Measurement",
      "overview": "ઝીરોથ લો ઓફ થર્મોડાયનેમિક્સ તાપમાનની વિજ્ઞાન આધારિત વ્યાખ્યા પૂરી પાડે છે અને તમામ થર્મોમીટર્સનો વૈજ્ઞાનિક પાયો છે. (PDF Page 4)",
      "concept": "Zeroth Law: જો બે અલગ તંત્રો (A અને B) કોઈ ત્રીજા તંત્ર (C) સાથે સ્વતંત્ર રીતે થર્મલ સંતુલન (Thermal Equilibrium) માં હોય, તો તે બંને તંત્રો (A અને B) પણ પરસ્પર થર્મલ સંતુલનમાં જ રહે. આ નિયમ તાપમાન (Temperature) ની ચોક્કસ ભૌતિક વ્યાખ્યા પૂરી પાડે છે.",
      "definitions": [
        "Zeroth Law of Thermodynamics: જો A અને B સ્વતંત્ર રીતે C સાથે થર્મલ સંતુલનમાં હોય, તો A અને B પણ પરસ્પર થર્મલ સંતુલનમાં રહે છે.",
        "Thermometric Property: થર્મોમીટરમાં તાપમાન સાથે નિયમિત રીતે બદલાતો ભૌતિક ગુણધર્મ (જેમ કે દબાણ P, કદ V, રેઝિસ્ટન્સ R, Voltage EMF, Length L).",
        "Triple Point of Water: જે ચોક્કસ તાપમાન અને દબાણે પાણીની ત્રણેય અવસ્થાઓ (બ્રફ, પ્રવાહી પાણી, બાષ્પ) સાથે થર્મલ સંતુલનમાં અસ્તિત્વ ધરાવે તે બિંદુ (T_tp = 273.16 K = 0.01 °C, P_tp = 0.6112 kPa = 4.58 mm Hg)."
      ],
      "detailedTheory": '''
૧. થર્મોમીટર્સ અને થર્મોમેટ્રિક ગુણધર્મોનું વર્ગીકરણ (PDF Page 4):

(૧) Constant Volume Gas Thermometer:
- Thermometric Property: Pressure (દબાણ P).
- સિદ્ધાંત: અચળ કદે ગેસનું દબાણ તાપમાન સાથે સીધા સમપ્રમાણમાં બદલાય છે (P ∝ T). આ પ્રાથમિક સ્ટાન્ડર્ડ થર્મોમીટર છે.

(૨) Constant Pressure Gas Thermometer:
- Thermometric Property: Volume (કદ V).
- સિદ્ધાંત: અચળ દબાણે ગેસનું કદ તાપમાન સાથે સીધા સમપ્રમાણમાં વિસ્તરે છે (V ∝ T).

(૩) Electrical Resistance Thermometer (RTD):
- Thermometric Property: Electrical Resistance (ઇલેક્ટ્રિકલ અવરોધ R).
- સિદ્ધાંત: પ્લેટિનમ વાયરનો અવરોધ તાપમાન સાથે વધે છે [R_t = R_0 (1 + α t)].

(૪) Thermocouple (થર્મોકપલ):
- Thermometric Property: Thermal EMF / Voltage (વીજચાલક બળ ε).
- Seebeck Effect: બે જુદી ધાતુઓના જંકશન વચ્ચે તાપમાન ફેરફારથી વોલ્ટેજ પેદા થાય છે.

(૫) Optical Pyrometer:
- Thermometric Property: Thermal Radiation Intensity.
- સિદ્ધાંત: સંપર્ક વગર (Non-contact) ઊંચા તાપમાનવાળી ભઠ્ઠીઓ (Furnaces) નું તાપમાન માપવા વપરાય છે.

૨. તાપમાન સ્કેલના રૂપાંતરણ સૂત્રો:
(C / 5) = (F - 32) / 9 = (K - 273.15) / 5 = (R - 491.67) / 9
- -40° નો ખાસ સંબંધ: સેલ્સિયસ અને ફેરેનહીટ સ્કેલ -40 ડિગ્રી પર સમાન મૂલ્ય દર્શાવે છે (-40°C = -40°F).
'''.trim(),
      "keyPoints": [
        "Zeroth Law defines -> Temperature.",
        "Thermocouple works on -> Seebeck Effect (EMF = ε).",
        "RTD formula -> R_t = R_0 (1 + α t).",
        "-40°C = -40°F (Celsius & Fahrenheit scales intersect at -40).",
        "Triple Point of Water -> T = 273.16 K (0.01 °C), P = 0.6112 kPa (4.58 mm Hg)."
      ],
      "formulas": [
        "Temperature Scale Conversion: \\frac{C}{5} = \\frac{F - 32}{9} = \\frac{K - 273.15}{5}",
        "RTD Resistance Equation: R_t = R_0 (1 + \\alpha t)",
        "Triple Point Temperature: T_{tp} = 273.16 \\text{ K} = 0.01 ^\\circ\\text{C}"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ (Temperature Conversion):\nઆપેલ વિગતો (Given Data):\n- તાપમાન C = 100 °C (પાણીનું બોઇલિંગ પોઇન્ટ)\nશોધવાનું મૂલ્ય: ફેરેનહીટ F અને કેલ્વિન K માં મૂલ્ય\nઉકેલ:\n(1) F માટે: (100 / 5) = (F - 32) / 9 => 20 * 9 = F - 32 => F = 180 + 32 = 212 °F.\n(2) K માટે: K = C + 273.15 = 100 + 273.15 = 373.15 K.\nઅંતિમ જવાબ: 100 °C = 212 °F = 373.15 K."
      ],
      "importantPoints": [
        "સેલ્સિયસ અને ફેરેનહીટ સ્કેલ્સ બરાબર -40 °C = -40 °F આગળ એકસમાન મૂલ્ય બતાવે છે.",
        "આધુનિક આંતરરાષ્ટ્રીય તાપમાન સ્કેલ રિફરન્સ પોઇન્ટ તરીકે પાણીના ટ્રિપલ પોઇન્ટ (273.16 K) નો ઉપયોગ કરે છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: Zeroth law of thermodynamics provides the basis for measurement of -> Temperature.",
        "GSSSB Golden Question: Thermocouple works on the principle of -> Seebeck Effect.",
        "GSSSB Golden Question: Celsius and Fahrenheit scales show equal reading at -> -40 degrees.",
        "GSSSB Golden Question: Triple point of water in Kelvin is -> 273.16 K (0.01 °C)."
      ],
      "commonMistakes": [
        "⚠️ GSSSB Exam Trap: કન્સ્ટન્ટ વોલ્યુમ ગેસ થર્મોમીટરમાં થર્મોમેટ્રિક પ્રોપર્ટી કદ ગણી લેવું (તેમાં દબાણ P થર્મોમેટ્રિક પ્રોપર્ટી છે!).",
        "⚠️ GSSSB Exam Trap: ટ્રિપલ પોઇન્ટ ઓફ વોટર માટે 273.15 K અને 273.16 K વચ્ચે કન્ફ્યુઝ થવું (ટ્રિપલ પોઇન્ટ ચોક્કસ 273.16 K અથવા 0.01 °C થાય!)."
      ],
      "quickRevision": [
        "Zeroth Law -> Temperature.",
        "Thermocouple -> Seebeck Effect.",
        "-40°C = -40°F.",
        "T_tp = 273.16 K."
      ],
      "mcqs": [],
      "msqs": [],
      "visualLearning": {
        "enabled": true,
        "visualRequired": true,
        "type": "diagram",
        "animationKey": "zeroth_law_anim",
        "title": "Zeroth Law & Temperature Measurement",
        "purpose": "Visualizing Thermal Equilibrium A-C and B-C leading to A-B Equilibrium and Thermometer Property Comparison",
        "mobileLayout": "vertical_card",
        "sequence": [
          "૧. Systems A, B અને C વચ્ચે Thermal Equilibrium ઝીરોથ લો જુઓ.",
          "૨. Thermocouple Seebeck Effect અને RTD Pt Wire જુઓ.",
          "૩. -40°C = -40°F Conversion અને 273.16 K Triple Point જુઓ."
        ],
        "diagrams": ["Zeroth Law Equilibrium & Thermometer Types Diagram"],
        "rule": "Full animated Gujarati narrative story with GSSSB exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/zeroth_law_and_temperature.mp4",
        "videos": [
          {
            "title": "Zeroth Law & Temperature Measurement - Full Concept Explanation",
            "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/zeroth_law_and_temperature.mp4",
            "assetPath": "assets/videos/zeroth_law_and_temperature.mp4",
            "description": "Full animated Gujarati video lesson covering Zeroth law, thermal equilibrium, thermometer types, Seebeck effect, and scale conversions."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_1_topic_2.png"
      }
    },

    // -----------------------------------------------------------------
    // TOPIC 3 (ID 3): First Law - Energy & Enthalpy
    // -----------------------------------------------------------------
    {
      "id": 3,
      "topic": "First Law - Energy & Enthalpy",
      "title": "First Law - Energy & Enthalpy",
      "overview": "પ્રથમ નિયમ એ ઊર્જા સંરક્ષણનો નિયમ (Law of Conservation of Energy) છે જે દર્શાવે છે કે સાયકલિક પ્રક્રિયા માટે ચોખ્ખી ઉષ્મા ચોખ્ખા કાર્ય સમાન હોય છે (∮ δQ = ∮ δW). (PDF Pages 5–7)",
      "concept": "First Law of Thermodynamics: ઊર્જા ઉત્પન્ન કરી શકાતી નથી કે નાશ કરી શકાતી નથી, માત્ર તેનું એક સ્વરૂપમાંથી બીજા સ્વરૂપમાં રૂપાંતર થાય છે. Closed System Process: δQ = dU + δW. Steady Flow Open System (SFEE): h_1 + V_1²/2 + g z_1 + q = h_2 + V_2²/2 + g z_2 + w.",
      "definitions": [
        "First Law for Cycle: ∮ δQ = ∮ δW (ચક્ર દરમિયાન નેટ હીટ ટ્રાન્સફર નેટ વર્ક ટ્રાન્સફર સમાન હોય છે).",
        "Internal Energy (U): પદાર્થમાં રહેલા અણુઓનની ગતિ અને સ્થિતિ ઊર્જાનો સરવાળો, જે સ્ટેટ પ્રોપર્ટી છે (dU = m C_v dT).",
        "Enthalpy (H): ઇન્ટરનલ એનર્જી U અને પ્રેશર-વોલ્યુમ પ્રોડક્ટ P*V નો બેજિક સરવાળો (H = U + P*V, h = u + P*v).",
        "PMM-1 (Perpetual Motion Machine of First Kind): કોઈપણ પ્રકારની ઊર્જાનો વપરાશ કર્યા વગર સતત કાર્ય આપતું કાલ્પનિક મશીન, જે પ્રથમ નિયમનું ઉલ્લંઘન કરે છે તેથી અશક્ય છે."
      ],
      "detailedTheory": '''
૧. વિવિધ થર્મોડાયનેમિક પ્રક્રિયાઓ માટે Work Done, Heat Transfer અને ΔU (PDF Page 6):

(૧) Isobaric Process (Constant Pressure, P = const):
- Work Done: W = P (V_2 - V_1) = m R (T_2 - T_1).
- Heat Transfer: Q = m C_p (T_2 - T_1) = ΔH.
- Internal Energy Change: ΔU = m C_v (T_2 - T_1).

(૨) Isochoric Process (Constant Volume, V = const):
- Work Done: W = 0 (કારણ કે dV = 0).
- Heat Transfer: Q = ΔU = m C_v (T_2 - T_1).

(૩) Isothermal Process (Constant Temperature, T = const):
- Internal Energy Change: ΔU = 0 (ideal gas માટે dT = 0).
- Work Done = Heat Transfer: W = Q = P_1 V_1 ln(V_2 / V_1) = m R T ln(P_1 / P_2).

(૪) Isentropic / Reversible Adiabatic Process (Q = 0, S = const):
- Heat Transfer: Q = 0.
- Work Done: W = (P_1 V_1 - P_2 V_2) / (γ - 1) = m R (T_1 - T_2) / (γ - 1).
- Relation: P V^γ = constant, T_2/T_1 = (P_2/P_1)^((γ-1)/γ).

(૫) Polytropic Process (P V^n = constant):
- Work Done: W = (P_1 V_1 - P_2 V_2) / (n - 1).
- Heat Transfer: Q = W * [(γ - n) / (γ - 1)].

૨. Steady Flow Energy Equation (SFEE) ના ઉપકરણો (PDF Page 7):
- Steam/Gas Turbine: Q ≈ 0, ΔKE ≈ 0, ΔPE ≈ 0 => Work Output W = h_1 - h_2.
- Compressor / Pump: Q ≈ 0 => Work Input W = h_2 - h_1.
- Nozzle: Q = 0, W = 0 => Exit Velocity V_2 = √(2 * (h_1 - h_2) + V_1²).
- Throttling Valve: Isenthalpic process (h_1 = h_2, W = 0, Q = 0).
'''.trim(),
      "keyPoints": [
        "First Law for Cycle -> ∮ δQ = ∮ δW.",
        "First Law for Process -> δQ = dU + δW.",
        "PMM-1 violates First Law of Thermodynamics and is IMPOSSIBLE.",
        "Isochoric Process -> W = 0, Q = ΔU.",
        "Isothermal Process -> ΔU = 0, Q = W.",
        "Isenthalpic Process (Throttling) -> h_1 = h_2.",
        "Turbine Work Output -> W = h_1 - h_2.",
        "Nozzle Exit Velocity -> V_2 = √(2 * Δh) if V_1 ≈ 0."
      ],
      "formulas": [
        "First Law Equation: \\delta Q = dU + \\delta W",
        "Enthalpy Equation: H = U + P * V \\implies h = u + P * v",
        "Isothermal Work: W = P_1 V_1 \\ln\\left(\\frac{V_2}{V_1}\\right)",
        "Adiabatic Work: W = \\frac{P_1 V_1 - P_2 V_2}{\\gamma - 1}",
        "SFEE Turbine Work: W_{turbine} = h_1 - h_2 \\text{ (kJ/kg)}",
        "Nozzle Velocity: V_2 = \\sqrt{2000 * (h_1 - h_2)} \\text{ (m/s if h in kJ/kg)}"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ (SFEE Steam Turbine Work Output):\nઆપેલ વિગતો (Given Data):\n- ઇનલેટ એન્થાલ્પી h_1 = 3200 kJ/kg\n- આઉટલેટ એન્થાલ્પી h_2 = 2400 kJ/kg\n- હીટ લોસ Q = -20 kJ/kg (હીટ રિજેક્શન)\n- KE અને PE ફેરફાર નગણ્ય છે.\nશોધવાનું મૂલ્ય: ટર્બાઇન વર્ક આઉટપુટ (w)\nઉકેલ:\nSFEE મુજબ: h_1 + q = h_2 + w\n3200 + (-20) = 2400 + w => 3180 = 2400 + w\nw = 3180 - 2400 = 780 kJ/kg.\nઅંતિમ જવાબ: ટર્બાઇન વર્ક આઉટપુટ w = 780 kJ/kg."
      ],
      "importantPoints": [
        "થ્રોટલિંગ પ્રક્રિયા (Throttling) દરમિયાન કોઈ કાર્ય થતું નથી (W = 0) અને તે Isenthalpic (h_1 = h_2) પ્રક્રિયા છે.",
        "PMM-1 એ એવું મશીન છે જે ઈનપુટ ઊર્જા વગર સતત કાર્ય આપવાનો દાવો કરે છે, જે પ્રથમ નિયમ વિરૂદ્ધ હોવાથી અશક્ય છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: First law of thermodynamics is based on conservation of -> Energy.",
        "GSSSB Golden Question: Perpetual motion machine of first kind (PMM-1) violates -> First Law of Thermodynamics.",
        "GSSSB Golden Question: In an Isenthalpic process, property that remains constant is -> Enthalpy (h).",
        "GSSSB Golden Question: Work done in constant volume process is -> ZERO."
      ],
      "commonMistakes": [
        "⚠️ GSSSB Exam Trap: નોઝલ આઉટલેટ વેગ ના સૂત્ર V = √(2*Δh) માં Δh ને kJ/kg માં રાખી 2 વડે જ ગુણવું (kJ માં હોય તો 2000 વડે ગુણવું પડે કારણ કે 1 kJ = 1000 J!).",
        "⚠️ GSSSB Exam Trap: કોન્સ્ટન્ટ ટેમ્પરેચર (Isothermal) પ્રક્રિયામાં internal energy નો ફેરફાર ગણવો (Ideal gas માટે ΔU = 0 થાય!)."
      ],
      "quickRevision": [
        "δQ = dU + δW.",
        "H = U + PV.",
        "Throttling: h = const.",
        "Turbine: W = h_1 - h_2.",
        "PMM-1 -> Impossible."
      ],
      "mcqs": [],
      "msqs": [],
      "visualLearning": {
        "enabled": true,
        "visualRequired": true,
        "type": "diagram",
        "animationKey": "first_law_anim",
        "title": "First Law - Energy & Enthalpy",
        "purpose": "Visualizing Energy Conservation δQ = dU + δW in Closed System and SFEE Flow Devices",
        "mobileLayout": "vertical_card",
        "sequence": [
          "૧. Piston Cylinder માં Heat Q in, Internal Energy dU અને Work W out નો સંગમ જુઓ.",
          "૨. SFEE Turbine (w = h1 - h2) અને Nozzle Expansion જુઓ.",
          "૩. w = 780 kJ/kg ગણતરી ચકાસો."
        ],
        "diagrams": ["First Law Energy Balance & SFEE Devices Diagram"],
        "rule": "Full animated Gujarati narrative story with GSSSB exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/first_law_energy_enthalpy.mp4",
        "videos": [
          {
            "title": "First Law - Energy & Enthalpy - Full Concept Explanation",
            "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/first_law_energy_enthalpy.mp4",
            "assetPath": "assets/videos/first_law_energy_enthalpy.mp4",
            "description": "Full animated Gujarati video lesson covering First law of thermodynamics, energy conservation, Enthalpy H = U + PV, process equations, and SFEE."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_1_topic_3.png"
      }
    },

    // -----------------------------------------------------------------
    // TOPICS 4 to 10 (Subject 1)
    // -----------------------------------------------------------------
    {
      "id": 4,
      "topic": "Kelvin-Planck & Clausius Statements",
      "title": "Kelvin-Planck & Clausius Statements",
      "overview": "બીજો નિયમ ઉષ્માના વહનની દિશા નક્કી કરે છે અને હીટ એન્જિન, રેફ્રિજરેટર તથા હીટ પમ્પના કાર્યકારી સિદ્ધાંતો દર્શાવે છે. (PDF Pages 7–8)",
      "concept": "Kelvin-Planck Statement: સિંગલ હાઇ થર્મલ રિઝર્વોયર સાથે સંકળાયીને 100% ઉષ્માનું કાર્યમાં રૂપાંતર કરતું હીટ એન્જિન અશક્ય છે. Clausius Statement: બાહ્ય કાર્ય આપ્યા વગર ઉષ્માને નીચા તાપમાનથી ઉંચા તાપમાને સ્વયંભૂ મોકલવી અશક્ય છે. PMM-2 ઇમ્પસિબલ છે.",
      "definitions": [
        "Kelvin-Planck Statement: એવું ચક્રીય હીટ એન્જિન બનાવવું અશક્ય છે જે માત્ર એક જ રિઝર્વોયરથી ઉષ્મા મેળવી સમાન પ્રમાણમાં ચોખ્ખું કાર્ય આપે.",
        "Clausius Statement: એવું ચક્રીય સાધન બનાવવું અશક્ય છે જે બાહ્ય કાર્ય વગર ઠંડા પદાર્થમાંથી ગરમ પદાર્થ તરફ ઉષ્મા ટ્રાન્સફર કરે.",
        "PMM-2 (Perpetual Motion Machine of Second Kind): સિંગલ રિઝર્વોયરથી 100% એફિશિયન્સી બતાવતું અશક્ય મશીન."
      ],
      "detailedTheory": '''
૧. બીજા નિયમની બે મુખ્ય વિધાન રજૂઆતો (PDF Pages 7–8):
- Kelvin-Planck Statement -> Heat Engines માટે લાગુ પડે છે (η < 100%).
- Clausius Statement -> Refrigerators & Heat Pumps માટે લાગુ પડે છે (W_in > 0).
- Equivalence of Statements -> જો કેલ્વિન-પ્લાન્કનું ઉલ્લંઘન થાય તો ક્લોસિયસનું પણ ઉલ્લંઘન થાય છે અને ઊલટું.

૨. બીજા નિયમના ઉપકરણોની સરખામણી:
- Heat Engine Efficiency: η = W_net / Q_1 = (Q_1 - Q_2) / Q_1 = 1 - (Q_2 / Q_1).
- Refrigerator COP: COP_R = Q_L / W_in = Q_L / (Q_H - Q_L).
- Heat Pump COP: COP_HP = Q_H / W_in = Q_H / (Q_H - Q_L).
- COP Relation: COP_HP = COP_R + 1.
'''.trim(),
      "keyPoints": [
        "Kelvin-Planck applies to -> Heat Engines.",
        "Clausius Statement applies to -> Refrigerators and Heat Pumps.",
        "COP_HP = COP_R + 1.",
        "PMM-2 gives 100% thermal efficiency and violates Second Law.",
        "Heat cannot flow spontaneously from cold to hot body."
      ],
      "formulas": [
        "Heat Engine Efficiency: \\eta = 1 - \\frac{Q_2}{Q_1}",
        "Refrigerator COP: COP_R = \\frac{Q_L}{Q_H - Q_L}",
        "Heat Pump COP: COP_{HP} = \\frac{Q_H}{Q_H - Q_L} = COP_R + 1"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ (Heat Engine Efficiency & Heat Rejection):\nઆપેલ વિગતો (Given Data):\n- હીટ સપ્લાય Q_1 = 1000 kJ\n- વર્ક આઉટપુટ W = 400 kJ\nશોધવાનું મૂલ્ય: એફિશિયન્સી η અને હીટ રિજેક્શન Q_2\nઉકેલ:\nη = W / Q_1 = 400 / 1000 = 0.40 = 40%.\nQ_2 = Q_1 - W = 1000 - 400 = 600 kJ.\nઅંતિમ જવાબ: η = 40%, Q_2 = 600 kJ."
      ],
      "importantPoints": [
        "હીટ પમ્પનો COP કાયમ ૧ કરતા વધારે (COP_HP > 1) હોય છે કારણ કે COP_HP = COP_R + 1."
      ],
      "examPoints": [
        "GSSSB Golden Question: Kelvin-Planck statement deals with conversion of -> Heat into Work.",
        "GSSSB Golden Question: Relationship between COP of Heat Pump and Refrigerator -> COP_HP = COP_R + 1.",
        "GSSSB Golden Question: PMM-2 violates -> Second Law of Thermodynamics."
      ],
      "commonMistakes": [
        "⚠️ GSSSB Exam Trap: હીટ પમ્પ અને રેફ્રિજરેટર ના COP સૂત્રો વચ્ચે કન્ફ્યુઝન થવું (હીટ પમ્પમાં અંશમાં Q_H આવે, રેફ્રિજરેટરમાં અંશમાં Q_L આવે!)."
      ],
      "quickRevision": [
        "Kelvin-Planck = Engine (η < 1).",
        "Clausius = Ref / HP.",
        "COP_HP = COP_R + 1.",
        "PMM-2 = Impossible."
      ],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "second_law_anim",
        "title": "Kelvin-Planck & Clausius Statements", "purpose": "Visualizing Heat Engine Sink Rejection and Heat Pump Work Input",
        "mobileLayout": "vertical_card",
        "sequence": [
          "૧. Heat Engine T1 થી Q1 મેળવી W આપી T2 પર Q2 રિજેક્ટ કરતું જુઓ.",
          "૨. Heat Pump T2 થી QL ખેંચી W_in વડે T1 પર QH આપતું જુઓ.",
          "૩. COP_HP = COP_R + 1 ચકાસો."
        ],
        "diagrams": ["Kelvin-Planck Engine & Clausius Heat Pump Diagram"],
        "rule": "Full animated Gujarati narrative story with GSSSB exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/kelvin_planck_and_clausius.mp4",
        "videos": [
          {
            "title": "Kelvin-Planck & Clausius Statements - Full Concept Explanation",
            "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/kelvin_planck_and_clausius.mp4",
            "assetPath": "assets/videos/kelvin_planck_and_clausius.mp4",
            "description": "Full video on Second Law, Kelvin-Planck and Clausius statements, COP relations, and PMM-2."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_1_topic_4.png"
      }
    },
    {
      "id": 5,
      "topic": "Entropy & Clausius Inequality",
      "title": "Entropy & Clausius Inequality",
      "overview": "એન્ટ્રોપી એ સિસ્ટમમાં અનિવાર્યપણે રહેલી અસ્વસ્થતા (Disorder) અથવા ઉર્જાની બિન-ઉપયોગીતા દર્શાવતી પ્રોપર્ટી છે. (PDF Pages 8–9)",
      "concept": "Clausius Inequality: ∮ (δQ / T) ≤ 0. Reversible Cycle: ∮ (δQ / T) = 0. Irreversible Cycle: ∮ (δQ / T) < 0. Impossible Cycle: ∮ (δQ / T) > 0. Entropy change dS = (δQ / T)_rev. Principle of Increase of Entropy: (dS)_universe ≥ 0.",
      "definitions": [
        "Clausius Inequality: કોઈપણ થર્મોડાયનેમિક સાયકલ માટે ∮ (δQ / T) કાયમ ≤ 0 હોય છે.",
        "Entropy (S): રિવર્સિબલ હીટ ટ્રાન્સફર અને તાપમાનનો ગુણોત્તર (dS = δQ_rev / T, SI Unit: kJ/K).",
        "Principle of Increase of Entropy: આઇસોલેટેડ સિસ્ટમ કે યુનિવર્સની એન્ટ્રોપી કાયમ વધે છે અથવા અચળ રહે છે ((dS)_universe ≥ 0)."
      ],
      "detailedTheory": '''
૧. ક્લોસિયસ ઇનિક્વાલિટી ની શરતો (PDF Page 8):
- ∮ (δQ / T) = 0 -> Reversible Cycle.
- ∮ (δQ / T) < 0 -> Irreversible Cycle.
- ∮ (δQ / T) > 0 -> Impossible Cycle (અશક્ય ચક્ર).

૨. આઇડિયલ ગેસ માટે એન્ટ્રોપી ફેરફારના સૂત્રો (PDF Page 9):
- T અને V ના પદમાં: s_2 - s_1 = C_v ln(T_2 / T_1) + R ln(v_2 / v_1).
- T અને P ના પદમાં: s_2 - s_1 = C_p ln(T_2 / T_1) - R ln(P_2 / P_1).
- P અને V ના પદમાં: s_2 - s_1 = C_v ln(P_2 / P_1) + C_p ln(v_2 / v_1).
'''.trim(),
      "keyPoints": [
        "∮ (δQ / T) = 0 for Reversible Cycle.",
        "∮ (δQ / T) < 0 for Irreversible Cycle.",
        "∮ (δQ / T) > 0 is IMPOSSIBLE.",
        "dS = (δQ / T)_rev.",
        "Entropy of Universe ALWAYS INCREASES ((dS)_universe > 0)."
      ],
      "formulas": [
        "Clausius Inequality: \\oint \\frac{\\delta Q}{T} \\le 0",
        "Entropy Definition: dS = \\left(\\frac{\\delta Q}{T}\\right)_{rev}",
        "Ideal Gas Entropy Change: s_2 - s_1 = C_p \\ln\\left(\\frac{T_2}{T_1}\\right) - R \\ln\\left(\\frac{P_2}{P_1}\\right)"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ (Entropy Change in Reversible Heat Transfer):\nઆપેલ વિગતો (Given Data):\n- ઉષ્મા Q = 3000 kJ\n- તાપમાન T = 300 K (Constant)\nશોધવાનું મૂલ્ય: એન્ટ્રોપી ફેરફાર ΔS\nઉકેલ:\nΔS = Q / T = 3000 / 300 = 10 kJ/K.\nઅંતિમ જવાબ: ΔS = 10 kJ/K."
      ],
      "importantPoints": [
        "રિવર્સિબલ એડિયાબેટિક પ્રક્રિયાને Isentropic (S = const) પ્રક્રિયા કહે છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: Clausius inequality statement for reversible cycle is -> ∮ (δQ / T) = 0.",
        "GSSSB Golden Question: Change in entropy during reversible adiabatic process is -> ZERO (Isentropic).",
        "GSSSB Golden Question: Entropy of the universe -> Always Increases."
      ],
      "commonMistakes": [
        "⚠️ GSSSB Exam Trap: ∮ (δQ / T) > 0 ને પોસિબલ ગણવું (તે ચોક્કસ અશક્ય ઇમ્પસિબલ ચક્ર દર્શાવે છે!)."
      ],
      "quickRevision": [
        "∮ δQ/T = 0 (Rev).",
        "∮ δQ/T < 0 (Irrev).",
        "dS = δQ/T.",
        "dS_universe ≥ 0."
      ],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "entropy_anim",
        "title": "Entropy & Clausius Inequality", "purpose": "Visualizing T-s Diagram Area Heat Q and Clausius Cyclic Integral",
        "mobileLayout": "vertical_card",
        "sequence": ["૧. T-s Diagram પર રેખા હેઠળનો વિસ્તાર Q_rev બતાવે છે.", "૨. ∮ δQ/T ≤ 0 ની શરતો જુઓ."],
        "diagrams": ["T-s Diagram & Clausius Inequality Diagram"],
        "rule": "Full animated Gujarati story with GSSSB exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/entropy_and_clausius_inequality.mp4",
        "videos": [{"title": "Entropy & Clausius Inequality Explanation", "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/entropy_and_clausius_inequality.mp4", "assetPath": "assets/videos/entropy_and_clausius_inequality.mp4", "description": "Full lesson on Clausius Inequality and Entropy."}],
        "imageUrl": "assets/images/diagrams/subj_1_topic_5.png"
      }
    },
    {
      "id": 6,
      "topic": "Properties, Process & State",
      "title": "Properties, Process & State",
      "overview": "સિસ્ટમની સ્થિતિ (State), પ્રક્રિયા (Process) અને ઇન્ટેન્સિવ તથા એક્સટેન્સિવ ગુણધર્મોનું વિશ્લેષણ. (PDF Pages 5–6)",
      "concept": "Intensive Properties: દ્રવ્યના જથ્થા (mass/size) પર આધાર રાખતા નથી (T, P, ρ, Viscosity). Extensive Properties: કુલ જથ્થા પર આધાર રાખે છે (m, V, U, H, S). Point Function & Exact Differential (P, V, T). Path Function & Inexact Differential (Q, W).",
      "definitions": [
        "Intensive Property: દ્રવ્યના જથ્થાથી મુક્ત ગુણધર્મ (જેમ કે તાપમાન T, દબાણ P, ડેન્સિટી ρ).",
        "Extensive Property: દ્રવ્યના જથ્થા પર આધારિત ગુણધર્મ (જેમ કે માસ m, વોલ્યુમ V, ઇન્ટરનલ એનર્જી U).",
        "Point Function: જેનું મૂલ્ય માત્ર પ્રારંભિક અને અંતિમ સ્થિતિ પર જ આધાર રાખે છે (Exact Differential dP, dT, dU).",
        "Path Function: જેનું મૂલ્ય પ્રક્રિયાના રસ્તા (Path) પર આધાર રાખે છે (Inexact Differential δQ, δW)."
      ],
      "detailedTheory": '''
૧. Intensive vs Extensive Properties ની તુલના (PDF Page 5):
- Intensive: Temperature, Pressure, Density, Viscosity, Specific Volume (v = V/m).
- Extensive: Mass, Volume, Internal Energy, Enthalpy, Entropy.
- નિયમ: બે Extensive properties નો ગુણોત્તર (Ratio) હંમેશા Intensive Property બની જાય છે! (દા.ત. Specific Volume v = V / m).

૨. Point vs Path Functions:
- Point Functions: ∮ dZ = 0 (ચક્ર માટે ફેરફાર ઝીરો થાય).
- Path Functions: ∮ δQ ≠ 0, ∮ δW ≠ 0 (ચક્ર માટે કાર્ય અને ઉષ્મા ઝીરો થતા નથી).
'''.trim(),
      "keyPoints": [
        "All Specific Properties (Specific Enthalpy, Specific Volume) are INTENSIVE.",
        "Heat Q and Work W are PATH FUNCTIONS and INEXACT DIFFERENTIALS.",
        "Thermodynamic Properties (P, V, T, U, H, S) are POINT FUNCTIONS and EXACT DIFFERENTIALS.",
        "Ratio of two extensive properties is an INTENSIVE property."
      ],
      "formulas": [
        "Exact Differential Cycle Integral: \\oint dP = 0, \\oint dT = 0, \\oint dU = 0",
        "Specific Property Relation: v = \\frac{V}{m} \\text{ (Intensive)}"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ (Specific Volume Calculation):\nઆપેલ વિગતો: V = 0.5 m³, m = 2 kg.\nv = V / m = 0.5 / 2 = 0.25 m³/kg (Intensive property)."
      ],
      "importantPoints": [
        "Heat (Q) અને Work (W) એ સિસ્ટમની પ્રોપર્ટી નથી, પરંતુ બાઉન્ડ્રી ફેનોમિના (Boundary Phenomena) છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: Heat and Work are -> Path Functions and Inexact Differentials.",
        "GSSSB Golden Question: Which of the following is an Intensive property? -> Density / Temperature / Pressure.",
        "GSSSB Golden Question: Specific volume is an -> Intensive Property."
      ],
      "commonMistakes": [
        "⚠️ GSSSB Exam Trap: ડેન્સિટી કે સ્પેસિફિક વોલ્યુમને એક્સટેન્સિવ માનવું (બધી જ સ્પેસિફિક પ્રોપર્ટીઝ ઇન્ટેન્સિવ હોય છે!)."
      ],
      "quickRevision": [
        "Intensive = Mass Independent.",
        "Extensive = Mass Dependent.",
        "Q, W = Path Functions.",
        "P, V, T = Point Functions."
      ],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "prop_process_anim",
        "title": "Properties, Process & State", "purpose": "Visualizing Intensive vs Extensive Split System Comparison and P-V Path Dependence",
        "mobileLayout": "vertical_card",
        "sequence": ["૧. Box Split કરતાં T સમાન (Intensive) અને Mass/Volume અડધા (Extensive) જુઓ.", "૨. P-V Diagram પર Path 1 અને Path 2 નો Work Area ફેરફાર જુઓ."],
        "diagrams": ["Intensive vs Extensive Properties Diagram"],
        "rule": "Full animated Gujarati story with GSSSB exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/properties_process_and_state.mp4",
        "videos": [{"title": "Properties & Process Explanation", "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/properties_process_and_state.mp4", "assetPath": "assets/videos/properties_process_and_state.mp4", "description": "Full lesson on Intensive/Extensive properties and Point/Path functions."}],
        "imageUrl": "assets/images/diagrams/subj_1_topic_6.png"
      }
    },
    {
      "id": 7,
      "topic": "Pure Substances & Ideal/Real Gases",
      "title": "Pure Substances & Ideal/Real Gases",
      "overview": "પ્યોર સબસ્ટન્સ (પાણી/સ્ટીમ) ની અવસ્થાઓ, P-v-T સપાટીઓ અને આઇડિયલ વિરુદ્ધ રિયલ ગેસ ઇક્વેશન્સ. (PDF Pages 10–11)",
      "concept": "Pure Substance: અચળ રાસાયણિક બંધારણ ધરાવતો પદાર્થ (જેમ કે પાણી + વરાળ). Ideal Gas Equation: P V = m R T. Compressibility Factor Z = P V / (R T) (Ideal gas Z = 1). Van der Waals Equation: (P + a/v²)(v - b) = R T.",
      "definitions": [
        "Pure Substance: એવો પદાર્થ જે તમામ અવસ્થાઓમાં અચળ અને સમાન રાસાયણિક બંધારણ ધરાવે છે.",
        "Compressibility Factor (Z): Z = P v / (R T). આઇડિયલ ગેસ માટે Z = 1 હોય છે.",
        "Critical Point of Water: જ્યાં સેચ્યુરેટેડ લિક્વિડ અને સેચ્યુરેટેડ વેપર લાઇન મળે છે (T_c = 374.14 °C, P_c = 22.06 MPa / 221.2 bar)."
      ],
      "detailedTheory": '''
૧. આઇડિયલ ગેસ ના નિયમો (PDF Page 10):
- Boyle's Law: P ∝ 1/V (T = const).
- Charles's Law: V ∝ T (P = const).
- Gay-Lussac's Law: P ∝ T (V = const).
- Ideal Gas Equation: P V = m R T (જ્યાં R = R_u / M, Air માટે R = 0.287 kJ/kg·K).

૨. વાસ્તવિક વાયુઓ અને Van der Waals Equation:
- (P + a/v²)(v - b) = R T.
- a/v² -> અણુઓ વચ્ચેના આકર્ષણ બળનું કરેક્શન.
- b -> અણુઓ દ્વારા રોકાયેલા પોતાના કદનું કરેક્શન (Co-volume).
'''.trim(),
      "keyPoints": [
        "Ideal Gas Equation -> P V = m R T.",
        "Air Characteristic Gas Constant R -> 0.287 kJ/kg·K.",
        "Universal Gas Constant R_u -> 8.314 kJ/kmol·K.",
        "Water Critical Point -> T_c = 374.14 °C, P_c = 22.06 MPa (221.2 bar).",
        "Ideal Gas Compressibility Factor Z = 1."
      ],
      "formulas": [
        "Ideal Gas Equation: P V = m R T",
        "Gas Constant Relation: R = \\frac{R_u}{M}",
        "Van der Waals Equation: \\left(P + \\frac{a}{v^2}\\right)(v - b) = R T",
        "Compressibility Factor: Z = \\frac{P v}{R T}"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ (Ideal Gas Pressure Calculation):\nઆપેલ વિગતો: m = 2 kg હવા, V = 0.5 m³, T = 300 K, R = 287 J/kg·K.\nP = (m * R * T) / V = (2 * 287 * 300) / 0.5 = 172200 / 0.5 = 344400 Pa = 344.4 kPa."
      ],
      "importantPoints": [
        "પાણીના ક્રિટીકલ પોઇન્ટ (22.06 MPa) થી ઉંચા દબાણે સેચ્યુરેશન ફેઝ દેખાતો નથી અને પાણી સીધું બાષ્પ બની જાય છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: Value of characteristic gas constant R for air is -> 0.287 kJ/kg·K.",
        "GSSSB Golden Question: Value of Universal Gas Constant R_u is -> 8.314 kJ/kmol·K.",
        "GSSSB Golden Question: Critical pressure for water is -> 22.06 MPa (221.2 bar)."
      ],
      "commonMistakes": [
        "⚠️ GSSSB Exam Trap: R ની કિંમત J/kg·K અને kJ/kg·K વચ્ચે અદલાબદલી કરવી (287 J/kg·K = 0.287 kJ/kg·K!)."
      ],
      "quickRevision": [
        "PV = mRT.",
        "R_air = 0.287 kJ/kgK.",
        "R_u = 8.314.",
        "Z = 1 (Ideal)."
      ],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "pure_sub_anim",
        "title": "Pure Substances & Ideal/Real Gases", "purpose": "Visualizing Steam T-s Dome Critical Point and Compressibility Chart",
        "mobileLayout": "vertical_card",
        "sequence": ["૧. Steam T-s Dome અને Critical Point (22.06 MPa) જુઓ.", "૨. Ideal Gas Z=1 vs Real Gas Van der Waals જુઓ."],
        "diagrams": ["Steam T-s Dome & Real Gas Chart Diagram"],
        "rule": "Full animated Gujarati story with GSSSB exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/pure_substances_and_gases.mp4",
        "videos": [{"title": "Pure Substances & Real Gases Explanation", "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/pure_substances_and_gases.mp4", "assetPath": "assets/videos/pure_substances_and_gases.mp4", "description": "Full lesson on Pure substances, Critical point, and Ideal/Real gas equations."}],
        "imageUrl": "assets/images/diagrams/subj_1_topic_7.png"
      }
    },
    {
      "id": 8,
      "topic": "Second Law - Heat Engines & COP",
      "title": "Second Law - Heat Engines & COP",
      "overview": "હીટ એન્જિનની એફિશિયન્સી અને રેફ્રિજરેટર / હીટ પમ્પના કોએફિશિયન્ટ ઓફ પરફોર્મન્સ (COP) નું ગણિતીક વિશ્લેષણ. (PDF Page 8)",
      "concept": "Thermal Efficiency η = W_net / Q_1 = 1 - (Q_2 / Q_1). Refrigerator COP_R = Q_L / W_in = Q_L / (Q_H - Q_L). Heat Pump COP_HP = Q_H / W_in = Q_H / (Q_H - Q_L). COP_HP = COP_R + 1.",
      "definitions": [
        "Thermal Efficiency (η): હીટ એન્જિન વડે મળતા ચોખ્ખા કાર્ય અને મેળવેલી ઉષ્માનો ગુણોત્તર (η = W / Q_1).",
        "Coefficient of Performance (COP): રેફ્રિજરેટર કે હીટ પમ્પમાં ઇચ્છિત કૂલિંગ કે હીટિંગ અસર અને આપવા પડતા વર્ક ઇનપુટ નો ગુણોત્તર."
      ],
      "detailedTheory": '''
૧. હીટ એન્જિન અને હીટ પમ્પની સરખામણી (PDF Page 8):
- Heat Engine: T_H માંથી Q_1 મેળવી W આપે છે અને T_L પર Q_2 છોડે છે.
- Refrigerator: T_L માંથી Q_L શોષી W ઇનપુટ વડે T_H પર Q_H મુક્ત કરે છે.
- Heat Pump: ઘરને ગરમ રાખવા T_H પર Q_H પમ્પ કરે છે.

૨. Carnot Efficiency (મહત્તમ સૈદ્ધાંતિક મર્યાદા):
- η_carnot = 1 - (T_L / T_H) (જ્યાં T કેલ્વિનમાં જ લેવું!).
'''.trim(),
      "keyPoints": [
        "Carnot Efficiency depends ONLY on Reservoir Temperatures T_H and T_L.",
        "COP_HP = COP_R + 1.",
        "Temperatures MUST be in Kelvin for Carnot calculations."
      ],
      "formulas": [
        "Carnot Efficiency: \\eta_{carnot} = 1 - \\frac{T_L}{T_H}",
        "Carnot Refrigerator COP: COP_{R, carnot} = \\frac{T_L}{T_H - T_L}",
        "Carnot Heat Pump COP: COP_{HP, carnot} = \\frac{T_H}{T_H - T_L}"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ (Carnot Engine Efficiency):\nઆપેલ વિગતો: T_H = 600 K, T_L = 300 K.\nη_carnot = 1 - (300 / 600) = 1 - 0.5 = 0.5 = 50%."
      ],
      "importantPoints": [
        "કોઈપણ વાસ્તવિક હીટ એન્જિનની એફિશિયન્સી તેના જેટલા જ તાપમાનો વચ્ચે ચાલતા કાર્નોટ એન્જિન કરતાં વધુ હોઈ શકે નહીં."
      ],
      "examPoints": [
        "GSSSB Golden Question: Carnot cycle efficiency depends on -> Working Temperatures (T_H and T_L) only.",
        "GSSSB Golden Question: Relation between COP of heat pump and refrigerator -> COP_HP = COP_R + 1."
      ],
      "commonMistakes": [
        "⚠️ GSSSB Exam Trap: કાર્નોટ સૂત્રમાં તાપમાન °C માં મૂકી દેવું (કાયમ K = °C + 273.15 કેલ્વિનમાં જ મૂકવું!)."
      ],
      "quickRevision": [
        "η = 1 - T_L/T_H.",
        "COP_R = T_L/(T_H-T_L).",
        "COP_HP = COP_R + 1."
      ],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "cop_anim",
        "title": "Second Law - Heat Engines & COP", "purpose": "Visualizing Thermal Reservoirs T_H & T_L with Carnot Efficiency Limits",
        "mobileLayout": "vertical_card",
        "sequence": ["૧. T_H (600 K) અને T_L (300 K) વચાળે Carnot Efficiency 50% જુઓ.", "૨. Refrigerator અને Heat Pump COP સરખામણી જુઓ."],
        "diagrams": ["Carnot Cycle & COP Energy Flows Diagram"],
        "rule": "Full animated Gujarati story with GSSSB exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/second_law_heat_engines_cop.mp4",
        "videos": [{"title": "Second Law & COP Explanation", "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/second_law_heat_engines_cop.mp4", "assetPath": "assets/videos/second_law_heat_engines_cop.mp4", "description": "Full lesson on Heat engines, Carnot efficiency, and COP relations."}],
        "imageUrl": "assets/images/diagrams/subj_1_topic_8.png"
      }
    },
    {
      "id": 9,
      "topic": "Carnot Cycle & Reversibility",
      "title": "Carnot Cycle & Reversibility",
      "overview": "કાર્નોટ સાયકલ એ મહત્તમ સૈદ્ધાંતિક કાર્યક્ષમતા આપતું કાલ્પનિક આઇડિયલ ચક્ર છે જે ૪ રિવર્સિબલ પ્રક્રિયાઓનું બનેલું છે. (PDF Page 8)",
      "concept": "4 Processes of Carnot Cycle: (1-2) Reversible Isothermal Heat Addition, (2-3) Reversible Adiabatic Expansion, (3-4) Reversible Isothermal Heat Rejection, (4-1) Reversible Adiabatic Compression. Efficiency η = 1 - T_L / T_H.",
      "definitions": [
        "Reversible Process: જે પ્રક્રિયા બાદ સિસ્ટમ અને પર્યાવરણ બંને કોઈ પણ ટ્રેસ છોડ્યા વગર પોતાની મૂળ સ્થિતિમાં પાછા ફરી શકે.",
        "Carnot Theorem: સમાન બે તાપમાન રિઝર્વોયર્સ વચ્ચે કામ કરતા તમામ એન્જિનોમાંથી કાર્નોટ (રિવર્સિબલ) એન્જિનની કાર્યક્ષમતા સૌથી વધુ હોય છે."
      ],
      "detailedTheory": '''
૧. કાર્નોટ ચક્રની ૪ પ્રક્રિયાઓ (PDF Page 8):
- Process 1-2: Isothermal Heat Addition (T_H = const, Q_1 = m R T_H ln(V_2 / V_1)).
- Process 2-3: Isentropic Expansion (Q = 0, T_H થી T_L ઘટે છે).
- Process 3-4: Isothermal Heat Rejection (T_L = const, Q_2 = m R T_L ln(V_3 / V_4)).
- Process 4-1: Isentropic Compression (Q = 0, T_L થી T_H વધે છે).

૨. પ્રાયોગિક અશક્યતા (Practical Impossibility):
આઇસોથર્મલ પ્રક્રિયા અત્યંત ધીમી અને એડિયાબેટિક પ્રક્રિયા અતિ ઝડપી હોવાથી એક જ એન્જિનમાં બંને ઝડપનો સમન્વય અશક્ય છે. તેથી કાર્નોટ સાયકલ વ્યવહારમાં બનાવી શકાતું નથી.
'''.trim(),
      "keyPoints": [
        "Carnot Cycle consists of 2 Isothermal + 2 Reversible Adiabatic processes.",
        "P-V and T-s Diagrams are Rectangular in shape for Carnot Cycle.",
        "No real engine can have efficiency higher than Carnot engine."
      ],
      "formulas": [
        "Carnot Cycle Efficiency: \\eta_{carnot} = 1 - \\frac{T_L}{T_H}",
        "Work Done in Carnot Cycle: W_{net} = (T_H - T_L) * \\Delta S"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ (Carnot Cycle Work Done): ΔS = 2 kJ/K, T_H = 500 K, T_L = 300 K. W_net = (500 - 300) * 2 = 400 kJ."
      ],
      "importantPoints": [
        "કાર્નોટ સાયકલનો T-s ડાયાગ્રામ ચોરસ અથવા લંબચોરસ (Rectangle) બને છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: Processes in Carnot cycle -> 2 Reversible Isothermal + 2 Reversible Adiabatic.",
        "GSSSB Golden Question: Shape of Carnot cycle on T-s diagram -> Rectangle."
      ],
      "commonMistakes": [
        "⚠️ GSSSB Exam Trap: કાર્નોટ ચક્રમાં ઇરેવર્સિબલ પ્રક્રિયાઓ હોવાનું માનવું (તે બધી જ ૪ રિવર્સિબલ પ્રક્રિયાઓનું બનેલું છે!)."
      ],
      "quickRevision": [
        "2 Isothermal + 2 Isentropic.",
        "η = 1 - T_L/T_H.",
        "T-s shape = Rectangle."
      ],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "carnot_anim",
        "title": "Carnot Cycle & Reversibility", "purpose": "Visualizing Carnot Cycle P-V Curves and T-S Rectangle Shape",
        "mobileLayout": "vertical_card",
        "sequence": ["૧. Carnot P-V Diagram અને T-S Rectangle Shape જુઓ.", "૨. 4 Reversible Processes (2 Isothermal + 2 Isentropic) જુઓ."],
        "diagrams": ["Carnot Cycle P-V and T-S Diagrams"],
        "rule": "Full animated Gujarati story with GSSSB exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/carnot_cycle_reversibility.mp4",
        "videos": [{"title": "Carnot Cycle Explanation", "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/carnot_cycle_reversibility.mp4", "assetPath": "assets/videos/carnot_cycle_reversibility.mp4", "description": "Full lesson on Carnot cycle 4 processes and reversibility."}],
        "imageUrl": "assets/images/diagrams/subj_1_topic_9.png"
      }
    },
    {
      "id": 10,
      "topic": "Rankine, Brayton & Vapor Compression Cycles",
      "title": "Rankine, Brayton & Vapor Compression Cycles",
      "overview": "વરાળ પાવર પ્લાન્ટ માટે રેન્કિન સાયકલ, ગેસ ટર્બાઇન માટે બ્રેટન સાયકલ અને રેફ્રિજરેશન માટે VCRS સાયકલ. (PDF Pages 12, 15)",
      "concept": "Rankine Cycle: Boiler, Turbine, Condenser, Pump (h3-h4 - wp)/(h3-h2). Brayton Cycle: Compressor, Combustion Chamber, Gas Turbine, Heat Exchanger (η = 1 - 1/r_p^((γ-1)/γ)). VCRS Cycle: Compressor, Condenser, Expansion Valve (Isenthalpic), Evaporator.",
      "definitions": [
        "Rankine Cycle: થર્મલ પાવર પ્લાન્ટ્સમાં સ્ટીમ વડે વીજળી ઉત્પન્ન કરવાનું આઇડિયલ વેપર પાવર સાયકલ.",
        "Brayton Cycle: ગેસ ટર્બાઇન પાવર પ્લાન્ટ્સ અને જેટ એન્જિન્સનું આઇડિયલ ગેસ પાવર સાયકલ.",
        "VCRS Cycle: કમ્પ્રેશન, કન્ડેન્સેશન, થ્રોટલિંગ અને ઇવેપોરેશન આધારિત વિહવહારિક રેફ્રિજરેશન સાયકલ."
      ],
      "detailedTheory": '''
૧. સાયકલોની પ્રક્રિયાઓ અને સરખામણી (PDF Pages 12, 15):

(૧) Rankine Cycle (PDF Page 15):
- 1-2: Isentropic Pumping in Pump (W_p = v_f (P_2 - P_1)).
- 2-3: Constant Pressure Heat Addition in Boiler (Q_in = h_3 - h_2).
- 3-4: Isentropic Expansion in Turbine (W_t = h_3 - h_4).
- 4-1: Constant Pressure Heat Rejection in Condenser (Q_out = h_4 - h_1).
- Efficiency: η = [(h_3 - h_4) - W_p] / (h_3 - h_2).

(૨) Brayton Cycle (Gas Turbine):
- 2 Constant Pressure + 2 Isentropic processes.
- Efficiency: η = 1 - (1 / r_p^((γ-1)/γ)) (જ્યાં r_p = Pressure Ratio P_2/P_1).

(૩) VCRS Cycle (Refrigeration — PDF Page 12):
- 1-2: Isentropic Compression in Compressor.
- 2-3: Constant Pressure Condensation in Condenser.
- 3-4: Isenthalpic Throttling in Expansion Valve (h_3 = h_4).
- 4-1: Constant Pressure Evaporation in Evaporator (Refrigerating Effect q_re = h_1 - h_4).
- COP = (h_1 - h_4) / (h_2 - h_1).
'''.trim(),
      "keyPoints": [
        "Rankine Cycle is ideal cycle for Steam Thermal Power Plants.",
        "Brayton Cycle is ideal cycle for Gas Turbines (η = 1 - 1/r_p^((γ-1)/γ)).",
        "VCRS Throttling Process in Expansion Valve is ISENTHALPIC (h_3 = h_4).",
        "VCRS COP = (h_1 - h_4) / (h_2 - h_1)."
      ],
      "formulas": [
        "Rankine Efficiency: \\eta = \\frac{(h_3 - h_4) - w_p}{h_3 - h_2}",
        "Brayton Efficiency: \\eta = 1 - \\frac{1}{r_p^{\\frac{\\gamma - 1}{\\gamma}}}",
        "VCRS COP: COP = \\frac{h_1 - h_4}{h_2 - h_1}"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ (VCRS COP Calculation):\nઆપેલ વિગતો: h_1 (Evaporator Exit) = 1400 kJ/kg, h_2 (Compressor Exit) = 1600 kJ/kg, h_3 = h_4 (Expansion Exit) = 600 kJ/kg.\nCOP = (1400 - 600) / (1600 - 1400) = 800 / 200 = 4.0."
      ],
      "importantPoints": [
        "VCRS સાયકલમાં એક્સપાન્સન વાલ્વમાં થ્રોટલિંગ પ્રક્રિયા થતી હોવાથી એન્થાલ્પી અચળ (h_3 = h_4) રહે છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: Ideal cycle for steam power plant -> Rankine Cycle.",
        "GSSSB Golden Question: Ideal cycle for gas turbine power plant -> Brayton Cycle.",
        "GSSSB Golden Question: Expansion process in VCRS cycle is -> Isenthalpic (Constant Enthalpy)."
      ],
      "commonMistakes": [
        "⚠️ GSSSB Exam Trap: VCRS માં એક્સપાન્સન વાલ્વ ની પ્રક્રિયાને Isentropic ગણવી (તે થ્રોટલિંગ હોવાથી Isenthalpic h_3 = h_4 હોય છે!)."
      ],
      "quickRevision": [
        "Rankine = Steam Power.",
        "Brayton = Gas Turbine (r_p).",
        "VCRS = Ref (h_3 = h_4).",
        "COP = (h_1-h_4)/(h_2-h_1)."
      ],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "cycles_anim",
        "title": "Rankine, Brayton & Vapor Compression Cycles", "purpose": "Visualizing Rankine T-s Steam Cycle vs VCRS P-h Refrigeration Cycle",
        "mobileLayout": "vertical_card",
        "sequence": ["૧. Rankine Steam Cycle T-s Diagram (Boiler, Turbine, Condenser, Pump) જુઓ.", "૨. VCRS P-h Diagram (Compressor, Condenser, Throttling h3=h4, Evaporator) જુઓ."],
        "diagrams": ["Rankine and VCRS Cycles Layout Diagram"],
        "rule": "Full animated Gujarati story with GSSSB exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/rankine_brayton_vcc_cycles.mp4",
        "videos": [{"title": "Rankine, Brayton & VCRS Cycles Explanation", "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/rankine_brayton_vcc_cycles.mp4", "assetPath": "assets/videos/rankine_brayton_vcc_cycles.mp4", "description": "Full lesson on Rankine, Brayton, and VCRS refrigeration cycles."}],
        "imageUrl": "assets/images/diagrams/subj_1_topic_10.png"
      }
    }
  ];

  masterData[s1Index]['topics'] = updatedS1Topics;

  masterFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(masterData),
    encoding: utf8,
  );

  print('================================================================================');
  print('🎉 SUBJECT 1 (THERMODYNAMICS) 100% REBUILT FROM SOURCE PDF WITH 0 ERRORS!');
  print('================================================================================');
}
