import 'dart:io';

void main() {
  print('====================================================');
  print('🧹 CLEANING UNUSED & TEMPORARY ASSETS');
  print('====================================================');

  int deletedBytes = 0;
  int deletedFilesCount = 0;

  void deleteFile(File f) {
    if (f.existsSync()) {
      final len = f.lengthSync();
      deletedBytes += len;
      deletedFilesCount++;
      f.deleteSync();
      print('Deleted: ${f.path} (${(len / (1024 * 1024)).toStringAsFixed(2)} MB)');
    }
  }

  // 1. Delete backup files
  deleteFile(File('assets/questions.zip'));
  deleteFile(File('assets/study_material/master_study_material.json.before_detail_backup'));

  // 2. Clean temporary .mp3 and unneeded .mp4 files in assets/videos/
  final videosDir = Directory('assets/videos');
  if (videosDir.existsSync()) {
    final preservedVideos = {
      'thermodynamic_systems.mp4',
      'ic_engine_combustion_knocking.mp4',
      'ic_engine_testing_and_performance.mp4',
      'air_standard_cycles.mp4',
    };

    for (final entity in videosDir.listSync()) {
      if (entity is File) {
        final filename = entity.path.replaceAll('\\', '/').split('/').last;

        if (filename.endsWith('.mp3')) {
          deleteFile(entity);
        } else if (filename.endsWith('.mp4') && !preservedVideos.contains(filename)) {
          deleteFile(entity);
        }
      }
    }
  }

  print('\n====================================================');
  print('✅ CLEANUP COMPLETE!');
  print('   • Total Files Deleted : $deletedFilesCount');
  print('   • Total Size Saved    : ${(deletedBytes / (1024 * 1024)).toStringAsFixed(2)} MB ($deletedBytes bytes)');
  print('====================================================');
}
