import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/competition.dart';

class CompetitionBackendService {
  // Default shared Firebase Realtime DB endpoint for synchronized leaderboards
  static const String _defaultBaseUrl =
      'https://hammesh-aae-default-rtdb.firebaseio.com';

  static String _baseUrl = _defaultBaseUrl;

  static void setCustomBaseUrl(String url) {
    if (url.trim().isNotEmpty) {
      _baseUrl = url.trim().endsWith('/') ? url.trim().substring(0, url.trim().length - 1) : url.trim();
    }
  }

  static String get baseUrl => _baseUrl;

  /// Registers or updates a member on the global leaderboard.
  static Future<bool> registerGlobalMember(CompetitionMember member) async {
    try {
      final url = Uri.parse('$_baseUrl/global_leaderboard/members/${member.id}.json');
      final body = jsonEncode(member.toJson());
      final response = await http
          .put(url, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 8));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('Error registering global member: $e');
      return false;
    }
  }

  /// Fetches all members registered on the global leaderboard.
  static Future<Map<String, CompetitionMember>> fetchGlobalMembers() async {
    try {
      final url = Uri.parse('$_baseUrl/global_leaderboard/members.json');
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 && response.body != 'null' && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        Map<String, CompetitionMember> members = {};
        if (decoded is Map) {
          decoded.forEach((key, value) {
            if (value is Map) {
              final m = CompetitionMember.fromJson(Map<String, dynamic>.from(value));
              members[m.id] = m;
            }
          });
        }
        return members;
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching global members: $e');
      return {};
    }
  }

  /// Submits a test result to the global leaderboard database.
  static Future<bool> submitGlobalResult(CompetitionResult result) async {
    try {
      final url = Uri.parse('$_baseUrl/global_leaderboard/results/${result.id}.json');
      final body = jsonEncode(result.toJson());
      final response = await http
          .put(url, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 8));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('Error submitting global result: $e');
      return false;
    }
  }

  /// Fetches all test results from the global leaderboard database.
  static Future<List<CompetitionResult>> fetchGlobalResults() async {
    try {
      final url = Uri.parse('$_baseUrl/global_leaderboard/results.json');
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 && response.body != 'null' && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        List<CompetitionResult> results = [];
        if (decoded is Map) {
          decoded.forEach((key, value) {
            if (value is Map) {
              results.add(CompetitionResult.fromJson(Map<String, dynamic>.from(value)));
            }
          });
        }
        return results;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching global results: $e');
      return [];
    }
  }
}
