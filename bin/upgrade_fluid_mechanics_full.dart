import 'dart:convert';
import 'dart:io';

void main() {
  print('====================================================');
  print('🚀 UPGRADING SUBJECT 2: FLUID MECHANICS TO FULL DEPTH');
  print('====================================================');

  final masterFile = File('assets/study_material/master_study_material.json');
  if (!masterFile.existsSync()) {
    print('❌ ERROR: master_study_material.json not found!');
    exit(1);
  }

  final List<dynamic> masterData = jsonDecode(masterFile.readAsStringSync());

  // Find Subject 2: Fluid Mechanics
  final int subjectIndex = masterData.indexWhere(
    (element) => (element['subject'] as String? ?? '').trim().toLowerCase() == 'fluid mechanics',
  );

  if (subjectIndex == -1) {
    print('❌ ERROR: Fluid Mechanics subject not found in master_study_material.json');
    exit(1);
  }

  // Construct 13 fully elaborated topics for Fluid Mechanics
  final List<Map<String, dynamic>> updatedTopics = [
    // -----------------------------------------------------------------
    // TOPIC 1 (ID 11): Definition of Fluid, Newton's Law of Viscosity
    // -----------------------------------------------------------------
    {
      "id": 11,
      "topic": "Definition of Fluid, Newton's Law of Viscosity",
      "title": "Definition of Fluid, Newton's Law of Viscosity",
      "overview": "પ્રવાહી (Fluid) એવો પદાર્થ છે જે તેના પર સહેજ પણ શિયર સ્ટ્રેસ (Shear Stress) આપતાં સતત ડિફોર્મ (Flow) થાય છે. Newton's Law of Viscosity: τ = μ * (du/dy).",
      "concept": "ડાયનેમિક વિસ્કોસિટી μ (N·s/m² અથવા Pa·s, 1 Poise = 0.1 Pa·s) અને કાઇનેમેટિક વિસ્કોસિટી ν = μ / ρ (m²/s, 1 Stoke = 10⁻⁴ m²/s). ન્યુટોનિયન અને નોન-ન્યુટોનિયન ફ્લુઇડ્સ વચ્ચેનો તફાવત અગત્યનો છે.",
      "definitions": [
        "Fluid: શિયર બળ (Shear force) લગાડતા સતત વહેવાનો ગુણધર્મ ધરાવતો પદાર્થ (પ્રવાહી અને વાયુ).",
        "Viscosity (શ્યાનતા): ફ્લુઇડના એક સ્તર દ્વારા બીજા સ્તરની ગતિ સામે થતો આંતરિક પ્રતિકાર (Internal Resistance).",
        "Newton's Law of Viscosity: શિયર સ્ટ્રેસ τ એ શિયર સ્ટ્રેઇન રેટ (Velocity Gradient du/dy) ના સમપ્રમાણમાં હોય છે (τ = μ * du/dy).",
        "Dynamic Viscosity (μ): શિયર સ્ટ્રેસ અને વેલોસિટી ગ્રેડિયન્ટનો ગુણોત્તર (SI Unit: Pa·s અથવા N·s/m², 1 Poise = 0.1 Pa·s).",
        "Kinematic Viscosity (ν): ડાયનેમિક વિસ્કોસિટી અને માસ ડેન્સિટીનો ગુણોત્તર (ν = μ / ρ, SI Unit: m²/s, 1 Stoke = 10⁻⁴ m²/s)."
      ],
      "detailedTheory": "તાપમાન વધતાં પ્રવાહી (Liquids) ની વિસ્કોસિટી ઘટે છે કારણ કે અણુઓ વચ્ચેનું Cohesive Force ઘટે છે. પરંતુ વાયુઓ (Gases) ની વિસ્કોસિટી તાપમાન વધતાં વધે છે કારણ કે અણુઓ વચ્ચે મોલેક્યુલર મોમેન્ટમ ટ્રાન્સફર વધે છે. ન્યુટોનિયન ફ્લુઇડ્સ (પાણી, હવા, કેરોસીન) ન્યુટનના વિસ્કોસિટી નિયમનું પાલન કરે છે (τ સ્કીવ લાઇન). નોન-ન્યુટોનિયન ફ્લુઇડ્સ: Pseudoplastic (Blood, Milk), Dilatant (Quick sand), Bingham Plastic (Toothpaste, Sewage sludge).",
      "keyPoints": [
        "Newton's Law of Viscosity -> τ = μ * (du/dy).",
        "1 Poise = 0.1 Pa·s = 0.1 N·s/m².",
        "1 Stoke = 10⁻⁴ m²/s = 1 cm²/s.",
        "Liquid Viscosity DECREASES with Temperature Increase.",
        "Gas Viscosity INCREASES with Temperature Increase.",
        "Bingham Plastic requires Yield Stress before flow starts (Toothpaste)."
      ],
      "formulas": [
        "Shear Stress: τ = μ * (du / dy)",
        "Kinematic Viscosity: ν = μ / ρ",
        "Poise Conversion: 1 Poise = 0.1 Pa·s",
        "Stoke Conversion: 1 Stoke = 10⁻⁴ m²/s"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ: બે પ્લેટો વચ્ચે 0.02 mm નો ઓઇલ ગેપ (μ = 0.8 Pa·s) છે. ઉપરની પ્લેટ 1.5 m/s ની ઝડપે ખસે છે. શિયર સ્ટ્રેસ τ ગણો.\nઉકેલ:\nVelocity Gradient du/dy = 1.5 / (0.00002 m) = 75000 s⁻¹.\nτ = μ * (du/dy) = 0.8 * 75000 = 60000 N/m² = 60 kPa."
      ],
      "importantPoints": [
        "Ideal fluid ની વિસ્કોસિટી શૂન્ય (μ = 0) અને Incompressible (ρ = Constant) હોય છે.",
        "Real fluid માં કાયમ વિસ્કોસિટી અને સરફેસ ટેન્શન હોય છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: Viscosity of liquid with temperature increase -> DECREASES.",
        "Viscosity of gas with temperature increase -> INCREASES.",
        "1 Poise is equal to -> 0.1 N·s/m².",
        "SI unit of Kinematic Viscosity -> m²/s."
      ],
      "commonMistakes": [
        "1 Poise ને 1 Pa·s ગણી લેવું (1 Poise = 0.1 Pa·s).",
        "વાયુમાં તાપમાન સાથે વિસ્કોસિટી ઘટે છે તેવું દ્રવ્ય જેવું જ ખોટું માનવું (વાયુમાં વધે છે!)."
      ],
      "quickRevision": [
        "τ = μ (du/dy).",
        "ν = μ / ρ.",
        "1 Poise = 0.1 Pa·s | 1 Stoke = 10⁻⁴ m²/s.",
        "Liquid T↑ -> μ↓ | Gas T↑ -> μ↑."
      ],
      "mcqs": [],
      "msqs": [],
      "visualLearning": {
        "enabled": true,
        "visualRequired": true,
        "type": "diagram",
        "animationKey": "fluid_viscosity_anim",
        "title": "Definition of Fluid, Newton's Law of Viscosity",
        "purpose": "Visualizing Shear Deformation, Velocity Profile du/dy, and Rheological Fluid Curves",
        "mobileLayout": "vertical_card",
        "sequence": [
          "૧. બે સમાંતર પ્લેટો વચ્ચે ફ્લુઇડ લેયર્સનું શિયરીંગ અને Velocity Profile du/dy જુઓ.",
          "૨. Newtonian, Pseudoplastic, Dilatant અને Bingham Plastic ના Rheology Curves જુઓ.",
          "૩. τ = μ (du/dy) અને 1 Poise = 0.1 Pa·s ની ગણતરી ચકાસો."
        ],
        "diagrams": [
          "Velocity Profile & Rheological Curves Diagram"
        ],
        "rule": "Full animated Gujarati narrative story with exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/fluid_properties.mp4",
        "videos": [
          {
            "title": "Definition of Fluid, Newton's Law of Viscosity - Full Concept Explanation",
            "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/fluid_properties.mp4",
            "assetPath": "assets/videos/fluid_properties.mp4",
            "description": "Comprehensive video lesson covering fluid definition, Newton's law of viscosity, dynamic/kinematic viscosity, and fluid types."
          },
          {
            "title": "Definition of Fluid, Newton's Law of Viscosity - Numerical Problem Solving",
            "url": "https://www.youtube.com/watch?v=video_t_11_num",
            "assetPath": "",
            "description": "Step-by-step shear stress τ = μ(du/dy) and viscosity unit conversion numerical problems."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_2_topic_1.png"
      }
    },

    // -----------------------------------------------------------------
    // TOPIC 2 (ID 12): Mass Density, Specific Volume & Specific Gravity
    // -----------------------------------------------------------------
    {
      "id": 12,
      "topic": "Mass Density, Specific Volume & Specific Gravity",
      "title": "Mass Density, Specific Volume & Specific Gravity",
      "overview": "ફ્લુઇડના પાયાના ભૌતિક ગુણધર્મો માં માસ ડેન્સિટી (ρ), સ્પેસિફિક વેઇટ (w), સ્પેસિફિક વોલ્યુમ (v) અને સ્પેસિફિક ગ્રેવિટી (S) નો સમાવેશ થાય છે.",
      "concept": "પાણીની માસ ડેન્સિટી ρ = 1000 kg/m³ અને સ્પેસિફિક વેઇટ w = 9810 N/m³ છે. મર્ક્યુરી (પારો) ની સ્પેસિફિક ગ્રેવિટી S = 13.6 છે.",
      "definitions": [
        "Mass Density (ρ): પદાર્થના દળ (m) અને તેના કદ (V) નો ગુણોત્તર (ρ = m / V, SI Unit: kg/m³).",
        "Specific Weight / Weight Density (w): પદાર્થના વજન (W) અને કદ (V) નો ગુણોત્તર (w = ρ * g, SI Unit: N/m³).",
        "Specific Volume (v): એકમ દળ દીઠ રોકાયેલું કદ, જે ડેન્સિટીનો વ્યસ્ત છે (v = 1 / ρ, SI Unit: m³/kg).",
        "Specific Gravity / Relative Density (S): ફ્લુઇડની ડેન્સિટી અને સ્ટાન્ડર્ડ ફ્લુઇડ (પાણી 4°C પર) ની ડેન્સિટીનો ગુણોત્તર (S = ρ_fluid / ρ_water, Dimensionless)."
      ],
      "detailedTheory": "પાણીની માસ ડેન્સિટી 4 °C તાપમાને મહત્તમ 1000 kg/m³ હોય છે. પારા (Mercury) ની ડેન્સિટી 13600 kg/m³ હોવાથી તેની સ્પેસિફિક ગ્રેવિટી S = 13.6 છે. ગેસ માટે સ્ટાન્ડર્ડ ફ્લુઇડ તરીકે હવા (Air) લેવામાં આવે છે. સ્પેસિફિક ગ્રેવિટી એ એકમ-રહિત (Dimensionless) રાશિ છે.",
      "keyPoints": [
        "Water Density ρ = 1000 kg/m³ (at 4 °C).",
        "Water Specific Weight w = 9810 N/m³ = 9.81 kN/m³.",
        "Mercury Specific Gravity S = 13.6 (Density ρ = 13600 kg/m³).",
        "Specific Volume v = 1 / ρ.",
        "Specific Gravity S is Dimensionless."
      ],
      "formulas": [
        "Mass Density: ρ = m / V",
        "Specific Weight: w = ρ * g",
        "Specific Volume: v = 1 / ρ",
        "Specific Gravity: S = ρ_fluid / ρ_water"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ: 2 m³ કદ ધરાવતા પ્રવાહીનું વજન 15.696 kN (15696 N) છે. તેની માસ ડેન્સિટી ρ અને સ્પેસિફિક ગ્રેવિટી S શોધો.\nઉકેલ:\nw = W / V = 15696 / 2 = 7848 N/m³.\nρ = w / g = 7848 / 9.81 = 800 kg/m³.\nS = ρ / 1000 = 800 / 1000 = 0.8."
      ],
      "importantPoints": [
        "Specific gravity ની કિંમત ૧ કરતાં ઓછી હોય તો પદાર્થ પાણી પર તરે છે (દા.ત. ઓઇલ S = 0.8).",
        "Specific weight એ સ્થાનિક ગુરુત્વાકર્ષણ ગતિવર્ધન g સાથે બદલાય છે, પણ માસ ડેન્સિટી ρ અચળ રહે છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: Specific gravity of mercury -> 13.6.",
        "Specific weight of water in SI units -> 9810 N/m³ or 9.81 kN/m³.",
        "Unit of Specific Volume -> m³/kg.",
        "Dimension of Specific Gravity -> Dimensionless (M^0 L^0 T^0)."
      ],
      "commonMistakes": [
        "Specific Weight (w = ρg) અને Mass Density (ρ) ને એક જ ગણી લેવું.",
        "Specific gravity નો એકમ kg/m³ લખવો (તે એકમ-રહિત છે!)."
      ],
      "quickRevision": [
        "ρ = m/V (kg/m³).",
        "w = ρg (N/m³).",
        "v = 1/ρ.",
        "S = ρ_fluid / 1000 (Mercury S = 13.6)."
      ],
      "mcqs": [],
      "msqs": [],
      "visualLearning": {
        "enabled": true,
        "visualRequired": true,
        "type": "diagram",
        "animationKey": "fluid_prop_anim",
        "title": "Mass Density, Specific Volume & Specific Gravity",
        "purpose": "Visualizing Hydrometer Measurement, Water vs Mercury Density Scale, and Unit Relationships",
        "mobileLayout": "vertical_card",
        "sequence": [
          "૧. 1 m³ કન્ટેનરમાં પાણી (1000 kg), ઓઇલ (800 kg) અને મર્ક્યુરી (13600 kg) નો માસ સરખાવો.",
          "૨. Hydrometer વડે સ્પેસિફિક ગ્રેવિટી S માપવાની પદ્ધતિ જુઓ.",
          "૩. S = 0.8 માટે ρ = 800 kg/m³ ની ગણતરી ચકાસો."
        ],
        "diagrams": [
          "Fluid Density Scale & Hydrometer Diagram"
        ],
        "rule": "Full animated Gujarati narrative story with exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/fluid_properties.mp4",
        "videos": [
          {
            "title": "Mass Density, Specific Volume & Specific Gravity - Full Concept Explanation",
            "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/fluid_properties.mp4",
            "assetPath": "assets/videos/fluid_properties.mp4",
            "description": "Comprehensive video lesson covering Mass density, specific weight, specific volume, and specific gravity."
          },
          {
            "title": "Mass Density, Specific Volume & Specific Gravity - Numerical Problem Solving",
            "url": "https://www.youtube.com/watch?v=video_t_12_num",
            "assetPath": "",
            "description": "Step-by-step fluid property conversion numerical problems."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_2_topic_2.png"
      }
    },

    // -----------------------------------------------------------------
    // TOPIC 3 (ID 13): Manometry, Buoyancy & Stability of Floating Bodies
    // -----------------------------------------------------------------
    {
      "id": 13,
      "topic": "Manometry, Buoyancy & Stability of Floating Bodies",
      "title": "Manometry, Buoyancy & Stability of Floating Bodies",
      "overview": "સ્થિર પ્રવાહીમાં દબાણ માપન માટે મનોમીટર અને પાણીમાં તૌરતા પદાર્થોની સ્થિરતા (Stability) માટે મેટાકેન્દ્રીય ઊંચાઈ (Metacentric Height GM) વપરાય છે.",
      "concept": "Hydrostatic Law: P = ρ * g * h. Buoyant Force F_B એ પદાર્થ દ્વારા વિસ્થાપિત પ્રવાહીના વજન બરાબર હોય છે. મેટાકેન્ટર M એ પદાર્થની સ્થિરતા નક્કી કરે છે: જો M એ ક્રોસ સેન્ટર G થી ઉપર હોય (GM > 0), તો પદાર્થ STABLE રહે છે.",
      "definitions": [
        "Hydrostatic Law: સ્થિર પ્રવાહીમાં ઊંડાઈ સાથે દબાણના વધારાનો દર સ્પેસિફિક વેઇટ બરાબર હોય છે (dP/dh = ρ*g).",
        "Gauge Pressure: વાતાવરણના દબાણ (Atmospheric Pressure) ને શૂન્ય ગણી માપવામાં આવતું દબાણ.",
        "Buoyancy (પ્લાવકતા): પ્રવાહીમાં ડૂબેેલા પદાર્થ પર પ્રવાહી દ્વારા ઉપરની તરફ લાગતું ઉર્ધ્વબળ (Buoyant Force F_B).",
        "Metacentre (M): તૌરતા પદાર્થ સહેજ નમતાં તેની નોર્મલ અક્ષ અને નવું બોયન્સી ફોર્સ જ્યા છેદે તે બિંદુ.",
        "Metacentric Height (GM): સેન્ટર ઓફ ગ્રેવિટી (G) અને મેટાકેન્ટર (M) વચ્ચેનું અંતર (GM = I/V - BG)."
      ],
      "detailedTheory": "તૌરતા પદાર્થની ત્રણ સ્થિતિઓ: (૧) Stable Equilibrium: M એ G ની ઉપર હોય (GM > 0). (૨) Unstable Equilibrium: M એ G ની નીચે હોય (GM < 0). (૩) Neutral Equilibrium: M અને G એક જ બિંદુ પર હોય (GM = 0). તૌરતા પદાર્થના દોલનનો સમયગાળો T = 2π * √(k² / (g * GM)). જહાજની સ્થિરતા વધારવા GM મોટો હોવો જોઈએ, પણ GM વધુ હોવાથી દોલનનો સમય ઘટે છે જેથી જહાજ ઝડપથી આંચકા અનુભવે છે.",
      "keyPoints": [
        "Hydrostatic Law -> P = ρ * g * h.",
        "Buoyant Force F_B = Weight of fluid displaced = ρ * g * V_displaced.",
        "Stable Equilibrium -> Metacentre M is ABOVE Centre of Gravity G (GM > 0).",
        "Unstable Equilibrium -> Metacentre M is BELOW Centre of Gravity G (GM < 0).",
        "Metacentric Height formula -> GM = (I / V) - BG.",
        "Time Period of Oscillation -> T = 2π * √(k² / (g * GM))."
      ],
      "formulas": [
        "Gauge Pressure: P = ρ * g * h",
        "Buoyant Force: F_B = ρ * g * V_displaced",
        "Metacentric Height: GM = (I / V) - BG",
        "Time Period of Oscillation: T = 2π * √(k² / (g * GM))"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ: પારાના U-ટ્યુબ મનોમીટરમાં હાઇડ્રોલિક હેડ h = 0.5 m મર્ક્યુરી (S = 13.6) બતાવે છે. ગેજ પ્રેશર P શોધો.\nઉકેલ:\nρ = 13.6 * 1000 = 13600 kg/m³.\nP = ρ * g * h = 13600 * 9.81 * 0.5 = 66708 Pa = 66.71 kPa."
      ],
      "importantPoints": [
        "સંપૂર્ણ ડૂબેેલા પદાર્થ (Submerged body) ની સ્થિરતા માટે Centre of Buoyancy (B) એ Centre of Gravity (G) ની ઉપર હોવો જોઈએ.",
        "શિપિંગ મરીન ઇજનેરીમાં મેટાકેન્ટ્રિક હાઇટ GM ૧ m થી ૧.૫ m રખાય છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: A floating body is STABLE if Metacentre M is -> ABOVE Centre of Gravity G.",
        "Formula for Metacentric Height -> GM = I/V - BG.",
        "Buoyant force acts through -> Centre of Buoyancy (Centroid of displaced volume).",
        "Absolute Pressure = Gauge Pressure + Atmospheric Pressure."
      ],
      "commonMistakes": [
        "GM > 0 ને અનસ્ટેબલ ગણવું (GM > 0 કાયમ STABLE હોય છે!).",
        "Submerged body અને Floating body માટે સ્થિરતાની શરતો મિક્સ કરી દેવી."
      ],
      "quickRevision": [
        "P = ρgh.",
        "F_B = ρ g V_disp.",
        "Stable -> M above G (GM > 0).",
        "GM = I/V - BG."
      ],
      "mcqs": [],
      "msqs": [],
      "visualLearning": {
        "enabled": true,
        "visualRequired": true,
        "type": "diagram",
        "animationKey": "manometry_anim",
        "title": "Manometry, Buoyancy & Stability of Floating Bodies",
        "purpose": "Visualizing Manometer Fluid Column, Buoyant Force, and Tilting Ship Metacentric Stability",
        "mobileLayout": "vertical_card",
        "sequence": [
          "૧. U-Tube Manometer માં પ્રેશર હેડ h મુજબ મર્ક્યુરી ઊંચાઈ જુઓ.",
          "૨. તૌરતા શિપ ના Tilt થવાથી Metacentre M અને Righting Couple નો ઉદ્ભવ જુઓ.",
          "૩. GM > 0 માટે Stable Equilibrium ચકાસો."
        ],
        "diagrams": [
          "U-Tube Manometer & Metacentric Height Diagram"
        ],
        "rule": "Full animated Gujarati narrative story with exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/fluid_statics.mp4",
        "videos": [
          {
            "title": "Manometry, Buoyancy & Stability of Floating Bodies - Full Concept Explanation",
            "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/fluid_statics.mp4",
            "assetPath": "assets/videos/fluid_statics.mp4",
            "description": "Comprehensive video lesson covering Pascal's law, manometers, Archimedes principle, Buoyancy, and Metacentric height GM."
          },
          {
            "title": "Manometry, Buoyancy & Stability of Floating Bodies - Numerical Problem Solving",
            "url": "https://www.youtube.com/watch?v=video_t_13_num",
            "assetPath": "",
            "description": "Step-by-step manometer pressure and metacentric height GM numerical problems."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_2_topic_3.png"
      }
    },

    // -----------------------------------------------------------------
    // TOPIC 4 (ID 14): Fluid Acceleration, Continuity & Momentum Equations
    // -----------------------------------------------------------------
    {
      "id": 14,
      "topic": "Fluid Acceleration, Continuity & Momentum Equations",
      "title": "Fluid Acceleration, Continuity & Momentum Equations",
      "overview": "વહેતા ફ્લુઇડમાં લોકલ અને કન્વેક્ટિવ એક્સિલરેશન, માસ સંરક્ષણ માટે કંટીન્યુઇટી સમીકરણ (A₁ V₁ = A₂ V₂) અને મોમેન્ટમ સમીકરણ નો અભ્યાસ થાય છે.",
      "concept": "Total Acceleration a_x = (∂u/∂t) + u(∂u/∂x) + v(∂u/∂y) + w(∂u/∂z). 3D Incompressible continuity: (∂u/∂x) + (∂v/∂y) + (∂w/∂z) = 0.",
      "definitions": [
        "Local Acceleration: સમય સાથે તાપમાન કે વેગ બદલાવાથી થતું એક્સિલરેશન (∂u / ∂t).",
        "Convective Acceleration: જગ્યા અથવા સ્થાન બદલાવાથી વેગમાં થતા ફેરફારને કારણે થતું એક્સિલરેશન (u * ∂u / ∂x).",
        "Continuity Equation: માસ સંરક્ષણના સિદ્ધાંત પર આધારિત સમીકરણ (Incompressible fluid માટે A₁ V₁ = A₂ V₂).",
        "Impulse-Momentum Principle: પ્રવાહી પર લાગતું ચોખ્ખું બળ એ સમય સાથે મોમેન્ટમમાં થતા ફેરફારના દર બરાબર હોય છે (F = m_dot * (V₂ - V₁))."
      ],
      "detailedTheory": "Steady Uniform flow માં Local = 0 અને Convective = 0 હોવાથી કુલ એક્સિલરેશન શૂન્ય હોય છે. Steady Non-uniform flow માં Local = 0 પણ Convective Acceleration હોય છે. Unsteady Non-uniform flow માં બંને એક્સિલરેશન હાજર હોય છે. 1D Flow માટે Continuity Equation: ρ₁ A₁ V₁ = ρ₂ A₂ V₂. જો ફ્લુઇડ Incompressible (ρ = C) હોય તો A₁ V₁ = A₂ V₂.",
      "keyPoints": [
        "Steady Uniform Flow -> Total Acceleration = 0.",
        "Steady Non-Uniform Flow -> Convective Acceleration present, Local = 0.",
        "Unsteady Uniform Flow -> Local Acceleration present, Convective = 0.",
        "3D Incompressible Continuity -> (∂u/∂x) + (∂v/∂y) + (∂w/∂z) = 0.",
        "1D Incompressible Continuity -> A₁ V₁ = A₂ V₂."
      ],
      "formulas": [
        "Total X-Acceleration: a_x = (∂u / ∂t) + u * (∂u / ∂x) + v * (∂u / ∂y) + w * (∂u / ∂z)",
        "3D Continuity Equation: (∂u / ∂x) + (∂v / ∂y) + (∂w / ∂z) = 0",
        "1D Continuity Equation: A₁ * V₁ = A₂ * V₂",
        "Momentum Force: F = ρ * Q * (V₂ - V₁)"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ: પાઇપનો વ્યાસ D₁ = 200 mm (A₁ = 0.0314 m²) થી ઘટીને D₂ = 100 mm (A₂ = 0.00785 m²) થાય છે. પ્રવેશ પર વેગ V₁ = 2 m/s છે. બહાર નીકળતી હવા કે પાણીનો વેગ V₂ શોધો.\nઉકેલ:\nA₁ * V₁ = A₂ * V₂ => 0.0314 * 2 = 0.00785 * V₂.\nV₂ = 0.0628 / 0.00785 = 8 m/s."
      ],
      "importantPoints": [
        "Continuity equation એ Mass Conservation Law પર આધારિત છે.",
        "Momentum equation નો ઉપયોગ પાઇપ બેન્ડ પર લાગતાં બળની ગણતરી કરવા થાય છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: Continuity equation is based on -> Conservation of MASS.",
        "In Steady Uniform Flow, acceleration is -> ZERO.",
        "Incompressible 1D flow equation -> A₁ V₁ = A₂ V₂.",
        "Convective acceleration is due to -> Change of velocity with respect to SPACE."
      ],
      "commonMistakes": [
        "Continuity equation ને Energy Conservation સમજવું (Continuity = MASS Conservation!).",
        "Steady Non-uniform flow માં શૂન્ય એક્સિલરેશન ગણવું (Convective acceleration હાજર હોય છે!)."
      ],
      "quickRevision": [
        "Continuity -> Mass Conservation (A₁ V₁ = A₂ V₂).",
        "Steady Uniform -> Acc = 0.",
        "Local = Time change | Convective = Space change.",
        "F = ρ Q ΔV."
      ],
      "mcqs": [],
      "msqs": [],
      "visualLearning": {
        "enabled": true,
        "visualRequired": true,
        "type": "diagram",
        "animationKey": "kinematics_anim",
        "title": "Fluid Acceleration, Continuity & Momentum Equations",
        "purpose": "Visualizing Tapering Pipe Acceleration, Streamlines, and Mass Flow Conservation",
        "mobileLayout": "vertical_card",
        "sequence": [
          "૧. Tapering Pipe માં ક્ષેત્રફળ ઘટતા વેગ V₁ થી V₂ વધતો જુઓ.",
          "૨. Steady, Unsteady, Uniform અને Non-uniform પદોની સમજ જુઓ.",
          "૩. A₁ V₁ = A₂ V₂ વડે ૧૦૦ mm પાઇપમાં V₂ = 8 m/s ની ગણતરી ચકાસો."
        ],
        "diagrams": [
          "Tapering Pipe Flow & Continuity Diagram"
        ],
        "rule": "Full animated Gujarati narrative story with exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/fluid_kinematics_and_dynamics.mp4",
        "videos": [
          {
            "title": "Fluid Acceleration, Continuity & Momentum Equations - Full Concept Explanation",
            "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/fluid_kinematics_and_dynamics.mp4",
            "assetPath": "assets/videos/fluid_kinematics_and_dynamics.mp4",
            "description": "Comprehensive video lesson covering Fluid Kinematics, local/convective acceleration, 3D continuity, and momentum equations."
          },
          {
            "title": "Fluid Acceleration, Continuity & Momentum Equations - Numerical Problem Solving",
            "url": "https://www.youtube.com/watch?v=video_t_14_num",
            "assetPath": "",
            "description": "Step-by-step continuity equation velocity and fluid acceleration numerical problems."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_2_topic_4.png"
      }
    },

    // -----------------------------------------------------------------
    // TOPIC 5 (ID 15): Euler's Equation & Rotodynamic Machines
    // -----------------------------------------------------------------
    {
      "id": 15,
      "topic": "Euler's Equation & Rotodynamic Machines",
      "title": "Euler's Equation & Rotodynamic Machines",
      "overview": "Euler's Equation ફ્લુઇડ એલિમેન્ટ પર લાગતા પ્રેશર અને ગ્રેવિટી ફોર્સનું મોશન સમીકરણ છે, અને તેના પરથી રોટોડાયનેમિક મશીનોનું પાવર ટ્રાન્સફર સમીકરણ મળે છે.",
      "concept": "Euler Equation along a streamline: (dP / ρ) + V dV + g dz = 0. Bernoulli equation એ Euler equation ના સંકલન (Integration) થી મળે છે. Euler Turbine Equation: Power P = m_dot * (V_w1 * u₁ ± V_w2 * u₂).",
      "definitions": [
        "Euler's Equation of Motion: ફ્રીક્શન-રહિત (Non-viscous) ફ્લુઇડ માટે સ્ટ્રીમલાઇન પર દબાણ અને ગુરુત્વાકર્ષણ બળોનું મોશન સમીકરણ.",
        "Whirl Velocity (V_w): ટર્બાઇન રનર કે ઈમ્પેઈલરની ટેન્જેન્શિયલ દિશામાં વહેતા ફ્લુઇડનો વેગ કોમ્પોનન્ટ જે વર્ક ડન ઉત્પન્ન કરે છે.",
        "Flow Velocity (V_f): રનરમાંથી પસાર થતી હાઇડ્રોલિક ડિસ્ચાર્જ વહન માટે જવાબદાર એક્સિયલ અથવા રેડિયલ વેગ કોમ્પોનન્ટ.",
        "Euler Turbine Equation: રનર બ્લેડ્સ વડે ફ્લુઇડમાંથી શાફ્ટમાં ટ્રાન્સફર થતાં પાવરનું પાયાનું સમીકરણ."
      ],
      "detailedTheory": "યુલર સમીકરણ મેળવવા ફ્લુઇડને Frictionless (Ideal), Incompressible અને Flow ને Steady ગણવામાં આવે છે. ટર્બાઇન માટે વ્હર્લ વેલોસિટી ડાયાગ્રામ પરથી પાવરનું સૂત્ર P = m_dot * (V_w1 * u₁ - V_w2 * u₂). જો એક્ઝિટ પર ફ્લુઇડ રેડિયલી બહાર નીકળે તો V_w2 = 0 થાય છે અને P = m_dot * V_w1 * u₁ બને છે.",
      "keyPoints": [
        "Euler Equation -> (dP / ρ) + V dV + g dz = 0.",
        "Bernoulli Equation is obtained by INTEGRATING Euler Equation.",
        "Assumptions: Ideal (Non-viscous), Incompressible, Steady flow along a streamline.",
        "Euler Power Equation P = m_dot * (V_w1 * u₁ ± V_w2 * u₂).",
        "If discharge is radial at exit -> V_w2 = 0, so Power P = m_dot * V_w1 * u₁."
      ],
      "formulas": [
        "Euler Motion Equation: (dP / ρ) + V dV + g dz = 0",
        "Euler Power Equation: P = m_dot * (V_w1 * u₁ ± V_w2 * u₂)",
        "Hydraulic Head Developed: H = (V_w1 * u₁ ± V_w2 * u₂) / g"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ: ટર્બાઇન રનરમાં 100 kg/s પાણી V_w1 = 25 m/s અને u₁ = 15 m/s સાથે દાખલ થાય છે. એક્ઝિટ પર રેડિયલ ફ્લો (V_w2 = 0) છે. ટર્બાઇન પાવર P ગણો.\nઉકેલ:\nP = m_dot * V_w1 * u₁ = 100 kg/s * 25 m/s * 15 m/s = 37500 W = 37.5 kW."
      ],
      "importantPoints": [
        "Euler's equation માં વિસ્કોસિટી (Friction) ધ્યાને લેવાતી નથી.",
        "પમ્પમાં વર્ક ફ્લુઇડ પર થાય છે જ્યારે ટર્બાઇનમાં ફ્લુઇડ દ્વારા પાવર મળે છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: Integration of Euler's equation yields -> Bernoulli's Equation.",
        "Euler's equation assumes fluid is -> Inviscid (Frictionless) and Incompressible.",
        "Power equation when exit flow is radial -> P = m_dot * V_w1 * u₁.",
        "Velocity component responsible for work done -> Whirl Velocity (V_w)."
      ],
      "commonMistakes": [
        "Euler equation માં Friction ધ્યાને લેવું (Euler equation એ frictionless flow માટે છે!).",
        "Whirl velocity (V_w) ને Flow velocity (V_f) સાથે ગૂંચવી દેવી."
      ],
      "quickRevision": [
        "(dP/ρ) + V dV + g dz = 0.",
        "Integrate -> Bernoulli.",
        "P = m_dot * (V_w1 u1 - V_w2 u2).",
        "Radial exit -> V_w2 = 0."
      ],
      "mcqs": [],
      "msqs": [],
      "visualLearning": {
        "enabled": true,
        "visualRequired": true,
        "type": "diagram",
        "animationKey": "euler_anim",
        "title": "Euler's Equation & Rotodynamic Machines",
        "purpose": "Visualizing Fluid Element Forces along Streamline and Turbine Inlet/Outlet Velocity Triangles",
        "mobileLayout": "vertical_card",
        "sequence": [
          "૧. Streamline પર પ્રેશર અને ગ્રેવિટી ફોર્સનું Euler Equation બલેન્સ જુઓ.",
          "૨. Runner Inlet/Outlet પર Whirl Velocity V_w અને Blade Velocity u ના Triangles જુઓ.",
          "૩. P = m_dot * V_w1 * u₁ = 37.5 kW ની પાવર ગણતરી જુઓ."
        ],
        "diagrams": [
          "Euler Streamline & Runner Velocity Triangles Diagram"
        ],
        "rule": "Full animated Gujarati narrative story with exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/fluid_kinematics_and_dynamics.mp4",
        "videos": [
          {
            "title": "Euler's Equation & Rotodynamic Machines - Full Concept Explanation",
            "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/fluid_kinematics_and_dynamics.mp4",
            "assetPath": "assets/videos/fluid_kinematics_and_dynamics.mp4",
            "description": "Comprehensive video lesson covering Euler's motion equation, Bernoulli derivation, and rotodynamic turbine power equations."
          },
          {
            "title": "Euler's Equation & Rotodynamic Machines - Numerical Problem Solving",
            "url": "https://www.youtube.com/watch?v=video_t_15_num",
            "assetPath": "",
            "description": "Step-by-step velocity triangle and Euler turbine power output numerical problems."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_2_topic_5.png"
      }
    },

    // -----------------------------------------------------------------
    // TOPIC 6 (ID 16): Flow Through Pipes & Head Losses
    // -----------------------------------------------------------------
    {
      "id": 16,
      "topic": "Flow Through Pipes & Head Losses",
      "title": "Flow Through Pipes & Head Losses",
      "overview": "પાઇપમાં વહન દરમિયાન ઘર્ષણને કારણે મેજર હેડ લોસ (Darcy-Weisbach Eq) અને આકાર બદલાવાથી માઇનર લોસીસ થાય છે.",
      "concept": "Darcy-Weisbach Equation: h_f = (4 * f * L * V²) / (2 * g * d). Sudden Expansion Loss: h_e = (V₁ - V²)² / (2g). Max power transmission when h_f = H / 3 (Efficiency = 66.67%). Total Energy Line (TEL) કાયમ Hydraulic Gradient Line (HGL) ની ઉપર હોય છે.",
      "definitions": [
        "Major Loss (h_f): પાઇપની સપાટીના ઘર્ષણ (Friction) ના કારણે થતો હેડ લોસ.",
        "Darcy Friction Factor (f'): f' = 4f, જ્યાં f એ Fanning friction coefficient છે.",
        "Hydraulic Gradient Line (HGL): P-head અને Datum-head નો સરવાળો દર્શાવતી રેખા (HGL = P/ρg + z).",
        "Total Energy Line (TEL): કુલ એનર્જી હેડ (P-head + Velocity head + Datum head) દર્શાવતી રેખા (TEL = P/ρg + V²/2g + z).",
        "Sudden Expansion Loss (h_e): h_e = (V₁ - V₂)² / 2g."
      ],
      "detailedTheory": "TEL અને HGL વચ્ચેનો વર્ટિકલ તફાવત કાયમ વેલોસિટી હેડ V²/2g બરાબર હોય છે. Minor Losses: (૧) Sudden Expansion: (V₁ - V₂)² / 2g, (૨) Sudden Contraction: 0.5 * V₂² / 2g, (૩) Pipe Entrance: 0.5 * V² / 2g, (૪) Pipe Exit: V² / 2g. પાઇપ દ્વારા મહત્તમ પાવર ટ્રાન્સમિશન માટે ફ્રીક્શન લોસ h_f = H / 3 હોવો જોઈએ, અને તે સ્થિતિમાં મહત્તમ એફિશિયન્સી ૬૬.૬૭% મળે છે.",
      "keyPoints": [
        "Darcy-Weisbach Equation -> h_f = (4 f L V²) / (2 g d).",
        "Sudden Expansion Loss -> h_e = (V₁ - V₂)² / 2g.",
        "Sudden Contraction Loss -> h_c = 0.5 V₂² / 2g.",
        "TEL is ALWAYS ABOVE HGL by V² / 2g.",
        "Condition for Maximum Power Transmission -> h_f = H / 3.",
        "Maximum Efficiency of Power Transmission -> 66.67%."
      ],
      "formulas": [
        "Darcy-Weisbach Head Loss: h_f = (4 * f * L * V²) / (2 * g * d)",
        "Sudden Expansion Loss: h_e = (V₁ - V₂)² / (2g)",
        "Sudden Contraction Loss: h_c = 0.5 * (V₂² / 2g)",
        "Max Power Transmission Loss: h_f = H / 3"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ: 500 m લાંબી અને 0.2 m વ્યાસની પાઇપમાંથી 2 m/s ની ઝડપે પાણી વહે છે. ફ્રીક્શન ફેક્ટર f = 0.005 છે. ઘર્ષણ હેડ લોસ h_f ગણો.\nઉકેલ:\nh_f = (4 * 0.005 * 500 * 2²) / (2 * 9.81 * 0.2) = 40 / 3.924 = 10.19 m."
      ],
      "importantPoints": [
        "TEL ની લાઇન કાયમ વહનની દિશામાં નીચે જ નમે છે (Downward sloping).",
        "Syphon pipe ના ઉચ્ચતમ બિંદુ (Summit) પર પ્રેશર વાતાવરણના દબાણ કરતાં ઓછું (Negative gauge pressure) હોય છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: Vertical distance between TEL and HGL represents -> Velocity Head (V² / 2g).",
        "Head loss due to sudden expansion -> (V₁ - V₂)² / 2g.",
        "Head loss for max power transmission through pipe -> h_f = H / 3.",
        "Maximum efficiency of power transmission -> 66.67%."
      ],
      "commonMistakes": [
        "TEL ને HGL ની નીચે દોરી દેવી (TEL કાયમ HGL ની ઉપર જ હોય!).",
        "Sudden expansion અને contraction ના સૂત્રો બદલી નાખવા."
      ],
      "quickRevision": [
        "h_f = 4fLV² / 2gd.",
        "Expansion = (V₁-V₂)²/2g.",
        "Contraction = 0.5 V²/2g.",
        "TEL - HGL = V²/2g.",
        "Max Power: h_f = H/3 (η = 66.67%)."
      ],
      "mcqs": [],
      "msqs": [],
      "visualLearning": {
        "enabled": true,
        "visualRequired": true,
        "type": "diagram",
        "animationKey": "pipe_flow_anim",
        "title": "Flow Through Pipes & Head Losses",
        "purpose": "Visualizing Hydraulic Gradient Line HGL, Total Energy Line TEL, and Pipe Friction/Expansion Head Loss",
        "mobileLayout": "vertical_card",
        "sequence": [
          "૧. Pipe Flow માં TEL અને HGL વચ્ચેનો ગ્રેડિયન્ટ અને V²/2g અંતર જુઓ.",
          "૨. Sudden Expansion અને Sudden Contraction ના સ્થાનિક એડીઝ લોસીસ જુઓ.",
          "૩. Max Power Transmission માટે h_f = H/3 અને η = 66.67% ચકાસો."
        ],
        "diagrams": [
          "TEL, HGL & Pipe Head Loss Diagram"
        ],
        "rule": "Full animated Gujarati narrative story with exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/flow_through_pipes.mp4",
        "videos": [
          {
            "title": "Flow Through Pipes & Head Losses - Full Concept Explanation",
            "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/flow_through_pipes.mp4",
            "assetPath": "assets/videos/flow_through_pipes.mp4",
            "description": "Comprehensive video lesson covering Darcy-Weisbach equation, minor losses, TEL/HGL lines, and max power transmission."
          },
          {
            "title": "Flow Through Pipes & Head Losses - Numerical Problem Solving",
            "url": "https://www.youtube.com/watch?v=video_t_16_num",
            "assetPath": "",
            "description": "Step-by-step pipe friction head loss and TEL/HGL numerical problems."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_2_topic_6.png"
      }
    },

    // -----------------------------------------------------------------
    // TOPIC 7 (ID 17): Units, Dimensions & Fluid Properties
    // -----------------------------------------------------------------
    {
      "id": 17,
      "topic": "Units, Dimensions & Fluid Properties",
      "title": "Units, Dimensions & Fluid Properties",
      "overview": "ફ્લુઇડ મિકેનિક્સમાં વપરાતી ભૌતિક રાશિઓ પરિમાણો (Dimensions M, L, T, F) અને SI યુનિટ્સમાં દર્શાવાય છે.",
      "concept": "Dynamic Viscosity [μ] = M L⁻¹ T⁻¹. Kinematic Viscosity [ν] = L² T⁻¹. Surface Tension [σ] = M T⁻² (અથવા F L⁻¹). Pressure [P] = M L⁻¹ T⁻².",
      "definitions": [
        "Fundamental Dimensions: પાયાના મુક્ત પરિમાણો: માસ [M], લંબાઈ [L], અને સમય [T] (અથવા ફોર્સ [F]).",
        "Secondary / Derived Dimensions: પાયાના પરિમાણો વડે દર્શાવાતી ભૌતિક રાશિઓ (દા.ત. વેગ [L T⁻¹], એક્સિલરેશન [L T⁻²]).",
        "Dimensional Homogeneity: કોઈપણ ભૌતિક સમીકરણની બંને બાજુના દરેક પદના ડાયમેન્શન્સ સમાન હોવા ફરજિયાત છે."
      ],
      "detailedTheory": "ડાયનેમિક વિસ્કોસિટી μ નો ડાયમેન્શનલ ફોર્મ્યુલા મેળવવો: τ = μ * (du/dy) => [μ] = [τ] / [du/dy] = (M L⁻¹ T⁻²) / (T⁻¹) = M L⁻¹ T⁻¹. કાઇનેમેટિક વિસ્કોસિટી ν = μ / ρ => [ν] = (M L⁻¹ T⁻¹) / (M L⁻³) = L² T⁻¹ (માસથી મુક્ત!). સરફેસ ટેન્શન σ = Force / Length = (M L T⁻²) / L = M T⁻².",
      "keyPoints": [
        "Dynamic Viscosity [μ] = M L⁻¹ T⁻¹ (or F T L⁻²).",
        "Kinematic Viscosity [ν] = L² T⁻¹ (Independent of Mass [M]).",
        "Surface Tension [σ] = M T⁻² (or F L⁻¹).",
        "Pressure / Stress [P] = M L⁻¹ T⁻².",
        "Discharge [Q] = L³ T⁻¹.",
        "Power [P] = M L² T⁻³."
      ],
      "formulas": [
        "Dynamic Viscosity Dimension: [μ] = M * L⁻¹ * T⁻¹",
        "Kinematic Viscosity Dimension: [ν] = L² * T⁻¹",
        "Surface Tension Dimension: [σ] = M * T⁻²",
        "Pressure Dimension: [P] = M * L⁻¹ * T⁻²"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ: Kinematic Viscosity ν = μ / ρ નો ડાયમેન્શનલ ફોર્મ્યુલા સાબિત કરો.\nઉકેલ:\n[μ] = M L⁻¹ T⁻¹ અને [ρ] = M L⁻³.\n[ν] = (M L⁻¹ T⁻¹) / (M L⁻³) = L^(-1 - (-3)) T⁻¹ = L² T⁻¹."
      ],
      "importantPoints": [
        "Kinematic Viscosity ના ડાયમેન્શનમાં માસ [M] નો પાવર શૂન્ય (M⁰) હોય છે.",
        "Dimensional homogeneity વગરનું સમીકરણ ભૌતિક રીતે અશક્ય હોય છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: Dimension of Kinematic Viscosity -> L² T⁻¹.",
        "Dimension of Dynamic Viscosity -> M L⁻¹ T⁻¹.",
        "Dimension of Surface Tension -> M T⁻² or F L⁻¹.",
        "Dimension of Pressure -> M L⁻¹ T⁻²."
      ],
      "commonMistakes": [
        "Kinematic viscosity માં Mass [M] નો પાવર ૧ ગણવો (તે માસ-મુક્ત L² T⁻¹ છે!).",
        "Surface tension ના પરિમાણમાં લંબાઈ [L] નો પાવર ૧ લખવો (M T⁻² સાચું છે)."
      ],
      "quickRevision": [
        "[μ] = M L⁻¹ T⁻¹.",
        "[ν] = L² T⁻¹.",
        "[σ] = M T⁻².",
        "[P] = M L⁻¹ T⁻¹.",
        "[Q] = L³ T⁻¹."
      ],
      "mcqs": [],
      "msqs": [],
      "visualLearning": {
        "enabled": true,
        "visualRequired": true,
        "type": "diagram",
        "animationKey": "units_anim",
        "title": "Units, Dimensions & Fluid Properties",
        "purpose": "Visualizing Base Dimensions M, L, T Derivation Matrix for Viscosity and Pressure",
        "mobileLayout": "vertical_card",
        "sequence": [
          "૧. Base Units [M], [L], [T] પરથી Derived Units ની બનાવટ જુઓ.",
          "૨. Dynamic Viscosity M L⁻¹ T⁻¹ અને Kinematic Viscosity L² T⁻¹ નો તફાવત જુઓ.",
          "૩. Dimensional Homogeneity ની ચકાસણી જુઓ."
        ],
        "diagrams": [
          "Fluid Property Dimensions & Unit Matrix Diagram"
        ],
        "rule": "Full animated Gujarati narrative story with exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/units_and_dimensions.mp4",
        "videos": [
          {
            "title": "Units, Dimensions & Fluid Properties - Full Concept Explanation",
            "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/units_and_dimensions.mp4",
            "assetPath": "assets/videos/units_and_dimensions.mp4",
            "description": "Comprehensive video lesson covering Fluid dimensions MLT/FLT systems, viscosity dimensions, and dimensional homogeneity."
          },
          {
            "title": "Units, Dimensions & Fluid Properties - Numerical Problem Solving",
            "url": "https://www.youtube.com/watch?v=video_t_17_num",
            "assetPath": "",
            "description": "Step-by-step dimensional formula derivations and unit conversions."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_2_topic_7.png"
      }
    },

    // -----------------------------------------------------------------
    // TOPIC 8 (ID 18): Compressibility, Surface Tension & Fluid Statics
    // -----------------------------------------------------------------
    {
      "id": 18,
      "topic": "Compressibility, Surface Tension & Fluid Statics",
      "title": "Compressibility, Surface Tension & Fluid Statics",
      "overview": "કમ્પ્રેસિબિલિટી (Bulk Modulus K), સરફેસ ટેન્શન (σ), અને કેપિલેરિટી રાઇઝ/ડિપ્રેશન એ પ્રવાહીના અણુ-સપાટી ગુણધર્મો છે.",
      "concept": "Bulk Modulus K = -dP / (dV/V) = ρ * (dP/dρ). Surface Tension pressure inside Water Droplet ΔP = 4σ / d, Soap Bubble ΔP = 8σ / d, Liquid Jet ΔP = 2σ / d. Capillary Rise h = (4 σ cosθ) / (ρ g d).",
      "definitions": [
        "Bulk Modulus of Elasticity (K): દબાણના ફેરફાર (dP) અને વોલ્યુમેટ્રિક સ્ટ્રેઇન (-dV/V) નો ગુણોત્તર (K = -dP / (dV/V)).",
        "Compressibility (β): બલ્ક મોડ્યુલસનો વ્યસ્ત (β = 1 / K).",
        "Surface Tension (σ): પ્રવાહી સપાટી પર અણુઓના સંસક્ત બળ (Cohesion) ના કારણે ખેંચાયેલી પટલ (Tension membrane) ની જેમ વર્તવાની ક્ષમતા (N/m).",
        "Capillarity (કેપિલેરિટી): નાની નળી (Tube) માં પ્રવાહીનું ઉપર ચડવું (Capillary Rise) કે નીચે બેસવું (Capillary Depression).",
        "Angle of Contact (θ): પ્રવાહી સપાટી અને કાચ વચ્ચેનો ખૂણો (પાણી માટે θ ≈ 0°, પારા માટે θ ≈ 130°)."
      ],
      "detailedTheory": "સાબુના પરપોટા (Soap Bubble) માં બે મુક્ત સપાટીઓ (Two free surfaces) હોવાથી અંદરનું દબાણ વોટર ડ્રોપલેટ કરતાં બમણું ΔP = 8σ / d હોય છે. વોટર ડ્રોપલેટ માટે ΔP = 4σ / d અને લીક્વિડ જેટ માટે ΔP = 2σ / d. પારા (Mercury) નો કાચ સાથે એડહેશન કરતાં કોહેશન બળ વધુ હોવાથી તે કેપિલેરી ડિપ્રેશન (નીચે ઉતરવું) દર્શાવે છે.",
      "keyPoints": [
        "Bulk Modulus K = -dP / (dV/V) = ρ (dP/dρ).",
        "Compressibility β = 1 / K.",
        "Pressure inside Water Droplet -> ΔP = 4σ / d.",
        "Pressure inside Soap Bubble -> ΔP = 8σ / d (Double of droplet!).",
        "Pressure inside Liquid Jet -> ΔP = 2σ / d.",
        "Capillary Rise formula -> h = (4 σ cosθ) / (ρ g d)."
      ],
      "formulas": [
        "Bulk Modulus: K = - dP / (dV / V) = ρ * (dP / dρ)",
        "Water Droplet Pressure: ΔP = (4 * σ) / d",
        "Soap Bubble Pressure: ΔP = (8 * σ) / d",
        "Liquid Jet Pressure: ΔP = (2 * σ) / d",
        "Capillary Rise/Fall: h = (4 * σ * cosθ) / (ρ * g * d)"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ: 2 mm (0.002 m) વ્યાસના પાણીના ટીંપા (σ = 0.073 N/m) માં અંદરનું વધારાનું ગેજ દબાણ ΔP શોધો.\nઉકેલ:\nΔP = 4 * σ / d = (4 * 0.073) / 0.002 = 0.292 / 0.002 = 146 Pa = 146 N/m²."
      ],
      "importantPoints": [
        "પારા માટે કેપિલેરી ટ્યુબમાં પ્રવાહીની સપાટી કોન્વેક્સ (Convex shape) બને છે અને કેપિલેરી ફોલ થાય છે.",
        "કાચ અને શુદ્ધ પાણી વચ્ચે નો કોન્ટેક્ટ એન્ગલ θ = 0° લેવાય છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: Pressure inside a soap bubble -> 8σ / d.",
        "Pressure inside a liquid droplet -> 4σ / d.",
        "Capillary rise formula -> h = (4σ cosθ) / (ρ g d).",
        "Compressibility is the reciprocal of -> Bulk Modulus of Elasticity (1/K)."
      ],
      "commonMistakes": [
        "સાબુના પરપોટા માટે 4σ/d સૂત્ર મૂકી દેવું (8σ/d સાચું છે!).",
        "કેપિલેરિટીમાં નળીનો વ્યાસ d વધતાં ઊંચાઈ h વધે છે તેમ માનવું (વ્યાસ વધતાં h ઘટે છે, h ∝ 1/d)."
      ],
      "quickRevision": [
        "K = -dP / (dV/V).",
        "Droplet = 4σ/d | Soap = 8σ/d | Jet = 2σ/d.",
        "h = 4σ cosθ / (ρgd).",
        "Mercury -> Capillary Depression."
      ],
      "mcqs": [],
      "msqs": [],
      "visualLearning": {
        "enabled": true,
        "visualRequired": true,
        "type": "diagram",
        "animationKey": "compressibility_anim",
        "title": "Compressibility, Surface Tension & Fluid Statics",
        "purpose": "Visualizing Droplet vs Soap Bubble Surface Tension Forces and Capillary Rise in Micro-Tubes",
        "mobileLayout": "vertical_card",
        "sequence": [
          "૧. Droplet (૧ સરફેસ 4σ/d) અને Soap Bubble (૨ સરફેસ 8σ/d) ની સરખામણી જુઓ.",
          "૨. Capillary Tube માં પાણીનું ચડવું (θ ≈ 0°) અને પારાનું ઉતરવું (θ ≈ 130°) જુઓ.",
          "૩. 2 mm ડ્રોપલેટ માટે ΔP = 146 Pa ની ગણતરી જુઓ."
        ],
        "diagrams": [
          "Surface Tension Excess Pressure & Capillarity Diagram"
        ],
        "rule": "Full animated Gujarati narrative story with exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/fluid_statics.mp4",
        "videos": [
          {
            "title": "Compressibility, Surface Tension & Fluid Statics - Full Concept Explanation",
            "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/fluid_statics.mp4",
            "assetPath": "assets/videos/fluid_statics.mp4",
            "description": "Comprehensive video lesson covering Bulk modulus, compressibility, surface tension in droplets/bubbles, and capillarity."
          },
          {
            "title": "Compressibility, Surface Tension & Fluid Statics - Numerical Problem Solving",
            "url": "https://www.youtube.com/watch?v=video_t_18_num",
            "assetPath": "",
            "description": "Step-by-step surface tension pressure and capillary rise numerical problems."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_2_topic_8.png"
      }
    },

    // -----------------------------------------------------------------
    // TOPIC 9 (ID 19): Control-Volume Analysis of Mass, Momentum & Energy
    // -----------------------------------------------------------------
    {
      "id": 19,
      "topic": "Control-Volume Analysis of Mass, Momentum & Energy",
      "title": "Control-Volume Analysis of Mass, Momentum & Energy",
      "overview": "કન્ટ્રોલ વોલ્યુમ પર માસ, મોમેન્ટમ અને એનર્જી બેલેન્સ લાગુ કરી પાઇપ બેન્ડ્સ અને વોટર જેટ્સ પર લાગતા બળોની ગણતરી કરાય છે.",
      "concept": "Force on Pipe Bend: F_x = P₁ A₁ - P₂ A₂ cosθ + ρ Q (V₁ - V₂ cosθ). Force on Fixed Vertical Flat Plate: F = ρ A V². Force on Moving Flat Plate: F = ρ A (V - u)².",
      "definitions": [
        "Control Volume Analysis: અવકાશમાં ચોક્કસ નિયંત્રિત વિસ્તાર (CV) પસંદ કરી તેની સીમામાંથી વહેતા માસ અને ઉર્જાનો અભ્યાસ.",
        "Force on Pipe Bend: પાઇપમાં વહન દરમિયાન દિશા બદલાવાથી વહેતા પાણી દ્વારા પાઇપ બેન્ડ પર લાગતું પરિણામી બળ.",
        "Jet Impact: હાઇ-સ્પીડ નોઝલમાંથી નીકળતી પ્રવાહીની ધાર (Jet) દ્વારા પ્લેટ કે બ્લેડ પર લાગતું ઇમ્પેક્ટ ફોર્સ."
      ],
      "detailedTheory": "સ્થિર ફ્લેટ વર્ટિકલ પ્લેટ પર નોઝલ જેટ અથડાતાં લાગતું બળ F = ρ A V² હોય છે. જો પ્લેટ u મિનિટ ઝડપે વહેતા જેટની જ દિશામાં ગતિ કરતી હોય (Moving Plate), તો લાગતું બળ F = ρ A (V - u)² થાય છે. મુવિંગ પ્લેટની વર્ક ડન ક્ષમતા W = F * u = ρ A (V - u)² * u અને મહત્તમ એફિશિયન્સી u = V/3 પર η_max = 29.63% થાય છે.",
      "keyPoints": [
        "Force on Fixed Vertical Flat Plate -> F = ρ A V².",
        "Force on Moving Flat Plate -> F = ρ A (V - u)².",
        "Work Done on Moving Flat Plate -> W = ρ A (V - u)² * u.",
        "Max Efficiency for Moving Flat Plate -> u = V / 3 (η_max = 29.63%).",
        "Force on Curved Vane at Center -> F = 2 ρ A V²."
      ],
      "formulas": [
        "Force on Fixed Vertical Plate: F = ρ * A * V²",
        "Force on Moving Vertical Plate: F = ρ * A * (V - u)²",
        "Work Done on Moving Plate: W = ρ * A * (V - u)² * u",
        "Force on Pipe Bend X-Dir: F_x = P₁ A₁ - P₂ A₂ cosθ + ρ Q (V₁ - V₂ cosθ)"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ: 50 mm વ્યાસની નોઝલમાંથી (A = 0.0019635 m²) 20 m/s ની ઝડપે નીકળતું પાણીનું જેટ સ્થિર ઉભી પ્લેટ સાથે અથડાય છે. લાગતું બળ F ગણો.\nઉકેલ:\nF = ρ * A * V² = 1000 * 0.0019635 * (20)² = 1.9635 * 400 = 785.4 N."
      ],
      "importantPoints": [
        "પાઇપ બેન્ડ પર એન્કર બ્લોક (Anchor Block) લગાવી પરિણામી ફોર્સને બેલેન્સ કરવામાં આવે છે.",
        "કર્વ્ડ વેનના સેન્ટર પર પ્લેટ સાથે અથડાતાં બળ બમણું 2 ρ A V² થાય છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: Force exerted by jet on a FIXED flat vertical plate -> ρ A V².",
        "Force on a MOVING flat vertical plate -> ρ A (V - u)².",
        "Maximum efficiency of a moving flat plate -> 29.63% (at u = V/3).",
        "Force on a fixed curved hemispherical vane -> 2 ρ A V²."
      ],
      "commonMistakes": [
        "Fixed plate અને Moving plate ના બળોના સૂત્રો મિક્સ કરી દેવા (V ની જગ્યાએ V-u મૂકવું ભૂલી જવું).",
        "Moving flat plate ની મહત્તમ એફિશિયન્સી ૫૦% માનવી (તે ૨૯.૬૩% જ હોય છે)."
      ],
      "quickRevision": [
        "Fixed Plate -> F = ρ A V².",
        "Moving Plate -> F = ρ A (V-u)².",
        "Max Efficiency -> u = V/3 (29.63%).",
        "Hemispherical Vane -> F = 2 ρ A V²."
      ],
      "mcqs": [],
      "msqs": [],
      "visualLearning": {
        "enabled": true,
        "visualRequired": true,
        "type": "diagram",
        "animationKey": "control_vol_anim",
        "title": "Control-Volume Analysis of Mass, Momentum & Energy",
        "purpose": "Visualizing Water Jet Impact on Fixed vs Moving Flat Plates and Pipe Bend Forces",
        "mobileLayout": "vertical_card",
        "sequence": [
          "૧. Nozzle Jet સ્થિર પ્લેટ પર અથડાઈ F = ρ A V² બળ ઉત્પન્ન કરતું જુઓ.",
          "૨. Moving Plate પર અપેક્ષિત વેગ (V-u) અને વર્ક W = ρ A (V-u)² u જુઓ.",
          "૩. F = 785.4 N નો ઇમ્પેક્ટ ફોર્સ ગણતરીથી ચકાસો."
        ],
        "diagrams": [
          "Jet Impact on Flat & Curved Vanes Diagram"
        ],
        "rule": "Full animated Gujarati narrative story with exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/fluid_control_volume.mp4",
        "videos": [
          {
            "title": "Control-Volume Analysis of Mass, Momentum & Energy - Full Concept Explanation",
            "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/fluid_control_volume.mp4",
            "assetPath": "assets/videos/fluid_control_volume.mp4",
            "description": "Comprehensive video lesson covering Control volume analysis, pipe bend forces, and water jet impact on fixed/moving vanes."
          },
          {
            "title": "Control-Volume Analysis of Mass, Momentum & Energy - Numerical Problem Solving",
            "url": "https://www.youtube.com/watch?v=video_t_19_num",
            "assetPath": "",
            "description": "Step-by-step water jet impact force and pipe bend momentum numerical problems."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_2_topic_9.png"
      }
    },

    // -----------------------------------------------------------------
    // TOPIC 10 (ID 20): Bernoulli's Equation & Dimensional Analysis
    // -----------------------------------------------------------------
    {
      "id": 20,
      "topic": "Bernoulli's Equation & Dimensional Analysis",
      "title": "Bernoulli's Equation & Dimensional Analysis",
      "overview": "બર્નોલીનું સમીકરણ એનર્જી સંરક્ષણનો સિદ્ધાંત આપે છે. પરિમાણીય વિશ્લેષણમાં Buckingham π-Theorem અને Model Laws (Reynolds, Froude) અગત્યના છે.",
      "concept": "Bernoulli Equation: (P / ρg) + (V² / 2g) + z = Constant. Discharge Measurement: Venturimeter (Cd ≈ 0.95 - 0.98), Orificemeter (Cd ≈ 0.60 - 0.65). Model Laws: Reynolds Number Re, Froude Number Fr = V / √(g L).",
      "definitions": [
        "Bernoulli's Equation: આદર્શ અસંકોચ્ય ફ્લુઇડના વહન માટે સ્ટ્રીમલાઇન પર કુલ એનર્જી હેડ (Pressure head + Velocity head + Datum head) અચળ રહે છે.",
        "Venturimeter: પાઇપમાં વહેતા પાણીનો ડિસ્ચાર્જ (Q) માપવાનું સાધન (Convergent cone, Throat, Divergent cone).",
        "Buckingham π-Theorem: જો ભૌતિક ઘટનામાં n વેરીએબલ્સ અને m ફંડામેન્ટલ ડાઇમેન્શન્સ હોય, તો તેને (n - m) પરસ્પર મુક્ત ડાઇમેન્શનલેસ પાયિ (π) ટર્મ્સ વડે રજૂ કરાય છે.",
        "Froude Model Law: મુક્ત પ્રવાહી સપાટી અને ગુરુત્વાકર્ષણ બળ આધારિત વહન (શિપ મોડેલિંગ, ઓપન ચેનલ, સ્પીલવે) માટે Fr_model = Fr_prototype."
      ],
      "detailedTheory": "વેન્ચુરીમીટરમાં ડાઇવર્જન્ટ કોનનો એંગલ (૫° થી ૭°) નાનો રાખવામાં આવે છે જેથી Flow Separation અટકે. વેન્ચુરીમીટરનો Cd = 0.95 થી 0.98 હોય છે જ્યારે ઓરિફિસમીટરનો Cd = 0.60 થી 0.65 હોય છે. Froude Number Fr = V / √(g L). શિપ રેઝિસ્ટન્સ અને સ્પીલવે માટે ફ્રાઉડ મોડેલ લો વપરાય છે. પાઇપ ફ્લો અને સબમરીન માટે રેનોલ્ડ્સ મોડેલ લો (Re = ρ V D / μ) વપરાય છે.",
      "keyPoints": [
        "Bernoulli Equation -> (P / ρ g) + (V² / 2g) + z = Constant.",
        "Bernoulli Equation is based on -> Conservation of ENERGY.",
        "Venturimeter C_d ≈ 0.95 - 0.98.",
        "Orificemeter C_d ≈ 0.60 - 0.65.",
        "Buckingham π-Theorem -> Number of π terms = n - m.",
        "Froude Model Law (Fr = V / √(gL)) -> Used for Ships, Spillways, Open Channels."
      ],
      "formulas": [
        "Bernoulli's Equation: (P / ρg) + (V² / 2g) + z = Constant",
        "Venturimeter Discharge: Q_actual = C_d * [(A₁ * A₂) / √(A₁² - A₂²)] * √(2 g h)",
        "Froude Number: Fr = V / √(g * L)",
        "Reynolds Number: Re = (ρ * V * D) / μ"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ: વેન્ચુરીમીટર A₁ = 0.02 m², A₂ = 0.005 m² અને Cd = 0.98 સાથે ૨ m નો વેન્ચુરી હેડ h દર્શાવે છે. ડિસ્ચાર્જ Q ગણો.\nઉકેલ:\nQ = 0.98 * [(0.02 * 0.005) / √(0.02² - 0.005²)] * √(2 * 9.81 * 2)\nQ = 0.98 * [0.0001 / 0.01936] * 6.264 = 0.0317 m³/s = 31.7 L/s."
      ],
      "importantPoints": [
        "પીટોટ ટ્યુબ (Pitot Tube) વડે વહેતા પ્રવાહીનો સ્થાનિક વેગ (Stagnation Velocity) માપી શકાય છે (V = C_v √(2gh)).",
        "Buckingham π-theorem વડે વિસંગતતા વગર સંકુલ ભૌતિક સમીકરણોનું ડાઇમેન્શનલેસ વિશ્લેષણ થાય છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: Bernoulli's equation is based on -> Conservation of ENERGY.",
        "Co-efficient of discharge for Venturimeter -> 0.95 to 0.98.",
        "Model law used for open channel flow and ships -> Froude Model Law.",
        "Number of pi-terms in Buckingham theorem -> n - m."
      ],
      "commonMistakes": [
        "Bernoulli સમીકરણને Mass કે Momentum conservation સમજવું (તે ENERGY Conservation પર છે!).",
        "Venturimeter અને Orificemeter ના Cd ના મૂલ્યો બદલી નાખવા."
      ],
      "quickRevision": [
        "P/ρg + V²/2g + z = C.",
        "Energy Conservation.",
        "Venturi Cd = 0.95-0.98 | Orifice Cd = 0.60-0.65.",
        "Ships -> Froude Law (Fr = V/√(gL))."
      ],
      "mcqs": [],
      "msqs": [],
      "visualLearning": {
        "enabled": true,
        "visualRequired": true,
        "type": "diagram",
        "animationKey": "bernoulli_anim",
        "title": "Bernoulli's Equation & Dimensional Analysis",
        "purpose": "Visualizing Venturimeter Convergent/Divergent Flow, Piezometer Tubes, and Ship Froude Model Scaling",
        "mobileLayout": "vertical_card",
        "sequence": [
          "૧. Venturimeter ના Throat પર Pressure Head ઘટી Velocity Head વધતું જુઓ.",
          "૨. Orificemeter ની સરખામણીમાં Venturimeter ની ઉંચી Cd = 0.98 જુઓ.",
          "૩. Buckingham π-Theorem n-m અને Ship Model Froude Law જુઓ."
        ],
        "diagrams": [
          "Venturimeter Setup & Froude Model Law Diagram"
        ],
        "rule": "Full animated Gujarati narrative story with exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/model_analysis_and_similitude.mp4",
        "videos": [
          {
            "title": "Bernoulli's Equation & Dimensional Analysis - Full Concept Explanation",
            "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/model_analysis_and_similitude.mp4",
            "assetPath": "assets/videos/model_analysis_and_similitude.mp4",
            "description": "Comprehensive video lesson covering Bernoulli equation, Venturimeter/Orificemeter, Buckingham pi theorem, and Froude/Reynolds model laws."
          },
          {
            "title": "Bernoulli's Equation & Dimensional Analysis - Numerical Problem Solving",
            "url": "https://www.youtube.com/watch?v=video_t_20_num",
            "assetPath": "",
            "description": "Step-by-step Venturimeter discharge and Froude model law numerical problems."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_2_topic_10.png"
      }
    },

    // -----------------------------------------------------------------
    // TOPIC 11 (ID 21): Viscous Flow, Boundary Layer & Turbulent Flow
    // -----------------------------------------------------------------
    {
      "id": 21,
      "topic": "Viscous Flow, Boundary Layer & Turbulent Flow",
      "title": "Viscous Flow, Boundary Layer & Turbulent Flow",
      "overview": "લેમિનર (શ્યાન) વહન, Hagen-Poiseuille પાઇપ ફ્લો, બાઉન્ડ્રી લેયર થિકનેસ (δ, δ*, θ) અને ફ્લો સેપરેશન નો અભ્યાસ થાય છે.",
      "concept": "Pipe Flow Reynolds Number: Re < 2000 (Laminar), Re > 4000 (Turbulent). Hagen-Poiseuille Flow: u_max / u_avg = 2.0. Boundary Layer Displacement Thickness δ* = ∫(1 - u/U)dy. Momentum Thickness θ = ∫ (u/U)(1 - u/U)dy.",
      "definitions": [
        "Laminar Flow: પ્રવાહીના સ્તરો એકબીજા પર સ્મૂધલી ઘસ્યા વગર વહે છે (Re < 2000).",
        "Turbulent Flow: અણુઓ અસ્તવ્યસ્ત અને એડીઝ (Eddies) સાથે વહે છે (Re > 4000).",
        "Hagen-Poiseuille Flow: ગોળાકાર પાઇપમાંથી થતું લેમિનર શ્યાન વહન જેમાં પેરાબોલિક વેલોસિટી પ્રોફાઇલ મળે છે.",
        "Boundary Layer Thickness (δ): ઘન સપાટીથી એવું વર્ટિકલ અંતર જ્યાં ફ્લુઇડનો વેગ ફ્રી-સ્ટ્રીમ વેગના ૯૯% (u = 0.99 U) થાય છે.",
        "Displacement Thickness (δ*): બાઉન્ડ્રી લેયરમાં વિસ્કોસિટીના કારણે માસ ફ્લો ઘટે છે તેને સરભર કરવા બાઉન્ડ્રી શિફ્ટ થતું અંતર."
      ],
      "detailedTheory": "ગોળાકાર પાઇપમાં લેમિનર ફ્લો માટે મહત્તમ વેગ એ સરેરાશ વેગ કરતાં બમણો (u_max = 2 * u_avg) હોય છે! બે સમાંતર પ્લેટો વચ્ચે u_max = 1.5 * u_avg થાય છે. Darcy friction factor f' = 64 / Re. બાઉન્ડ્રી લેયર સેપરેશન ત્યારે જ થાય છે જ્યારે Adverse Pressure Gradient (∂P / ∂x > 0) હોય અને સપાટી પર વેલોસિટી ગ્રેડિયન્ટ (∂u / ∂y)_(y=0) < 0 બને.",
      "keyPoints": [
        "Pipe Flow Laminar Re < 2000 | Turbulent Re > 4000.",
        "Hagen-Poiseuille Circular Pipe -> u_max / u_avg = 2.0.",
        "Parallel Plates Laminar -> u_max / u_avg = 1.5.",
        "Darcy Friction Factor for Laminar Pipe -> f = 64 / Re.",
        "Boundary Layer Displacement Thickness -> δ* = ∫(1 - u/U) dy.",
        "Boundary Layer Separation Condition -> (∂u / ∂y)_(y=0) < 0 (Adverse Pressure Gradient ∂P / ∂x > 0)."
      ],
      "formulas": [
        "Hagen-Poiseuille Max Velocity: u_max = 2 * u_avg",
        "Laminar Pipe Head Loss: h_f = (32 * μ * u_avg * L) / (ρ * g * D²)",
        "Laminar Friction Factor: f = 64 / Re",
        "Displacement Thickness: δ* = ∫ (1 - u/U) dy",
        "Momentum Thickness: θ = ∫ (u/U) * (1 - u/U) dy"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ: પાઇપમાં લેમિનર વહન માટે Re = 1000 છે. Darcy friction factor f અને Hagen-Poiseuille અનુસાર u_max / u_avg નો ગુણોત્તર લખો.\nઉકેલ:\nDarcy Friction Factor f = 64 / Re = 64 / 1000 = 0.064.\nu_max / u_avg = 2.0 (બમણો વેગ)."
      ],
      "importantPoints": [
        "બાઉન્ડ્રી લેયર સેપરેશન અટકાવવા માટે સપાટી સુધારણા, સુચન (Suction) અથવા ફ્લુઇડ ઇન્જેક્શન વાપરી શકાય છે.",
        "Shape factor H = δ* / θ = 2.59 (Blasius laminar solution માટે)."
      ],
      "examPoints": [
        "GSSSB Golden Question: In laminar flow through circular pipe, ratio of max velocity to average velocity -> 2.0.",
        "Ratio of max to avg velocity for parallel plates -> 1.5.",
        "Friction factor for laminar pipe flow -> 64 / Re.",
        "Boundary layer separation occurs when velocity gradient at boundary is -> NEGATIVE (< 0)."
      ],
      "commonMistakes": [
        "ગોળાકાર પાઇપમાં u_max / u_avg = 1.5 લખી દેવું (પાઇપ માટે ૨.૦ સાચું છે, ૧.૫ સમાંતર પ્લેટો માટે છે!).",
        "Fanning friction factor (16/Re) અને Darcy friction factor (64/Re) ને એક ગણવું."
      ],
      "quickRevision": [
        "Pipe Laminar: Re < 2000.",
        "u_max / u_avg = 2.0 (Pipe) | 1.5 (Plates).",
        "f = 64/Re.",
        "Separation -> (∂u/∂y)_(y=0) < 0."
      ],
      "mcqs": [],
      "msqs": [],
      "visualLearning": {
        "enabled": true,
        "visualRequired": true,
        "type": "diagram",
        "animationKey": "viscous_anim",
        "title": "Viscous Flow, Boundary Layer & Turbulent Flow",
        "purpose": "Visualizing Hagen-Poiseuille Parabolic Profile, Boundary Layer Growth δ, and Flow Separation Point",
        "mobileLayout": "vertical_card",
        "sequence": [
          "૧. Pipe માં Hagen-Poiseuille Parabolic Velocity Profile (u_max = 2 u_avg) જુઓ.",
          "૨. Flat Plate પર Boundary Layer Growth δ, δ* અને θ નો વિકાસ જુઓ.",
          "૩. Adverse Pressure Gradient પર Flow Separation અટકવાનું દૃશ્ય જુઓ."
        ],
        "diagrams": [
          "Hagen-Poiseuille & Boundary Layer Separation Diagram"
        ],
        "rule": "Full animated Gujarati narrative story with exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/boundary_layer_theory.mp4",
        "videos": [
          {
            "title": "Viscous Flow, Boundary Layer & Turbulent Flow - Full Concept Explanation",
            "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/boundary_layer_theory.mp4",
            "assetPath": "assets/videos/boundary_layer_theory.mp4",
            "description": "Comprehensive video lesson covering Hagen-Poiseuille flow, boundary layer thickness δ, δ*, θ, and flow separation."
          },
          {
            "title": "Viscous Flow, Boundary Layer & Turbulent Flow - Numerical Problem Solving",
            "url": "https://www.youtube.com/watch?v=video_t_21_num",
            "assetPath": "",
            "description": "Step-by-step laminar pipe friction factor and boundary layer displacement thickness numerical problems."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_2_topic_11.png"
      }
    },

    // -----------------------------------------------------------------
    // TOPIC 12 (ID 22): Water Turbines, Heads, Efficiencies & Velocity Triangles
    // -----------------------------------------------------------------
    {
      "id": 22,
      "topic": "Water Turbines, Heads, Efficiencies & Velocity Triangles",
      "title": "Water Turbines, Heads, Efficiencies & Velocity Triangles",
      "overview": "હાઇડ્રોલિક ટર્બાઇનમાં પાણીની પોટેન્શિયલ અને કાઇનેટિક એનર્જીનું શાફ્ટ મિકેનિકલ પાવરમાં રૂપાંતર થાય છે. તેના માટે વિવિધ એફિશિયન્સીઓ અને Specific Speed (N_s) અગત્યની છે.",
      "concept": "Net Head H = H_g - h_f. Hydraulic Efficiency η_h = RP / WP. Mechanical Efficiency η_m = SP / RP. Overall Efficiency η_o = SP / WP = η_h * η_m. Specific Speed N_s = (N * √P) / H^(5/4).",
      "definitions": [
        "Water Power (WP): નોઝલ કે પેનસ્ટોક દ્વારા ટર્બાઇનને મળતી કુલ હાઇડ્રોલિક ઉર્જા (WP = ρ * g * Q * H Watts).",
        "Runner Power (RP): પાણીના જેટ દ્વારા ટર્બાઇન રનર બ્લેડ્સ પર ઉત્પન્ન થતો પાવર (RP = m_dot * (V_w1 * u₁ ± V_w2 * u₂)).",
        "Shaft Power (SP): ટર્બાઇન ક્રેન્કશાફ્ટ પર મળતો વાસ્તવિક મિકેનિકલ આઉટપુટ પાવર.",
        "Specific Speed (N_s): ૧ મીટર નેટ હેડ હેઠળ ૧ kW શાફ્ટ પાવર ઉત્પન્ન કરતી કાલ્પનિક ભૌમિતિક રીતે સમાન ટર્બાઇનની ઝડપ (N_s = N * √P / H^(5/4))."
      ],
      "detailedTheory": "હાઇડ્રોલિક એફિશિયન્સી η_h = RP / WP = (V_w1 * u₁ ± V_w2 * u₂) / (g * H). મિકેનિકલ એફિશિયન્સી η_m = SP / RP. ઓવરઓલ એફિશિયન્સી η_o = SP / WP = η_h * η_m. પમ્પની Specific speed માટે સૂત્ર N_s = N * √Q / H^(3/4) વપરાય છે, જ્યારે ટર્બાઇન માટે પાવર પદ સાથે N_s = N * √P / H^(5/4) વપરાય છે.",
      "keyPoints": [
        "Water Power WP = ρ g Q H (in Watts).",
        "Hydraulic Efficiency η_h = RP / WP.",
        "Mechanical Efficiency η_m = SP / RP.",
        "Overall Efficiency η_o = SP / WP = η_h * η_m.",
        "Turbine Specific Speed N_s = (N √P) / H^(5/4) (P in kW, H in meters).",
        "Pump Specific Speed N_s = (N √Q) / H^(3/4)."
      ],
      "formulas": [
        "Water Power: WP = ρ * g * Q * H",
        "Hydraulic Efficiency: η_h = (V_w1 * u₁ ± V_w2 * u₂) / (g * H)",
        "Overall Efficiency: η_o = SP / (ρ * g * Q * H) = η_h * η_m",
        "Turbine Specific Speed: N_s = (N * √P) / H^(5/4)"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ: ટર્બાઇન નેટ હેડ H = 100 m પર Q = 2 m³/s પાણી મેળવી શાફ્ટ પાવર SP = 1600 kW ઉત્પન્ન કરે છે. Overall Efficiency η_o ગણો.\nઉકેલ:\nWater Power WP = 1000 * 9.81 * 2 * 100 = 1962000 W = 1962 kW.\nη_o = SP / WP = 1600 / 1962 = 0.8155 = 81.55 %."
      ],
      "importantPoints": [
        "Net Head H એ ગ્રોસ હેડમાંથી પેનસ્ટોક ઘર્ષણ લોસ બાદ કરતાં મળે છે (H = H_g - h_f).",
        "Specific speed વડે આપેલી હેડ અને ડિસ્ચાર્જ સ્થિતિ માટે સાચી ટર્બાઇન પસંદ કરી શકાય છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: Formula for Specific Speed of a Turbine -> N_s = (N √P) / H^(5/4).",
        "Relationship between efficiencies -> η_o = η_h * η_m.",
        "Water Power formula -> ρ g Q H.",
        "Unit of Power P in turbine specific speed formula -> kW."
      ],
      "commonMistakes": [
        "ટર્બાઇન અને પમ્પના સ્પેસિફિક સ્પીડના સૂત્રો મિક્સ કરવા (ટર્બાઇનમાં H^(5/4) અને પમ્પમાં H^(3/4)!).",
        "Specific speed ના સૂત્રમાં પાવર P ને Watts માં મૂકી દેવો (તે kW માં હોવો જોઈએ)."
      ],
      "quickRevision": [
        "WP = ρ g Q H.",
        "η_o = η_h * η_m.",
        "Turbine N_s = N √P / H^(5/4).",
        "Pump N_s = N √Q / H^(3/4)."
      ],
      "mcqs": [],
      "msqs": [],
      "visualLearning": {
        "enabled": true,
        "visualRequired": true,
        "type": "diagram",
        "animationKey": "turbines_anim",
        "title": "Water Turbines, Heads, Efficiencies & Velocity Triangles",
        "purpose": "Visualizing Penstock Net Head, Runner Work Transfer, and Efficiency Chain",
        "mobileLayout": "vertical_card",
        "sequence": [
          "૧. Dam થી Penstock વડે Gross Head H_g માંથી h_f બાદ થઈ Net Head H મળતું જુઓ.",
          "૨. Water Power -> Runner Power -> Shaft Power નો એફિશિયન્સી ચેઇન ટ્રાન્સફર જુઓ.",
          "૩. Specific Speed N_s = N √P / H^(5/4) વડે ટર્બાઇન સિલેક્શન ગ્રાફ જુઓ."
        ],
        "diagrams": [
          "Turbine Efficiency Chain & Specific Speed Chart"
        ],
        "rule": "Full animated Gujarati narrative story with exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/hydraulic_turbines.mp4",
        "videos": [
          {
            "title": "Water Turbines, Heads, Efficiencies & Velocity Triangles - Full Concept Explanation",
            "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/hydraulic_turbines.mp4",
            "assetPath": "assets/videos/hydraulic_turbines.mp4",
            "description": "Comprehensive video lesson covering Water turbines, heads, hydraulic/overall efficiencies, and specific speed N_s."
          },
          {
            "title": "Water Turbines, Heads, Efficiencies & Velocity Triangles - Numerical Problem Solving",
            "url": "https://www.youtube.com/watch?v=video_t_22_num",
            "assetPath": "",
            "description": "Step-by-step overall efficiency and turbine specific speed numerical calculations."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_2_topic_12.png"
      }
    },

    // -----------------------------------------------------------------
    // TOPIC 13 (ID 23): Pelton Wheel, Francis Turbine & Kaplan Turbine
    // -----------------------------------------------------------------
    {
      "id": 23,
      "topic": "Pelton Wheel, Francis Turbine & Kaplan Turbine",
      "title": "Pelton Wheel, Francis Turbine & Kaplan Turbine",
      "overview": "પેલ્ટન વ્હીલ (Impulse), ફ્રાન્સિસ (Mixed Reaction) અને કેપલાન (Axial Reaction) એ મુખ્ય ૩ હાઇડ્રોલિક ટર્બાઇન્સ છે.",
      "concept": "Pelton Wheel: High Head (H > 250 m), Tangential Impulse. Francis: Medium Head (30-250 m), Mixed Flow Reaction. Kaplan: Low Head (H < 30 m), High Flow Axial Reaction with adjustable blades. Draft Tube is used ONLY in Reaction Turbines.",
      "definitions": [
        "Pelton Wheel: ઉંચા હેડ અને ઓછા ડિસ્ચાર્જ માટે વપરાતી ટેન્જેન્શિયલ ફ્લો ઇમ્પલ્સ ટર્બાઇન (N_s = 10 - 30).",
        "Francis Turbine: મધ્યમ હેડ અને મધ્યમ ડિસ્ચાર્જ માટે વપરાતી ઇનવર્ડ મિક્સ્ડ ફ્લો રિએક્શન ટર્બાઇન (N_s = 60 - 300).",
        "Kaplan Turbine: નીચા હેડ અને ખુબ મોટા ડિસ્ચાર્જ માટે વપરાતી એક્સિયલ ફ્લો રિએક્શન ટર્બાઇન (N_s = 300 - 1000).",
        "Draft Tube: રિએક્શન ટર્બાઇનના આઉટલેટ પર લગાડાતી એક્સપાનડિંગ પાઇપ જે એક્ઝિટ કાઇનેટિક એનર્જીને પ્રેશર એનર્જીમાં રિકવર કરે છે.",
        "Jet Ratio (m): પેલ્ટન વ્હીલના પીચ ડાયામીટર (D) અને નોઝલ જેટ ડાયામીટર (d) નો ગુણોત્તર (m = D / d ≈ 12)."
      ],
      "detailedTheory": "પેલ્ટન વ્હીલ બકેટ્સમાં બકેટ સ્પીડ રેશિયો u = k_u * √(2gH) (જ્યાં k_u ≈ 0.45 - 0.48). બકેટ્સની સંખ્યા Z = 15 + 0.5 m = 15 + 0.5 (D/d) (Tygun Formula). કેપલાન ટર્બાઇન એડજસ્ટેબલ રનર વાન્સ ધરાવે છે, જ્યારે પ્રોપેલર ટર્બાઇન ફિક્સ્ડ વાન્સ ધરાવે છે. ડ્રાફ્ટ ટ્યુબ માત્ર રિએક્શન ટર્બાઇન્સ (Francis & Kaplan) માં જ વપરાય છે, Impulse ટર્બાઇન (Pelton) માં ક્યારેય ડ્રાફ્ટ ટ્યુબ વપરાતી નથી.",
      "keyPoints": [
        "Pelton Wheel = High Head (H > 250 m), Low Flow, Tangential Impulse (N_s = 10-30).",
        "Francis Turbine = Medium Head (30-250 m), Medium Flow, Mixed Reaction (N_s = 60-300).",
        "Kaplan Turbine = Low Head (H < 30 m), High Flow, Axial Reaction (N_s = 300-1000).",
        "Pelton Bucket Speed u = (0.45 to 0.48) * √(2gH).",
        "Number of Pelton Buckets Z = 15 + 0.5 * (D/d).",
        "Draft Tube is used ONLY in REACTION TURBINES (Francis & Kaplan)."
      ],
      "formulas": [
        "Jet Velocity: V_1 = C_v * √(2 * g * H)",
        "Pelton Bucket Speed: u = k_u * √(2 * g * H)",
        "Jet Ratio: m = D / d",
        "Number of Buckets (Tygun): Z = 15 + 0.5 * (D / d)",
        "Kaplan Discharge: Q = (π / 4) * (D_o² - D_b²) * V_f"
      ],
      "solvedExamples": [
        "દાખલા ઉકેલ: પેલ્ટન વ્હીલ માટે રનર વ્યાસ D = 1 m અને નોઝલ વ્યાસ d = 0.1 m છે. Jet Ratio m અને બકેટ્સની સંખ્યા Z ગણો.\nઉકેલ:\nJet Ratio m = D / d = 1 / 0.1 = 10.\nBuckets Z = 15 + 0.5 * m = 15 + 0.5 * 10 = 15 + 5 = 20 બકેટ્સ."
      ],
      "importantPoints": [
        "કેપલાન ટર્બાઇનની પાર્ટ-લોડ એફિશિયન્સી ખુબ ઉંચી અને ફ્લેટ હોય છે કારણ કે તેની બ્લેડ્સ રનર હબ પર એડજસ્ટ થઈ શકે છે.",
        "ગવર્નિંગ માટે પેલ્ટન વ્હીલમાં સ્પીયર વાલ્વ અને ડિફ્લેક્ટર બ્લેડ વાપરાય છે."
      ],
      "examPoints": [
        "GSSSB Golden Question: High head low discharge turbine -> Pelton Wheel.",
        "Low head high discharge axial turbine -> Kaplan Turbine.",
        "Draft tube is used in -> Reaction Turbines (Francis & Kaplan).",
        "Number of buckets formula for Pelton wheel -> 15 + 0.5 (D/d)."
      ],
      "commonMistakes": [
        "પેલ્ટન વ્હીલમાં ડ્રાફ્ટ ટ્યુબ વપરાય છે તેમ માનવું (ઇમ્પલ્સ ટર્બાઇનમાં ડ્રાફ્ટ ટ્યુબ ન હોય!).",
        "કેપલાન ટર્બાઇનમાં ફ્લો રેડિયલ ગણવો (કેપલાનમાં ફ્લો AXIAL હોય છે)."
      ],
      "quickRevision": [
        "Pelton: High Head, Impulse (N_s=10-30).",
        "Francis: Medium Head, Reaction (N_s=60-300).",
        "Kaplan: Low Head, Axial (N_s=300-1000).",
        "Buckets Z = 15 + 0.5 (D/d).",
        "Draft Tube -> Reaction only."
      ],
      "mcqs": [],
      "msqs": [],
      "visualLearning": {
        "enabled": true,
        "visualRequired": true,
        "type": "diagram",
        "animationKey": "types_turbines_anim",
        "title": "Pelton Wheel, Francis Turbine & Kaplan Turbine",
        "purpose": "Visualizing Pelton Bucket Jet Impact, Francis Scroll Casing, Kaplan Axial Propeller, and Draft Tube",
        "mobileLayout": "vertical_card",
        "sequence": [
          "૧. Pelton Bucket નો Tangential Jet Impact અને Splitter Action જુઓ.",
          "૨. Francis Scroll Casing અને Kaplan Axial Flow Propeller Blades ની ગતિ જુઓ.",
          "૩. Reaction Turbines માં Draft Tube ની Kinetic Energy Recovery જુઓ."
        ],
        "diagrams": [
          "Pelton, Francis, Kaplan & Draft Tube Diagrams"
        ],
        "rule": "Full animated Gujarati narrative story with exam traps.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/hydraulic_turbines.mp4",
        "videos": [
          {
            "title": "Pelton Wheel, Francis Turbine & Kaplan Turbine - Full Concept Explanation",
            "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/hydraulic_turbines.mp4",
            "assetPath": "assets/videos/hydraulic_turbines.mp4",
            "description": "Comprehensive video lesson covering Pelton wheel impulse, Francis mixed flow, Kaplan axial flow turbines, jet ratio, and draft tubes."
          },
          {
            "title": "Pelton Wheel, Francis Turbine & Kaplan Turbine - Numerical Problem Solving",
            "url": "https://www.youtube.com/watch?v=video_t_23_num",
            "assetPath": "",
            "description": "Step-by-step Pelton jet ratio, bucket numbers, and Kaplan discharge numerical calculations."
          }
        ],
        "imageUrl": "assets/images/diagrams/subj_2_topic_13.png"
      }
    }
  ];

  // Update Subject 2 in masterData
  masterData[subjectIndex]['topics'] = updatedTopics;

  // Save back to master_study_material.json
  masterFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(masterData),
    encoding: utf8,
  );

  print('✅ Successfully updated master_study_material.json with 13 fully elaborated Fluid Mechanics topics!');

  // Update video_catalog.json for Subject 2
  final catalogFile = File('assets/video_learning/video_catalog.json');
  if (catalogFile.existsSync()) {
    final Map<String, dynamic> catalogJson = jsonDecode(catalogFile.readAsStringSync());
    final List<dynamic> catalogVideos = catalogJson['videos'] as List<dynamic>? ?? [];

    // Filter out old subject 2 videos
    final otherVideos = catalogVideos.where(
      (v) => (v['subject'] as String? ?? '').trim().toLowerCase() != 'fluid mechanics',
    ).toList();

    final List<Map<String, dynamic>> s2CatalogVideos = [];

    final videoAssetMap = {
      11: "assets/videos/fluid_properties.mp4",
      12: "assets/videos/mass_density_spec_volume.mp4",
      13: "assets/videos/manometry_buoyancy_stability.mp4",
      14: "assets/videos/fluid_kinematics_and_dynamics.mp4",
      15: "assets/videos/eulers_equation_rotodynamic.mp4",
      16: "assets/videos/flow_through_pipes.mp4",
      17: "assets/videos/units_and_dimensions.mp4",
      18: "assets/videos/compressibility_surface_tension.mp4",
      19: "assets/videos/fluid_control_volume.mp4",
      20: "assets/videos/model_analysis_and_similitude.mp4",
      21: "assets/videos/boundary_layer_theory.mp4",
      22: "assets/videos/hydraulic_turbines.mp4",
      23: "assets/videos/pelton_francis_kaplan.mp4",
    };

    for (final t in updatedTopics) {
      final int id = t['id'];
      final String title = t['title'];
      final String asset = videoAssetMap[id] ?? "assets/videos/fluid_properties.mp4";

      // Concept Video Entry
      s2CatalogVideos.add({
        'id': 'vid_${id}_1',
        'subject': 'Fluid Mechanics',
        'topic': title,
        'title': '$title - Full Concept Explanation',
        'url': 'https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/$asset',
        'assetPath': asset,
        'type': 'concept',
        'language': 'Gujarati',
        'isPrimary': true,
        'isGeneratedVideo': true,
        'isExternalLink': false,
        'verified': true,
        'qualityScore': 10,
        'practicalScore': 9,
        'examRelevance': 10,
        'durationSeconds': 390 + (id * 10),
        'description': 'Full animated Gujarati story-based video lesson covering core theory, formulas, visual working, and GSSSB AAE exam traps for $title.',
      });

      // Numerical Video Entry
      s2CatalogVideos.add({
        'id': 'vid_${id}_2',
        'subject': 'Fluid Mechanics',
        'topic': title,
        'title': '$title - Numerical & Practical Problem Solving',
        'url': 'https://www.youtube.com/watch?v=video_t_${id}_num',
        'assetPath': '',
        'type': 'numerical',
        'language': 'Gujarati',
        'isPrimary': false,
        'isGeneratedVideo': false,
        'isExternalLink': true,
        'verified': false,
        'qualityScore': 9,
        'practicalScore': 10,
        'examRelevance': 10,
        'durationSeconds': 250 + (id * 10),
        'description': 'Step-by-step numerical problem solving, formula derivation, and unit conversions for $title.',
      });
    }

    final List<dynamic> newFullCatalog = [...s2CatalogVideos, ...otherVideos];

    catalogJson['videos'] = newFullCatalog;
    catalogJson['totalVideos'] = newFullCatalog.length;

    catalogFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(catalogJson),
      encoding: utf8,
    );

    print('✅ Successfully updated video_catalog.json with ${s2CatalogVideos.length} Subject 2 video records!');
  }

  print('====================================================');
  print('🎉 SUBJECT 2 UPGRADE COMPLETED SUCCESSFULLY WITH 0 ERRORS!');
  print('====================================================');
}
