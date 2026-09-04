import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ReportIssue {
  final String id;
  final String category;
  final String description;
  final String? subject;
  final String? topic;
  final int? questionId;
  final String? questionText;
  final String? contentId;
  final String? currentScreen;
  final String appVersion;
  final String timestamp;
  final String platform;
  final String status; // 'Pending', 'Submitted', 'Queued'
  final bool isSynced;

  ReportIssue({
    required this.id,
    required this.category,
    required this.description,
    this.subject,
    this.topic,
    this.questionId,
    this.questionText,
    this.contentId,
    this.currentScreen,
    this.appVersion = '1.0.0',
    required this.timestamp,
    required this.platform,
    this.status = 'Queued',
    this.isSynced = false,
  });

  static String getOperatingPlatform() {
    if (kIsWeb) return 'Web';
    try {
      if (Platform.isAndroid) return 'Android';
      if (Platform.isIOS) return 'iOS';
      if (Platform.isWindows) return 'Windows';
      if (Platform.isMacOS) return 'macOS';
      if (Platform.isLinux) return 'Linux';
    } catch (_) {}
    return 'Unknown';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'subject': subject,
      'topic': topic,
      'questionId': questionId,
      'questionText': questionText,
      'contentId': contentId,
      'currentScreen': currentScreen,
      'appVersion': appVersion,
      'timestamp': timestamp,
      'platform': platform,
      'status': status,
      'isSynced': isSynced,
    };
  }

  factory ReportIssue.fromJson(Map<String, dynamic> json) {
    return ReportIssue(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      category: json['category'] as String? ?? 'Other',
      description: json['description'] as String? ?? '',
      subject: json['subject'] as String?,
      topic: json['topic'] as String?,
      questionId: json['questionId'] as int?,
      questionText: json['questionText'] as String?,
      contentId: json['contentId'] as String?,
      currentScreen: json['currentScreen'] as String?,
      appVersion: json['appVersion'] as String? ?? '1.0.0',
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      platform: json['platform'] as String? ?? 'Unknown',
      status: json['status'] as String? ?? 'Queued',
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }

  ReportIssue copyWith({
    String? id,
    String? category,
    String? description,
    String? subject,
    String? topic,
    int? questionId,
    String? questionText,
    String? contentId,
    String? currentScreen,
    String? appVersion,
    String? timestamp,
    String? platform,
    String? status,
    bool? isSynced,
  }) {
    return ReportIssue(
      id: id ?? this.id,
      category: category ?? this.category,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      questionId: questionId ?? this.questionId,
      questionText: questionText ?? this.questionText,
      contentId: contentId ?? this.contentId,
      currentScreen: currentScreen ?? this.currentScreen,
      appVersion: appVersion ?? this.appVersion,
      timestamp: timestamp ?? this.timestamp,
      platform: platform ?? this.platform,
      status: status ?? this.status,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
