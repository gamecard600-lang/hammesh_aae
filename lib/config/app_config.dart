class AppConfig {
  static const String appName = 'hammesh_aae';
  static const String appTitle = 'GSSSB AAE Mechanical Exam Prep';
  static const String currentAppVersion = '1.0.0';
  static const int currentVersionCode = 1;
  static const int defaultContentVersion = 10;

  // Remote version manifest endpoint for automatic background updates
  static String updateManifestUrl = 'https://raw.githubusercontent.com/gamecard600-lang/hammesh_aae/main/app/version.json';
  
  // Configurable share URL for APK Distribution
  static String shareUrl = 'https://github.com/gamecard600-lang/hammesh_aae/releases/latest';
  
  static const String shareMessage =
      '🎯 GSSSB AAE Mechanical Exam Prep App!\n\n'
      'Prepare for GSSSB AAE with 165+ technical topics, mock tests, mistake notebook, formula sheet, and AI Study Assistant.\n\n'
      'Download and start preparing today!';

  static String get fullShareText => '$shareMessage\n\nDownload link: $shareUrl';
}
