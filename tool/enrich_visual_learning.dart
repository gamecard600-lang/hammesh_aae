// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/study_material/master_study_material.json');
  if (!file.existsSync()) {
    print('master_study_material.json not found.');
    return;
  }

  final String content = file.readAsStringSync(encoding: utf8);
  final List<dynamic> masterData = jsonDecode(content);

  int enriched = 0;

  for (final subjectEntry in masterData) {
    if (subjectEntry is! Map<String, dynamic>) continue;
    final List<dynamic> topics = subjectEntry['topics'] ?? [];

    for (final topicEntry in topics) {
      if (topicEntry is! Map<String, dynamic>) continue;
      final String topicName = (topicEntry['topic'] ?? '').toString();
      final String title = (topicEntry['title'] ?? '').toString();
      final String text = '$topicName $title'.toLowerCase();

      String? animKey;
      String type = 'animation';
      List<String> diagrams = ['pv', 'ts'];
      List<String> sequence = [
        'Phase 1: Initial System State & Setup',
        'Phase 2: Thermodynamic Transformation / Work Input',
        'Phase 3: High Energy / Peak Condition',
        'Phase 4: Work Output / Exhaust / Return to Base',
      ];

      if (text.contains('carnot')) {
        animKey = 'carnot_cycle';
        type = 'cycle';
        sequence = [
          'Process 1-2: Isothermal Expansion (Heat Addition Qin at TH)',
          'Process 2-3: Isentropic Expansion (Turbine / Piston Work Output)',
          'Process 3-4: Isothermal Compression (Heat Rejection Qout at TL)',
          'Process 4-1: Isentropic Compression (Return to initial state)',
        ];
      } else if (text.contains('otto')) {
        animKey = 'otto_cycle';
        type = 'cycle';
        sequence = [
          'Process 1-2: Isentropic Compression (Stroke 1)',
          'Process 2-3: Constant Volume Heat Addition (Spark Ignition)',
          'Process 3-4: Isentropic Expansion (Power Stroke)',
          'Process 4-1: Constant Volume Heat Rejection (Exhaust)',
        ];
      } else if (text.contains('diesel')) {
        animKey = 'diesel_cycle';
        type = 'cycle';
        sequence = [
          'Process 1-2: Isentropic Compression',
          'Process 2-3: Constant Pressure Heat Addition (Fuel Injection)',
          'Process 3-4: Isentropic Expansion (Power Stroke)',
          'Process 4-1: Constant Volume Heat Rejection',
        ];
      } else if (text.contains('dual')) {
        animKey = 'dual_cycle';
        type = 'cycle';
      } else if (text.contains('brayton') || text.contains('gas turbine')) {
        animKey = 'brayton_cycle';
        type = 'cycle';
      } else if (text.contains('rankine') || text.contains('steam turbine')) {
        animKey = 'rankine_cycle';
        type = 'cycle';
      } else if (text.contains('vcr') || text.contains('vapor compression') || text.contains('refrigerat')) {
        animKey = 'vcr_cycle';
        type = 'cycle';
        diagrams = ['ph', 'ts'];
        sequence = [
          'Process 1-2: Isentropic Compression in Compressor',
          'Process 2-3: Constant Pressure Condensation in Condenser',
          'Process 3-4: Isenthalpic Expansion in Expansion Valve',
          'Process 4-1: Constant Pressure Evaporation in Evaporator',
        ];
      } else if (text.contains('psychromet')) {
        animKey = 'psychrometric_chart';
        type = 'graph';
        diagrams = ['graph'];
      } else if (text.contains('mohr')) {
        animKey = 'mohrs_circle';
        type = 'graph';
        diagrams = ['graph'];
      } else if (text.contains('shear force') || text.contains('bending moment') || text.contains('sfd') || text.contains('bmd')) {
        animKey = 'sfd_bmd';
        type = 'graph';
        diagrams = ['graph'];
      } else if (text.contains('stress') && text.contains('strain')) {
        animKey = 'stress_strain_curve';
        type = 'graph';
        diagrams = ['graph'];
      } else if (text.contains('iron') && text.contains('carbon')) {
        animKey = 'iron_carbon_diagram';
        type = 'graph';
        diagrams = ['graph'];
      } else if (text.contains('pump') || text.contains('turbine') || text.contains('fluid machine')) {
        animKey = 'centrifugal_pump';
        type = 'mechanism';
        diagrams = ['schematic'];
      } else if (text.contains('bernoulli') || text.contains('venturi') || text.contains('orific')) {
        animKey = 'bernoulli';
        type = 'diagram';
        diagrams = ['schematic'];
      } else if (text.contains('gear')) {
        animKey = 'gears_train';
        type = 'mechanism';
        diagrams = ['schematic'];
      } else if (text.contains('cam')) {
        animKey = 'cam_follower';
        type = 'mechanism';
        diagrams = ['schematic'];
      } else if (text.contains('cast') || text.contains('mould')) {
        animKey = 'casting_flow';
        type = 'process';
        diagrams = ['schematic'];
      } else if (text.contains('lathe') || text.contains('machining') || text.contains('cutting tool')) {
        animKey = 'lathe_cutting';
        type = 'process';
        diagrams = ['schematic'];
      }

      if (animKey != null) {
        Map<String, dynamic> vl = topicEntry['visualLearning'] is Map<String, dynamic>
            ? topicEntry['visualLearning']
            : {};
        vl['enabled'] = true;
        vl['visualRequired'] = true;
        vl['type'] = type;
        vl['animationKey'] = animKey;
        if ((vl['title'] ?? '').toString().isEmpty) {
          vl['title'] = '$topicName Diagram & Process Visual';
        }
        if ((vl['purpose'] ?? '').toString().isEmpty) {
          vl['purpose'] = 'Visualize $topicName step-by-step engineering principles';
        }
        vl['sequence'] = sequence;
        vl['diagrams'] = diagrams;
        vl['rule'] = vl['rule'] ?? 'Observe the interactive visualization to master $topicName principles.';
        topicEntry['visualLearning'] = vl;
        enriched++;
      }
    }
  }

  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(masterData), encoding: utf8);
  print('Successfully enriched visualLearning for $enriched topics!');
}
