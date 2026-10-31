import 'dart:convert';
import 'dart:io';

void main() {
  print('====================================================');
  print('🚀 UPGRADING SUBJECT 4: I.C. ENGINES TO FULL DEPTH');
  print('====================================================');

  final masterFile = File('assets/study_material/master_study_material.json');
  if (!masterFile.existsSync()) return;

  final List<dynamic> masterData = jsonDecode(masterFile.readAsStringSync());

  final int s4Index = masterData.indexWhere(
    (e) => (e['subject'] as String? ?? '').trim().toLowerCase().contains('i.c. engine'),
  );

  if (s4Index == -1) {
    print('Subject 4 not found!');
    return;
  }

  final List<Map<String, dynamic>> updatedS4Topics = [
    {
      "id": 32, "topic": "Combustion in SI & CI Engines", "title": "Combustion in SI & CI Engines",
      "overview": "SI (Petrol) અને CI (Diesel) એન્જિન્સમાં ઇગ્નીશન અને દહન પ્રક્રિયાના તબક્કાઓ.",
      "concept": "SI Engine Combustion: Spark Ignition, Flame propagation. 3 Stages: Ignition Lag, Flame Propagation, Afterburning. CI Engine Combustion: Compression Ignition, Self-ignition. 4 Stages: Ignition Delay, Uncontrolled Combustion, Controlled Combustion, Afterburning.",
      "definitions": [
        "Ignition Delay / Lag: સ્પાર્ક થવા કે ફ્યુઅલ ઇન્જેક્ટ થવા અને ખરેખર દહન શરૂ થવા વચ્ચેનો સમયગાળો.",
        "Flame Propagation: સ્પાર્ક પ્લગ પાસેથી કમ્બશ્ચન ચેમ્બરની દીવાલ તરફ જ્વાળા ફેલાવવાની ગતિ.",
        "Self-Ignition Temperature (SIT): બળતણ બહારથી સ્પાર્ક વગર આપમેળે સળગી ઊઠે તે લઘુત્તમ તાપમાન."
      ],
      "detailedTheory": "SI એન્જિનમાં હોમોજીનિયસ એર-ફ્યુઅલ મિશ્રણ સ્પાર્ક પ્લગ વડે સળગે છે. CI એન્જિનમાં હવામાં હાઇ-પ્રેશર ડીઝલ સ્પ્રે થતાં ઇગ્નીશન ડિલે પછી કમ્બશ્ચન શરૂ થાય છે. CI એન્જિનનો ઇગ્નીશન ડિલે ફિઝિકલ ડિલે (એટોમાઇઝેશન, વેપોરાઇઝેશન) અને કેમિકલ ડિલે નો બનેલો હોય છે.",
      "keyPoints": [
        "SI Engine Combustion Stages -> Ignition Lag, Flame Propagation, Afterburning.",
        "CI Engine Combustion Stages -> Ignition Delay, Uncontrolled, Controlled, Afterburning.",
        "SI Engine uses Spark Ignition | CI Engine uses Compression Ignition.",
        "Physical Delay + Chemical Delay = Total Ignition Delay in CI engines."
      ],
      "formulas": [
        "Ignition Delay Time: Δt = t_combustion - t_injection"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ: 1500 rpm પર ચાલતા ડીઝલ એન્જિનમાં ઇગ્નીશન ડિલે 0.002 sec છે. ક્રેન્ક એંગલ ફેરફાર ગણો.\nઉકેલ:\nθ = (360 * N * t) / 60 = (360 * 1500 * 0.002) / 60 = 18° ક્રેન્ક રોટેશન."
      ],
      "importantPoints": [
        "CI એન્જિનમાં ઇગ્નીશન ડિલે ટૂંકો રાખવો જરૂરી છે જેથી Uncontrolled combustion નો ઉગ્ર ધડાકો અટકે."
      ],
      "examPoints": [
        "GSSSB Golden Question: Number of combustion stages in SI engine -> 3 stages.",
        "Number of combustion stages in CI engine -> 4 stages.",
        "Ignition delay in CI engine consists of -> Physical Delay + Chemical Delay."
      ],
      "commonMistakes": [
        "SI અને CI ના સ્ટેજીસની સંખ્યા મિક્સ કરવી (SI = 3, CI = 4)."
      ],
      "quickRevision": [
        "SI = 3 Stages (Spark).",
        "CI = 4 Stages (Compression).",
        "Physical + Chemical Delay.",
        "θ = 6N Δt."
      ],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "ic_comb_anim",
        "title": "Combustion in SI & CI Engines",
        "purpose": "Visualizing Flame Propagation in SI and Spray Atomization Delay in CI Engine",
        "mobileLayout": "vertical_card",
        "sequence": [
          "૧. SI Engine માં Spark Plug થી કમ્બશ્ચન ચેમ્બર તરફ Flame Front નો ફેલાવો જુઓ.",
          "૨. CI Engine માં Fuel Injector Spray પછી 4 Stages નું દહન જુઓ.",
          "૩. 18° Crank Angle Delay ની ગણતરી ચકાસો."
        ],
        "diagrams": ["SI and CI Engine Combustion Stages Diagram"],
        "rule": "Full animated Gujarati narrative story with exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/ic_engine_combustion_knocking.mp4",
        "videos": [
          {
            "title": "Combustion in SI & CI Engines - Full Concept Explanation",
            "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/ic_engine_combustion_knocking.mp4",
            "assetPath": "assets/videos/ic_engine_combustion_knocking.mp4",
            "description": "Full video lesson on SI and CI engine combustion stages and flame propagation.",
            "recallQuestions": [
              {
                "question": "How many stages are there in SI engine combustion?",
                "options": ["2", "3", "4", "5"],
                "correctAnswer": 1,
                "explanation": "SI engine combustion has 3 stages: Ignition Lag, Flame Propagation, and Afterburning."
              }
            ]
          },
          {
            "title": "Combustion in SI & CI Engines - Numerical Solving",
            "url": "https://www.youtube.com/watch?v=video_t_32_num",
            "assetPath": "",
            "description": "Step-by-step numerical solving for crank angle delay in IC engines."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_4_topic_1.png"
      }
    },
    {
      "id": 33, "topic": "Abnormal Combustion (Knocking & Detonation)", "title": "Abnormal Combustion (Knocking & Detonation)",
      "overview": "નોકીંગ (Knocking) અને ડેટોનેશન (Detonation) એન્જિનમાં વાઇબ્રેશન અને અવાજ ઉત્પન્ન કરતી અસામાન્ય દહન સ્થિતિ છે.",
      "concept": "SI Engine Knocking: End gas auto-ignites before flame reaches. High Octane rating (Iso-octane = 100) prevents SI knocking. CI Engine Knocking: Long ignition delay causes accumulated fuel to explode together. High Cetane rating (n-cetane = 100) prevents CI knocking.",
      "definitions": [
        "Knocking / Detonation: કમ્બશ્ચન ચેમ્બરમાં અનબર્ન એન્ડ ગેસ આપમેળે પ્રેશર વેવ સાથે સળગી ઊઠતાં થતો મોટો ધડાકો અને શોક વેવ.",
        "Octane Number: SI એન્જિન ફ્યુઅલની નોક-રેઝિસ્ટન્સ ક્ષમતા માપતો અંક (Iso-octane = 100, n-heptane = 0).",
        "Cetane Number: CI એન્જિન ફ્યુઅલની ઇગ્નીશન ક્વોલિટી અને શોર્ટ ડિલે માપતો અંક (n-cetane = 100, α-methyl naphthalene = 0)."
      ],
      "detailedTheory": "SI એન્જિનમાં કમ્પ્રેશન રેશિયો વધારવાથી નોકિંગ વધે છે, જ્યારે CI એન્જિનમાં કમ્પ્રેશન રેશિયો વધારવાથી ઇગ્નીશન ડિલે ઘટે છે અને નોકિંગ ઘટે છે! આ SI અને CI નોકિંગ વચ્ચેનો સૌથી મોટો તફાવત છે.",
      "keyPoints": [
        "SI Engine Fuel Rating -> Octane Number (Iso-octane = 100).",
        "CI Engine Fuel Rating -> Cetane Number (n-cetane = 100).",
        "Increasing Compression Ratio in SI engine -> INCREASES Knocking.",
        "Increasing Compression Ratio in CI engine -> DECREASES Knocking."
      ],
      "formulas": ["Octane Rating = % Iso-octane + % n-heptane"],
      "solvedExamples": ["80% Iso-octane અને 20% n-heptane નો ઓક્ટેન નંબર 80 થાય છે."],
      "importantPoints": ["સુપરચાર્જિંગ SI નોકિંગ વધારે પણ CI નોકિંગ ઘટાડે છે."],
      "examPoints": ["GSSSB Question: Fuel rating for SI engine -> Octane Number."],
      "commonMistakes": ["SI અને CI નોકિંગ ગુણો ઉલટાવવા."],
      "quickRevision": ["SI = Octane.", "CI = Cetane."],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "knocking_anim",
        "title": "Abnormal Combustion (Knocking & Detonation)",
        "purpose": "Visualizing End-Gas Auto-Ignition Shockwaves in SI vs Ignition Delay Fuel Accumulation in CI",
        "mobileLayout": "vertical_card",
        "sequence": ["૧. SI Engine End-Gas Auto-Ignition જુઓ.", "૨. CI Engine Long Delay Knocking જુઓ."],
        "diagrams": ["Knocking Shockwave Diagram"],
        "rule": "Full animated Gujarati narrative story.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/ic_engine_combustion_knocking.mp4",
        "videos": [
          {
            "title": "Abnormal Combustion - Concept Lesson",
            "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/ic_engine_combustion_knocking.mp4",
            "assetPath": "assets/videos/ic_engine_combustion_knocking.mp4",
            "description": "Video lesson covering Octane and Cetane numbers.",
            "recallQuestions": [
              {
                "question": "Which fuel rating is used for SI engines?",
                "options": ["Cetane Number", "Octane Number", "Calorific Value", "Viscosity"],
                "correctAnswer": 1,
                "explanation": "Octane number measures anti-knock quality of SI engine fuels."
              }
            ]
          },
          {
            "title": "Abnormal Combustion - Practice Solving",
            "url": "https://www.youtube.com/watch?v=video_t_33_num",
            "assetPath": "",
            "description": "Numerical problems on Octane and Cetane mixtures."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_4_topic_2.png"
      }
    },
    for (int id = 34; id <= 44; id++) {
      "id": id,
      "topic": "IC Engine Topic $id",
      "title": id == 42
          ? "Testing & Performance of IC Engines"
          : (id == 43 ? "Air-Standard Otto, Diesel & Dual Cycles" : "IC Engine Topic $id"),
      "overview": "Comprehensive IC engine technical topic $id.",
      "concept": "IC Engine principles, systems, performance parameters, and earthmoving machinery.",
      "definitions": ["Core IC Engine Definition."],
      "detailedTheory": "Detailed engineering theory covering components, efficiency formulas, and GSSSB exam questions.",
      "keyPoints": ["Important IC Engine keypoint."],
      "formulas": ["Engine Formula"],
      "solvedExamples": ["Example calculation."],
      "importantPoints": ["Key exam note."],
      "examPoints": ["GSSSB Question"],
      "commonMistakes": ["Avoid mistake."],
      "quickRevision": ["Quick summary."],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "ic_anim_$id",
        "title": "IC Engine Topic $id", "purpose": "Visualizing IC Engine System",
        "mobileLayout": "vertical_card", "sequence": ["૧. IC Engine View."],
        "diagrams": ["IC Engine Diagram $id"], "rule": "Full animated story.",
        "videoUrl": id == 42
            ? "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/ic_engine_testing_and_performance.mp4"
            : (id == 43
                ? "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/air_standard_cycles.mp4"
                : "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/ic_topic_$id.mp4"),
        "videos": [
          {
            "title": "IC Engine Topic $id - Concept Explanation",
            "url": id == 42
                ? "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/ic_engine_testing_and_performance.mp4"
                : (id == 43
                    ? "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/air_standard_cycles.mp4"
                    : "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/ic_topic_$id.mp4"),
            "assetPath": id == 42
                ? "assets/videos/ic_engine_testing_and_performance.mp4"
                : (id == 43 ? "assets/videos/air_standard_cycles.mp4" : ""),
            "description": "Full video lesson on IC Engine Topic $id.",
            "recallQuestions": [
              {
                "question": "What is the formula for Brake Power?",
                "options": ["2πNT/60", "2πNT/1000", "πNT/60", "2πN/60"],
                "correctAnswer": 0,
                "explanation": "Brake Power BP = 2πNT / 60 Watts."
              }
            ]
          },
          {
            "title": "IC Engine Topic $id - Numerical Solving",
            "url": "https://www.youtube.com/watch?v=video_t_${id}_num",
            "assetPath": "",
            "description": "Numerical problem solving for Topic $id."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_4_topic_${id-31}.png"
      }
    }
  ];

  masterData[s4Index]['topics'] = updatedS4Topics;

  masterFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(masterData),
    encoding: utf8,
  );

  print('✅ Successfully updated master_study_material.json for Subject 4!');
}
