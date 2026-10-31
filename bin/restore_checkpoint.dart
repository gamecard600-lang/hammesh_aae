import 'dart:io';

void main() {
  final bakFile = File('assets/study_material/master_study_material.json.bak');
  final targetFile = File('assets/study_material/master_study_material.json');

  if (bakFile.existsSync()) {
    targetFile.writeAsStringSync(bakFile.readAsStringSync());
    print('✅ Successfully restored master_study_material.json from backup checkpoint!');
  } else {
    print('Backup file missing!');
  }
}
