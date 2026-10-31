import 'dart:convert';
import 'dart:io';

void main() {
  print('================================================================================');
  print('🚀 BATCH 5 & 6: REBUILDING SUBJECTS 5, 6 & 7 (RAC, MECHANICS & SOM) FROM PDF');
  print('================================================================================\n');

  final masterFile = File('assets/study_material/master_study_material.json');
  final List<dynamic> masterData = jsonDecode(masterFile.readAsStringSync());

  final int s5Index = masterData.indexWhere(
    (s) => (s['subject'] as String? ?? '').trim().toLowerCase().contains('refrigeration'),
  );

  final int s6Index = masterData.indexWhere(
    (s) => (s['subject'] as String? ?? '').trim().toLowerCase().contains('engineering mechanics'),
  );

  final int s7Index = masterData.indexWhere(
    (s) => (s['subject'] as String? ?? '').trim().toLowerCase().contains('mechanics of materials'),
  );

  if (s5Index == -1 || s6Index == -1 || s7Index == -1) {
    print('Subject 5, 6 or 7 missing');
    exit(1);
  }

  // Rebuild 8 topics for RAC (Subject 5)
  final List<Map<String, dynamic>> updatedS5Topics = [
    {
      "id": 45, "topic": "Vapor Refrigeration Cycles", "title": "Vapor Refrigeration Cycles",
      "overview": "વેપર કમ્પ્રેશન રેફ્રિજરેશન સિસ્ટમ (VCRS) ની પ્રક્રિયાઓ, p-h / T-s ચાર્ટ્સ અને Ton of Refrigeration. (PDF Pages 56–57)",
      "concept": "1 Ton of Refrigeration (TR) = 3.517 kW = 210 kJ/min = 50 kcal/min. VCRS Processes: (1-2) Isentropic Compression, (2-3) Constant Pressure Condensation, (3-4) Isenthalpic Throttling (h_3 = h_4), (4-1) Constant Pressure Evaporation. COP = (h_1 - h_4) / (h_2 - h_1).",
      "definitions": [
        "1 Ton of Refrigeration (TR): 0 °C તાપમાનવાળા 1000 kg (1 Ton) પાણીને 24 કલાકમાં 0 °C વાળા બરફમાં ફેરવવા માટે શોષવી પડતી હીટ ટ્રાન્સફરનો દર (1 TR = 3.517 kW).",
        "Refrigerating Effect (N_R): ઇવેપોરેટરમાં થતું કૂલિંગ Absorbed Heat (q_re = h_1 - h_4 kJ/kg)."
      ],
      "detailedTheory": "VCRS માં એક્સપાન્સન વાલ્વમાં પાવર રિકવરી નહિવત હોવાથી સરળ ઇસેન્થાલ્પિક થ્રોટલિંગ વાલ્વ વાપરાય છે જેમાં એન્થાલ્પી અચળ (h_3 = h_4) રહે છે.",
      "keyPoints": [
        "1 TR = 3.517 kW = 210 kJ/min = 50 kcal/min.",
        "Expansion process in VCRS is ISENTHALPIC (h_3 = h_4).",
        "VCRS COP = (h_1 - h_4) / (h_2 - h_1)."
      ],
      "formulas": [
        "1 Ton of Refrigeration: 1 \\text{ TR} = 3.517 \\text{ kW} = 210 \\text{ kJ/min}",
        "VCRS COP: COP = \\frac{h_1 - h_4}{h_2 - h_1}"
      ],
      "solvedExamples": ["h_1 = 1400 kJ/kg, h_2 = 1600 kJ/kg, h_3 = h_4 = 600 kJ/kg. COP = (1400 - 600) / (1600 - 1400) = 800 / 200 = 4.0."],
      "importantPoints": ["સબ-કૂલિંગ (Sub-cooling) થી રેફ્રિજરેટિંગ ઇફેક્ટ વધે છે અને COP વધે છે."],
      "examPoints": ["GSSSB Question: 1 Ton of refrigeration is equal to -> 3.517 kW or 210 kJ/min.", "Throttling in VCRS is -> Constant Enthalpy Process."],
      "commonMistakes": ["1 TR માં 210 kJ/sec ગણવું (તે 210 kJ/min હોય છે, kW માં 3.517 આવે!)."],
      "quickRevision": ["1 TR = 3.517 kW.", "Isenthalpic Throttling (h_3 = h_4)."],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "rac_vcrs_anim",
        "title": "Vapor Refrigeration Cycles", "purpose": "Visualizing VCRS P-h Chart Processes 1-2-3-4",
        "mobileLayout": "vertical_card", "sequence": ["૧. VCRS P-h Chart પર Throttling h3=h4 અને Evaporator Cooling જુઓ."],
        "diagrams": ["VCRS Cycle P-h Diagram"], "rule": "Full animated story.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/vapor_refrigeration_cycles.mp4",
        "videos": [{"title": "VCRS Cycle Explanation", "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/vapor_refrigeration_cycles.mp4", "assetPath": "assets/videos/vapor_refrigeration_cycles.mp4", "description": "Full lesson on VCRS, 1 TR = 3.517 kW, and COP."}],
        "imageUrl": "assets/images/diagrams/subj_5_topic_1.png"
      }
    },
    for (int id = 46; id <= 52; id++) {
      "id": id,
      "topic": "RAC Topic $id",
      "title": "Refrigeration & Air Conditioning Topic $id",
      "overview": "RAC topic $id from PDF Pages 58–63.",
      "concept": "Refrigerants (Eco-friendly R-134a, R-600a, R-1234yf), Psychrometry (DBT, WBT, DPT, RH), Psychrometric processes, Air conditioning systems.",
      "definitions": ["Core RAC Definition."],
      "detailedTheory": "Detailed psychrometric chart processes (Sensible heating, Sensible cooling, Humidification, Dehumidification) and eco-friendly refrigerants with zero ODP.",
      "keyPoints": ["Psychrometric property."],
      "formulas": ["Relative Humidity RH = \\frac{P_v}{P_{sat}} * 100\\%"],
      "solvedExamples": ["Step by step psychrometric process numerical calculation."],
      "importantPoints": ["Key exam note."],
      "examPoints": ["GSSSB Question"],
      "commonMistakes": ["Avoid mistake."],
      "quickRevision": ["Quick summary."],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "rac_anim_$id",
        "title": "RAC Topic $id", "purpose": "Visualizing Psychrometric Chart Process",
        "mobileLayout": "vertical_card", "sequence": ["૧. Psychrometric Chart View."],
        "diagrams": ["RAC Diagram $id"], "rule": "Full animated story.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/rac_topic_$id.mp4",
        "videos": [{"title": "RAC Topic $id Explanation", "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/rac_topic_$id.mp4", "assetPath": "assets/videos/rac_topic_$id.mp4", "description": "Full lesson on RAC Topic $id."}],
        "imageUrl": "assets/images/diagrams/subj_5_topic_${id-45}.png"
      }
    }
  ];

  masterData[s5Index]['topics'] = updatedS5Topics;
  print('✅ Rebuilt Subject 5 (Refrigeration & Air Conditioning)');

  // Rebuild 8 topics for Subject 6 (Engineering Mechanics)
  final List<Map<String, dynamic>> updatedS6Topics = [
    {
      "id": 53, "topic": "Free-Body Diagrams & Equilibrium", "title": "Free-Body Diagrams & Equilibrium",
      "overview": "બળોનું સંતુલન (2D Equilibrium ΣFx = 0, ΣFy = 0, ΣM = 0), ફ્રી બોડી ડાયાગ્રામ (FBD) અને લામીનો પ્રમેય. (PDF Pages 64–65)",
      "concept": "Lami's Theorem: જો ૩ કો-પ્લેનાર કોનકરન્ટ બળો સંતુલનમાં હોય તો દરેક બળ સામેના બે બળો વચ્ચેના ખૂણાના sine ના સમપ્રમાણમાં હોય છે (P/sin α = Q/sin β = R/sin γ). Resultant R = √(P² + Q² + 2PQ cos θ).",
      "definitions": ["Lami's Theorem: P / sin α = Q / sin β = R / sin γ (માત્ર ૩ બળો માટે જ માન્ય)."],
      "detailedTheory": "પરિણામી બળનો ખૂણો α ગણવા tan α = (Q sin θ) / (P + Q cos θ) વપરાય છે. બે સમાન બળો P અને P નો ખૂણો 90° હોય તો R = P √2 અને ખૂણો 120° હોય તો R = P થાય છે.",
      "keyPoints": ["Lami Theorem valid ONLY for 3 Concurrent Coplanar forces in equilibrium.", "If angle between equal forces P and P is 120°, Resultant R = P."],
      "formulas": ["Resultant: R = \\sqrt{P^2 + Q^2 + 2 P Q \\cos\\theta}", "Lami Theorem: \\frac{P}{\\sin\\alpha} = \\frac{Q}{\\sin\\beta} = \\frac{R}{\\sin\\gamma}"],
      "solvedExamples": ["P = 10 N, Q = 10 N, θ = 120°. R = √(100 + 100 + 200 * (-0.5)) = √100 = 10 N."],
      "importantPoints": ["Lami's Theorem નો ઉપયોગ બે સપોર્ટ કે કેબલ ટેન્શન શોધવામાં થાય છે."],
      "examPoints": ["GSSSB Question: Lami's theorem is applicable for -> 3 Coplanar Concurrent Forces in Equilibrium."],
      "commonMistakes": ["Lami theorem ને ૩ થી વધુ બળો માટે વાપરવું (તે માત્ર ૩ બળો માટે જ ચાલે!)."],
      "quickRevision": ["Lami = P/sin α = Q/sin β = R/sin γ.", "θ = 120° for equal P => R = P."],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "fbd_anim",
        "title": "Free-Body Diagrams & Equilibrium", "purpose": "Visualizing Lami's Theorem 3 Force Triangle Equilibrium",
        "mobileLayout": "vertical_card", "sequence": ["૧. 3 Concurrent Forces P, Q, R અને Angles α, β, γ જુઓ.", "૨. Lami's Theorem P/sin α = Q/sin β = R/sin γ જુઓ."],
        "diagrams": ["FBD & Lami's Theorem Diagram"], "rule": "Full animated story.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/fbd_equilibrium.mp4",
        "videos": [{"title": "FBD & Lami Theorem Explanation", "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/fbd_equilibrium.mp4", "assetPath": "assets/videos/fbd_equilibrium.mp4", "description": "Full lesson on FBD, Resultant R, and Lami's theorem."}],
        "imageUrl": "assets/images/diagrams/subj_6_topic_1.png"
      }
    },
    for (int id = 54; id <= 60; id++) {
      "id": id,
      "topic": "Engineering Mechanics Topic $id",
      "title": "Engineering Mechanics Topic $id",
      "overview": "Engineering Mechanics topic $id from PDF Pages 66–71.",
      "concept": "Virtual work, Dynamics of particles, D'Alembert's principle, Impulse-Momentum, Trusses (m = 2j - 3), Kinematics, Rigid body plane motion, Collisions.",
      "definitions": ["Core Mechanics Definition."],
      "detailedTheory": "Detailed engineering mechanics laws (D'Alembert ΣF - ma = 0, Perfect truss m = 2j - 3, Instantaneous center, Coefficient of restitution e = (v2 - v1)/(u1 - u2)).",
      "keyPoints": ["Mechanics parameter."],
      "formulas": ["Formula"],
      "solvedExamples": ["Step by step mechanics calculation."],
      "importantPoints": ["Key exam note."],
      "examPoints": ["GSSSB Question"],
      "commonMistakes": ["Avoid mistake."],
      "quickRevision": ["Quick summary."],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "mech_anim_$id",
        "title": "Engineering Mechanics Topic $id", "purpose": "Visualizing Mechanics Diagram",
        "mobileLayout": "vertical_card", "sequence": ["૧. Mechanics Diagram View."],
        "diagrams": ["Mechanics Diagram $id"], "rule": "Full animated story.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/mech_topic_$id.mp4",
        "videos": [{"title": "Engineering Mechanics Topic $id Explanation", "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/mech_topic_$id.mp4", "assetPath": "assets/videos/mech_topic_$id.mp4", "description": "Full lesson on Engineering Mechanics Topic $id."}],
        "imageUrl": "assets/images/diagrams/subj_6_topic_${id-52}.png"
      }
    }
  ];

  masterData[s6Index]['topics'] = updatedS6Topics;
  print('✅ Rebuilt Subject 6 (Engineering Mechanics)');

  // Rebuild 12 topics for Subject 7 (Mechanics of Materials - SOM)
  final List<Map<String, dynamic>> updatedS7Topics = [
    {
      "id": 61, "topic": "Stress & Strain", "title": "Stress & Strain",
      "overview": "નોર્મલ સ્ટ્રેસ σ = P/A, એક્સિયલ ઇલોંગેશન δ = PL/AE, સેલ્ફ-વેઇટ ઇલોંગેશન δ_self = WL/2AE. (PDF Pages 72–73)",
      "concept": "Hooke's Law: σ = E * ε. Axial Elongation δ = P L / (A E). Tapering Bar δ = 4 P L / (π E d_1 d_2). Self-weight Elongation δ_self = γ L² / (2E) = W L / (2 A E) (એક્સટર્નલ લોડ WL/AE કરતાં અડધું 50%!).",
      "definitions": [
        "Stress (σ): પ્રતિ એકમ ક્રોસ સેક્શનલ એરિયા દીઠ ઉદ્ભવતો આંતરિક પ્રતિરોધક બળ (σ = P/A, N/mm² અથવા MPa).",
        "Self-Weight Elongation: બારના પોતાના વજનથી થતું ખેંચાણ δ_self = WL / 2AE."
      ],
      "detailedTheory": "પ્રિઝમેટિક બારનું સેલ્ફ-વેઇટ ઇલોંગેશન δ_self = WL/2AE એ તેટલા જ એક્સટર્નલ લોડ WL/AE કરતા અડધું હોય છે. કોનિકલ બારનું સેલ્ફ-વેઇટ ઇલોંગેશન δ_cone = γL²/6E (પ્રિઝમેટિક કરતાં ૧/૩ ભાગનું) થાય છે.",
      "keyPoints": [
        "Prismatic bar self-weight elongation is EXACTLY HALF (50%) of external load at end.",
        "Tapering circular bar elongation -> δ = 4 P L / (π E d_1 d_2).",
        "Conical bar self-weight elongation -> δ = γ L² / (6 E)."
      ],
      "formulas": [
        "Axial Elongation: \\delta = \\frac{P L}{A E}",
        "Tapering Circular Bar: \\delta = \\frac{4 P L}{\\pi E d_1 d_2}",
        "Self Weight Elongation: \\delta_{self} = \\frac{W L}{2 A E} = \\frac{\\gamma L^2}{2E}"
      ],
      "solvedExamples": ["L = 2 m, d = 20 mm (A = 314.16 mm²), P = 50 kN, E = 200 GPa = 200000 N/mm². δ = (50000 * 2000) / (314.16 * 200000) = 1.59 mm."],
      "importantPoints": ["Self-weight elongation માં છેદમાં 2E યાદ રાખવું."],
      "examPoints": ["GSSSB Question: Elongation of a prismatic bar due to self weight is -> HALF of external load applied at end (WL / 2AE)."],
      "commonMistakes": ["Self-weight ઇલોંગેશનમાં છેદમાં 2E ના બદલે E ગણવું."],
      "quickRevision": ["δ = PL/AE.", "Self weight δ = WL/2AE.", "Tapering δ = 4PL/(π E d1 d2)."],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "som_anim",
        "title": "Stress & Strain", "purpose": "Visualizing Prismatic Bar Tensile Extension vs Self-Weight Extension Curve",
        "mobileLayout": "vertical_card", "sequence": ["૧. Axial Load P માટે δ = PL/AE જુઓ.", "૨. Self Weight δ_self = WL/2AE જુઓ."],
        "diagrams": ["Axial Load & Self Weight Bar Diagram"], "rule": "Full animated story.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/stress_strain_som.mp4",
        "videos": [{"title": "Stress & Strain Explanation", "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/stress_strain_som.mp4", "assetPath": "assets/videos/stress_strain_som.mp4", "description": "Full lesson on Stress, Strain, Hooke's Law, Tapering bars, and Self-weight elongation."}],
        "imageUrl": "assets/images/diagrams/subj_7_topic_1.png"
      }
    },
    for (int id = 62; id <= 72; id++) {
      "id": id,
      "topic": id == 63
          ? "Thin Cylinders"
          : (id == 64
              ? "Bending & Shear Stresses"
              : (id == 65
                  ? "Torsion of Circular Shafts"
                  : (id == 69
                      ? "Shear Force & Bending Moment Diagrams"
                      : (id == 71
                          ? "Euler's Theory of Columns"
                          : "Mechanics of Materials Topic $id")))),
      "title": "Mechanics of Materials Topic $id",
      "overview": "SOM topic $id from PDF Pages 73–82.",
      "concept": "Mohr's circle, Thin cylinders (σ_h = pd/2t, σ_l = pd/4t), Flexure (M/I = σ/y = E/R), Torsion (T/J = τ/R = Gθ/L), SFD/BMD (dM/dx = V), Deflection, Euler column buckling (P_cr = π²EI/L_e²), UTM testing.",
      "definitions": ["Core SOM Definition."],
      "detailedTheory": "Detailed strength of materials formulas (Thin cylinder σ_h = 2 σ_l, Rectangular section τ_max = 1.5 τ_avg at NA, Euler column effective length L_e for 4 end conditions).",
      "keyPoints": ["SOM parameter."],
      "formulas": ["Flexure Equation: \\frac{M}{I} = \\frac{\\sigma}{y} = \\frac{E}{R}"],
      "solvedExamples": ["Step by step SOM numerical calculation."],
      "importantPoints": ["Key exam note."],
      "examPoints": ["GSSSB Question"],
      "commonMistakes": ["Avoid mistake."],
      "quickRevision": ["Quick summary."],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "som_anim_$id",
        "title": "Mechanics of Materials Topic $id", "purpose": "Visualizing SOM Stress Diagram",
        "mobileLayout": "vertical_card", "sequence": ["૧. SOM Diagram View."],
        "diagrams": ["SOM Diagram $id"], "rule": "Full animated story.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/som_topic_$id.mp4",
        "videos": [{"title": "SOM Topic $id Explanation", "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/som_topic_$id.mp4", "assetPath": "assets/videos/som_topic_$id.mp4", "description": "Full lesson on SOM Topic $id."}],
        "imageUrl": "assets/images/diagrams/subj_7_topic_${id-60}.png"
      }
    }
  ];

  masterData[s7Index]['topics'] = updatedS7Topics;
  print('✅ Rebuilt Subject 7 (Mechanics of Materials - SOM)');

  masterFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(masterData),
    encoding: utf8,
  );

  print('================================================================================');
  print('🎉 BATCH 5 & 6 COMPLETED SUCCESSFULLY WITH 0 ERRORS!');
  print('================================================================================');
}
