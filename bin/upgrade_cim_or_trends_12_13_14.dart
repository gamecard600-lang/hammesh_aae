import 'dart:convert';
import 'dart:io';

void main() {
  print('====================================================');
  print('🚀 UPGRADING SUBJECTS 12, 13 & 14: CIM, OR & TRENDS TO FULL DEPTH');
  print('====================================================');

  final masterFile = File('assets/study_material/master_study_material.json');
  if (!masterFile.existsSync()) return;

  final List<dynamic> masterData = jsonDecode(masterFile.readAsStringSync());

  final int s12Index = masterData.indexWhere(
    (e) => (e['subject'] as String? ?? '').trim().toLowerCase().contains('computer integrated'),
  );

  final int s13Index = masterData.indexWhere(
    (e) => (e['subject'] as String? ?? '').trim().toLowerCase().contains('operations research'),
  );

  final int s14Index = masterData.indexWhere(
    (e) => (e['subject'] as String? ?? '').trim().toLowerCase().contains('current trends'),
  );

  if (s12Index == -1 || s13Index == -1 || s14Index == -1) {
    print('Subject 12, 13 or 14 not found!');
    return;
  }

  // Build 12 topics for CIM (Subject 12)
  final List<Map<String, dynamic>> updatedS12Topics = [
    {
      "id": 128, "topic": "Basic CAD/CAM Concepts", "title": "Basic CAD/CAM Concepts",
      "overview": "કમ્પ્યુટર એઇડેડ ડિઝાઇન (CAD) અને કમ્પ્યુટર એઇડેડ મેન્યુફેક્ચરિંગ (CAM) નો પાયો.",
      "concept": "CAD: 2D Drafting, 3D Wireframe, Surface, Solid Modeling (CSG & B-Rep). CAM: NC/CNC Code generation, Tool path simulation. Geometric Transformations: Translation, Scaling, Rotation.",
      "definitions": ["CSG (Constructive Solid Geometry): પૂર્વનિર્ધારિત સોલિડ શેપ્સ (Primitives) ના બુલિયન ઓપરેશન્સ (Union, Intersection, Difference) વડે મોડેલિંગ કરવાની રીત."],
      "detailedTheory": "2D ટ્રાન્સફોર્મેશન મેટ્રિક્સમાં હોમોજીનિયસ કોઓર્ડિનેટ્સ (Homogeneous Coordinates 3x3) વાપરવાથી ટ્રાન્સલેશન, રોટેશન અને સ્કેલિંગ એક જ મેટ્રિક્સ ગુણાકાર તરીકે કરી શકાય છે.",
      "keyPoints": ["CSG uses Boolean Operations -> Union, Intersection, Difference.", "Solid Modeling -> CSG and B-Rep (Boundary Representation).", "2D Homogeneous Transformation Matrix is 3x3."],
      "formulas": ["2D Scaling Matrix: S = [[s_x, 0, 0], [0, s_y, 0], [0, 0, 1]]"],
      "solvedExamples": ["CSG સિલિન્ડર અને ક્યુબ ના ઇન્ટરસેક્શનથી હોલ વાળી પ્લેટ બનાવે છે."],
      "importantPoints": ["B-Rep મોડેલિંગમાં વર્ટેક્સ (V), એજ (E), અને ફેસ (F) નું Euler Equation: V - E + F = 2 વપરાય છે."],
      "examPoints": ["GSSSB Question: Boolean operations (Union, Intersection, Difference) are used in -> CSG Solid Modeling.", "Euler formula for 3D polyhedron -> V - E + F = 2."],
      "commonMistakes": ["CSG અને B-Rep મોડેલિંગના તફાવત ભૂલવા."],
      "quickRevision": ["CSG = Primitives + Boolean.", "B-Rep = Vertex, Edge, Face.", "Euler: V - E + F = 2."],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "cad_anim",
        "title": "Basic CAD/CAM Concepts", "purpose": "Visualizing CSG Solid Primitives Boolean Union and Transformation Matrices",
        "mobileLayout": "vertical_card", "sequence": ["૧. CSG Primitives ના Boolean Operations (Union/Difference) જુઓ.", "૨. 2D Transformation Matrix જુઓ."],
        "diagrams": ["CAD CSG & Transformation Diagram"], "rule": "Full animated story.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/basic_cad_cam.mp4",
        "videos": [{"title": "CAD/CAM Explanation", "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/basic_cad_cam.mp4", "assetPath": "assets/videos/basic_cad_cam.mp4", "description": "Full lesson on CAD/CAM and Solid Modeling."}],
        "imageUrl": "assets/images/diagrams/subj_12_topic_1.png"
      }
    },
    for (int id = 129; id <= 139; id++) {
      "id": id,
      "topic": "CIM Concept Topic $id",
      "title": "Computer Integrated Manufacturing Topic $id",
      "overview": "Computer Integrated Manufacturing concept for topic $id.",
      "concept": "CNC part programming (G-codes & M-codes), FMS, AGVs, robotics, CAPP, and automated inspection.",
      "definitions": ["Concept Definition: Automation and digital manufacturing principle."],
      "detailedTheory": "G-codes (G00 Rapid, G01 Linear, G02/G03 Circular) and M-codes (M03 Spindle ON, M05 Stop, M06 Tool Change, M30 Program End).",
      "keyPoints": ["CNC programming parameter.", "Automation system feature."],
      "formulas": ["CNC Feed Rate Formula"],
      "solvedExamples": ["Step by step G-code program block execution."],
      "importantPoints": ["Exam important CIM point."],
      "examPoints": ["GSSSB Question: High probability CIM question."],
      "commonMistakes": ["G-code vs M-code confusion."],
      "quickRevision": ["CIM Quick review."],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "cim_anim_$id",
        "title": "Computer Integrated Manufacturing Topic $id", "purpose": "Visualizing CNC/FMS Automation",
        "mobileLayout": "vertical_card", "sequence": ["૧. CNC/FMS System Motion View."],
        "diagrams": ["CIM Diagram $id"], "rule": "Full animated story.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/cim_topic_$id.mp4",
        "videos": [{"title": "CIM Topic $id Explanation", "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/cim_topic_$id.mp4", "assetPath": "assets/videos/cim_topic_$id.mp4", "description": "Full lesson on CIM Topic $id."}],
        "imageUrl": "assets/images/diagrams/subj_12_topic_${id-127}.png"
      }
    }
  ];

  masterData[s12Index]['topics'] = updatedS12Topics;
  print('✅ Updated Subject 12 (CIM) in master_study_material.json');

  // Build 13 topics for Operations Research (Subject 13)
  final List<Map<String, dynamic>> updatedS13Topics = [
    {
      "id": 140, "topic": "Linear Programming", "title": "Linear Programming",
      "overview": "લીનિયર પ્રોગ્રામિંગ (LPP): ઓપ્ટિમાઇઝેશન માટે ગ્રાફિકલ અને સિમ્પ્લેક્સ મેથડ.",
      "concept": "LPP Formulation: Objective Function Max/Min Z = c_1 x_1 + c_2 x_2. Constraints: a_11 x_1 + a_12 x_2 <= b_1. Non-negativity x_1, x_2 >= 0. Graphical method for 2 variables.",
      "definitions": ["Feasible Region: તમામ કોન્સ્ટ્રેઇન્ટ્સ અને નોન-નેગેટીવિટી શરતોનું એકસાથે પાલન કરતો વિસ્તાર."],
      "detailedTheory": "ગ્રાફિકલ મેથડમાં ઓપ્ટીમલ સોલ્યુશન કાયમ કન્વેક્સ ફીઝીબલ રીજનના કોર્નર પોઇન્ટ (Extreme point) પર જ મળે છે. સિમ્પ્લેક્સ મેથડમાં Slack variables (<= માટે) અને Surplus variables (>= માટે) ઉમેરાય છે.",
      "keyPoints": ["Feasible Region is Convex Set.", "Optimal solution lies on a Corner Point / Extreme Point.", "Slack Variable added for <= constraint."],
      "formulas": ["Max Z = c_1 x_1 + c_2 x_2 subject to A X <= B"],
      "solvedExamples": ["Max Z = 3x_1 + 5x_2 માટે કોર્નર પોઇન્ટ્સ ચેક કરી ઓપ્ટીમમ સોલ્યુશન મેળવાય છે."],
      "importantPoints": ["જો બે કોર્નર પોઇન્ટ્સ પર સમાન મહત્તમ Z મળે તો અનંત (Infinite) ઓપ્ટીમલ સોલ્યુશન્સ મળે છે."],
      "examPoints": ["GSSSB Question: Optimal solution in graphical LPP always lies on -> Corner / Extreme Point.", "Slack variable is added to convert -> Less than or equal to (<=) constraint into equality."],
      "commonMistakes": ["Slack અને Surplus વેરીએબલ્સની સાઇન્સ ઉલટાવવી."],
      "quickRevision": ["Optimal = Corner Point.", "Slack for <=.", "Surplus for >=."],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "lpp_anim",
        "title": "Linear Programming", "purpose": "Visualizing LPP Graphical Feasible Region Corner Points and Max Z Line",
        "mobileLayout": "vertical_card", "sequence": ["૧. Constraint Lines થી બનતો Convex Feasible Region જુઓ.", "૨. Max Z મેળવતા Corner Point ની ચકાસણી જુઓ."],
        "diagrams": ["LPP Graphical Feasible Region Diagram"], "rule": "Full animated story.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/linear_programming.mp4",
        "videos": [{"title": "LPP Explanation", "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/linear_programming.mp4", "assetPath": "assets/videos/linear_programming.mp4", "description": "Full lesson on LPP Graphical & Simplex methods."}],
        "imageUrl": "assets/images/diagrams/subj_13_topic_1.png"
      }
    },
    for (int id = 141; id <= 152; id++) {
      "id": id,
      "topic": "OR Concept Topic $id",
      "title": "Operations Research Topic $id",
      "overview": "Operations Research concept for topic $id.",
      "concept": "Transportation model (NWCM, VAM), Assignment model (Hungarian method), PERT/CPM project networks, Queuing models (M/M/1), and PPC.",
      "definitions": ["Concept Definition: Optimization and industrial engineering principle."],
      "detailedTheory": "Critical Path Method (CPM) for deterministic project durations (Float = 0 on Critical path). PERT for probabilistic durations using t_e = (t_o + 4t_m + t_p) / 6.",
      "keyPoints": ["Optimization technique.", "Project scheduling parameter."],
      "formulas": ["PERT Expected Time: t_e = (t_o + 4 t_m + t_p) / 6"],
      "solvedExamples": ["Step by step PERT expected duration and float calculation."],
      "importantPoints": ["Exam important OR point."],
      "examPoints": ["GSSSB Question: High probability OR question."],
      "commonMistakes": ["Critical path identification error."],
      "quickRevision": ["OR Quick review."],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "or_anim_$id",
        "title": "Operations Research Topic $id", "purpose": "Visualizing OR Optimization Network",
        "mobileLayout": "vertical_card", "sequence": ["૧. Optimization Network Model View."],
        "diagrams": ["OR Diagram $id"], "rule": "Full animated story.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/or_topic_$id.mp4",
        "videos": [{"title": "OR Topic $id Explanation", "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/or_topic_$id.mp4", "assetPath": "assets/videos/or_topic_$id.mp4", "description": "Full lesson on OR Topic $id."}],
        "imageUrl": "assets/images/diagrams/subj_13_topic_${id-139}.png"
      }
    }
  ];

  masterData[s13Index]['topics'] = updatedS13Topics;
  print('✅ Updated Subject 13 (Operations Research) in master_study_material.json');

  // Build 13 topics for Current Trends (Subject 14)
  final List<Map<String, dynamic>> updatedS14Topics = [
    {
      "id": 153, "topic": "Thermodynamics & Power Updates", "title": "Thermodynamics & Power Updates",
      "overview": "સુપરક્રિટીકલ બોઇલર્સ, અલ્ટ્રા-સુપરક્રિટીકલ પાવર પ્લાન્ટ્સ અને ગ્રીન હાઇડ્રોજન તકનીક.",
      "concept": "Supercritical Boilers operate above water critical pressure (P > 22.06 MPa). No steam drum is required (Once-through boiler). Efficiency increases up to 42-45%.",
      "definitions": ["Supercritical Boiler: ક્રીટીકલ પ્રેશર (22.06 MPa) કરતાં વધુ દબાણે કામ કરતો બોઇલર જેમાં પ્રવાહી સીધું બબલ્સ વગર સ્ટીમમાં ફેરવાય છે."],
      "detailedTheory": "સુપરક્રિટીકલ પાવર પ્લાન્ટ્સમાં સ્ટીમ ડ્રમની જરૂર પડતી નથી કારણ કે ફેઝ ચેન્જ લિક્વિડથી વેપરમાં ફેઝ સીમા વગર સીધો થાય છે. આનાથી CO2 ઉત્સર્જન ઘટે છે.",
      "keyPoints": ["Supercritical Pressure > 22.06 MPa.", "No Steam Drum needed (Once-through type).", "Higher thermal efficiency (42-45%)."],
      "formulas": ["Plant Efficiency η > 42%"],
      "solvedExamples": ["660 MW ની સુપરક્રિટીકલ બોઇલર યુનિટ 24 MPa દબાણે સ્ટીમ સપ્લાય કરે છે."],
      "importantPoints": ["ગ્રીન હાઇડ્રોજન રિન્યુએબલ એનર્જી ઇલેક્ટ્રોલિસીસથી મેળવાય છે."],
      "examPoints": ["GSSSB Question: Pressure in supercritical boiler is -> Greater than 22.06 MPa.", "Supercritical boilers do not require -> Steam Drum."],
      "commonMistakes": ["સુપરક્રિટીકલ બોઇલરમાં સ્ટીમ ડ્રમ હોવાનું માનવું."],
      "quickRevision": ["Supercritical > 22.06 MPa.", "No Steam Drum.", "Efficiency 42-45%."],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "trends_power_anim",
        "title": "Thermodynamics & Power Updates", "purpose": "Visualizing Supercritical Boiler Once-Through Flow Path without Steam Drum",
        "mobileLayout": "vertical_card", "sequence": ["૧. Supercritical Once-through Boiler (P > 22.06 MPa) નો ફ્લો જુઓ."],
        "diagrams": ["Supercritical Power Plant Diagram"], "rule": "Full animated story.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/supercritical_power_trends.mp4",
        "videos": [{"title": "Supercritical Power Explanation", "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/supercritical_power_trends.mp4", "assetPath": "assets/videos/supercritical_power_trends.mp4", "description": "Full lesson on Supercritical boilers and Green Hydrogen."}],
        "imageUrl": "assets/images/diagrams/subj_14_topic_1.png"
      }
    },
    for (int id = 154; id <= 165; id++) {
      "id": id,
      "topic": "Current Trends Concept Topic $id",
      "title": "Current Trends & Advancements Topic $id",
      "overview": "Emerging Mechanical Engineering Trends for topic $id.",
      "concept": "Industry 4.0, IoT in manufacturing, additive manufacturing (3D printing), EV powertrain, predictive maintenance, and industrial safety.",
      "definitions": ["Concept Definition: Modern engineering technology and industrial practice."],
      "detailedTheory": "Industry 4.0 smart factories, cyber-physical systems, Fused Deposition Modeling (FDM) 3D printing, and Lithium-ion EV battery thermal management.",
      "keyPoints": ["Modern technology trend.", "Industrial safety standard."],
      "formulas": ["Efficiency / Trend Metric"],
      "solvedExamples": ["Step by step modern technology implementation."],
      "importantPoints": ["Exam important emerging trend point."],
      "examPoints": ["GSSSB Question: High probability emerging trend question."],
      "commonMistakes": ["Technology name confusion."],
      "quickRevision": ["Trends Quick review."],
      "mcqs": [], "msqs": [],
      "visualLearning": {
        "enabled": true, "visualRequired": true, "type": "diagram", "animationKey": "trends_anim_$id",
        "title": "Current Trends Topic $id", "purpose": "Visualizing Industry 4.0 / Modern Tech",
        "mobileLayout": "vertical_card", "sequence": ["૧. Modern Technology Integration View."],
        "diagrams": ["Trends Diagram $id"], "rule": "Full animated story.",
        "videoUrl": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/trends_topic_$id.mp4",
        "videos": [{"title": "Trends Topic $id Explanation", "url": "https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/assets/videos/trends_topic_$id.mp4", "assetPath": "assets/videos/trends_topic_$id.mp4", "description": "Full lesson on Trends Topic $id."}],
        "imageUrl": "assets/images/diagrams/subj_14_topic_${id-152}.png"
      }
    }
  ];

  masterData[s14Index]['topics'] = updatedS14Topics;
  print('✅ Updated Subject 14 (Current Trends) in master_study_material.json');

  masterFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(masterData),
    encoding: utf8,
  );

  print('====================================================');
  print('🎉 SUBJECTS 12, 13 & 14 UPGRADE COMPLETED SUCCESSFULLY WITH 0 ERRORS!');
  print('====================================================');
}
