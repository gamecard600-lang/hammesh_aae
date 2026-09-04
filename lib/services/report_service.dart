import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/report_issue.dart';

class ReportService {
  static const String _reportsKey = 'aspirant_reports_v1';
  static String reportApiUrl = 'https://raw.githubusercontent.com/HammeshVasoya/hammesh_aae/main/reports/submit';

  /// Loads all saved reports from local storage.
  static Future<List<ReportIssue>> loadReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawData = prefs.getStringList(_reportsKey);
      if (rawData == null || rawData.isEmpty) return [];

      return rawData
          .map((item) {
            try {
              final Map<String, dynamic> decoded = jsonDecode(item);
              return ReportIssue.fromJson(decoded);
            } catch (e) {
              return null;
            }
          })
          .whereType<ReportIssue>()
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('Error loading reports: $e');
      return [];
    }
  }

  /// Saves a new report locally and attempts online submission.
  static Future<bool> saveReport(ReportIssue report) async {
    try {
      final reports = await loadReports();

      // Duplicate prevention check
      final now = DateTime.tryParse(report.timestamp) ?? DateTime.now();
      final isDuplicate = reports.any((r) {
        if (r.id == report.id) return true;
        final rTime = DateTime.tryParse(r.timestamp) ?? DateTime.now();
        final isRecent = now.difference(rTime).inSeconds.abs() < 10;
        final sameDesc = r.description.trim() == report.description.trim();
        final sameQuestion = r.questionId == report.questionId && r.contentId == report.contentId;
        return isRecent && sameDesc && sameQuestion;
      });

      if (isDuplicate) {
        debugPrint('Duplicate report blocked.');
        return false;
      }

      // Attempt online submission first
      final syncResult = await _submitSingleReportOnline(report);
      final finalReport = report.copyWith(
        isSynced: syncResult,
        status: syncResult ? 'Submitted / Synced' : 'Saved Locally (Pending Sync)',
      );

      reports.insert(0, finalReport);

      final prefs = await SharedPreferences.getInstance();
      final encodedList = reports.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList(_reportsKey, encodedList);

      return true;
    } catch (e) {
      debugPrint('Error saving report: $e');
      return false;
    }
  }

  /// Attempts online submission via HTTP POST
  static Future<bool> _submitSingleReportOnline(ReportIssue report) async {
    try {
      final response = await http
          .post(
            Uri.parse(reportApiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(report.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      debugPrint('Online report submission offline/pending: $e');
    }
    return false;
  }

  /// Automatic retry sync for pending unsynced reports
  static Future<bool> syncPendingReports() async {
    try {
      final reports = await loadReports();
      final unsyncedIndex = reports.indexWhere((r) => !r.isSynced);
      if (unsyncedIndex == -1) return true;

      bool anySynced = false;
      for (int i = 0; i < reports.length; i++) {
        if (!reports[i].isSynced) {
          final success = await _submitSingleReportOnline(reports[i]);
          if (success) {
            reports[i] = reports[i].copyWith(
              isSynced: true,
              status: 'Submitted / Synced',
            );
            anySynced = true;
          }
        }
      }

      if (anySynced) {
        final prefs = await SharedPreferences.getInstance();
        final encodedList = reports.map((r) => jsonEncode(r.toJson())).toList();
        await prefs.setStringList(_reportsKey, encodedList);
      }
      return true;
    } catch (e) {
      debugPrint('Error syncing pending reports: $e');
      return false;
    }
  }

  /// Deletes a specific report by ID
  static Future<void> deleteReport(String id) async {
    try {
      final reports = await loadReports();
      reports.removeWhere((r) => r.id == id);
      final prefs = await SharedPreferences.getInstance();
      final encodedList = reports.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList(_reportsKey, encodedList);
    } catch (e) {
      debugPrint('Error deleting report: $e');
    }
  }

  /// Clears all local reports
  static Future<void> clearReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_reportsKey);
    } catch (e) {
      debugPrint('Error clearing reports: $e');
    }
  }
}
