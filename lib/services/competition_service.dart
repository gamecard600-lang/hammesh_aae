import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/competition.dart';
import '../models/exam_result.dart';
import 'competition_backend_service.dart';

class CompetitionService {
  static const String _myMemberIdKey = 'comp_my_member_id';
  static const String _myDisplayNameKey = 'comp_my_display_name';
  static const String _cachedMembersKey = 'global_cached_members_v1';
  static const String _cachedResultsKey = 'global_cached_results_v1';
  static const String _pendingResultsKey = 'global_pending_results_v1';

  /// Returns or creates a persistent unique Member ID for this device.
  static Future<String> getMemberId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_myMemberIdKey);
    if (id == null || id.isEmpty) {
      final random = Random();
      final time = DateTime.now().millisecondsSinceEpoch.toString();
      final randNum = random.nextInt(9000) + 1000;
      id = 'asp_${time.substring(time.length > 6 ? time.length - 6 : 0)}_$randNum';
      await prefs.setString(_myMemberIdKey, id);
    }
    return id;
  }

  /// Returns current display name saved locally.
  static Future<String> getDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_myDisplayNameKey);
    if (name != null && name.trim().isNotEmpty) {
      return name.trim();
    }
    final memberId = await getMemberId();
    final shortId = memberId.replaceAll('asp_', '');
    return 'Aspirant #$shortId';
  }

  /// Sets local display name & updates on global leaderboard.
  static Future<void> saveDisplayName(String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_myDisplayNameKey, cleanName);

    final memberId = await getMemberId();
    final member = CompetitionMember(
      id: memberId,
      displayName: cleanName,
      joinedAt: DateTime.now().toIso8601String(),
    );

    // Sync online
    CompetitionBackendService.registerGlobalMember(member);
  }

  /// Automatically registers current user on Global Leaderboard.
  static Future<void> autoRegisterGlobalUser() async {
    final memberId = await getMemberId();
    final displayName = await getDisplayName();

    final member = CompetitionMember(
      id: memberId,
      displayName: displayName,
      joinedAt: DateTime.now().toIso8601String(),
    );

    CompetitionBackendService.registerGlobalMember(member);
  }

  /// Records a completed test result for the global leaderboard.
  static Future<void> recordTestResult(ExamResult result) async {
    final memberId = await getMemberId();
    final displayName = await getDisplayName();

    final testKey = '${result.subject.trim()}_${result.subTopic.trim()}';
    final resultId = 'res_${memberId}_${DateTime.now().millisecondsSinceEpoch}';

    final points = CompetitionPointsCalculator.calculateAttemptPoints(
      correct: result.correct,
      totalQuestions: result.totalQuestions,
      accuracy: result.accuracy,
    );

    final compResult = CompetitionResult(
      id: resultId,
      competitionCode: 'GLOBAL',
      memberId: memberId,
      displayName: displayName,
      testKey: testKey,
      subject: result.subject,
      subTopic: result.subTopic,
      timestamp: DateTime.now().toIso8601String(),
      correct: result.correct,
      wrong: result.wrong,
      unattempted: result.skipped,
      totalQuestions: result.totalQuestions,
      score: result.score,
      percentage: result.percentage,
      accuracy: result.accuracy,
      competitionPoints: points,
    );

    // 1. Save result locally to cached results
    final prefs = await SharedPreferences.getInstance();
    List<CompetitionResult> cachedResults = await _loadCachedResults();
    cachedResults.add(compResult);
    await prefs.setString(
      _cachedResultsKey,
      jsonEncode(cachedResults.map((e) => e.toJson()).toList()),
    );

    // 2. Add to pending sync queue
    List<CompetitionResult> pending = await _loadPendingResults();
    pending.add(compResult);
    await prefs.setString(
      _pendingResultsKey,
      jsonEncode(pending.map((e) => e.toJson()).toList()),
    );

    // 3. Attempt background sync
    syncPendingResults();
  }

  /// Syncs pending offline results to backend.
  static Future<void> syncPendingResults() async {
    final prefs = await SharedPreferences.getInstance();
    List<CompetitionResult> pending = await _loadPendingResults();
    if (pending.isEmpty) return;

    List<CompetitionResult> remainingPending = [];

    for (var res in pending) {
      final success = await CompetitionBackendService.submitGlobalResult(res);
      if (!success) {
        remainingPending.add(res);
      }
    }

    await prefs.setString(
      _pendingResultsKey,
      jsonEncode(remainingPending.map((e) => e.toJson()).toList()),
    );
  }

  /// Synchronizes with backend online database and returns updated global leaderboard entries.
  static Future<List<CompetitionLeaderboardEntry>> syncAndFetchLeaderboard() async {
    // 1. Register current user
    await autoRegisterGlobalUser();

    // 2. Try to sync any unsynced local results
    await syncPendingResults();

    // 3. Fetch remote members & results
    final remoteMembers = await CompetitionBackendService.fetchGlobalMembers();
    final remoteResults = await CompetitionBackendService.fetchGlobalResults();

    final prefs = await SharedPreferences.getInstance();

    Map<String, CompetitionMember> members = Map.from(remoteMembers);
    final myId = await getMemberId();
    final myName = await getDisplayName();

    if (!members.containsKey(myId)) {
      members[myId] = CompetitionMember(
        id: myId,
        displayName: myName,
        joinedAt: DateTime.now().toIso8601String(),
      );
    }

    await prefs.setString(
      _cachedMembersKey,
      jsonEncode(members.map((k, v) => MapEntry(k, v.toJson()))),
    );

    List<CompetitionResult> allResults = [];
    if (remoteResults.isNotEmpty) {
      allResults = remoteResults;
      await prefs.setString(
        _cachedResultsKey,
        jsonEncode(remoteResults.map((e) => e.toJson()).toList()),
      );
    } else {
      allResults = await _loadCachedResults();
    }

    // Compute global leaderboard
    return CompetitionPointsCalculator.computeLeaderboard(
      members: members,
      results: allResults,
    );
  }

  /// Loads leaderboard from local cache immediately for fast startup/offline.
  static Future<List<CompetitionLeaderboardEntry>> getLocalLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final rawMembers = prefs.getString(_cachedMembersKey);
    Map<String, CompetitionMember> members = {};

    if (rawMembers != null && rawMembers.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawMembers) as Map;
        decoded.forEach((k, v) {
          if (v is Map) {
            members[k.toString()] = CompetitionMember.fromJson(Map<String, dynamic>.from(v));
          }
        });
      } catch (_) {}
    }

    final myId = await getMemberId();
    final myName = await getDisplayName();
    if (!members.containsKey(myId)) {
      members[myId] = CompetitionMember(
        id: myId,
        displayName: myName,
        joinedAt: DateTime.now().toIso8601String(),
      );
    }

    final results = await _loadCachedResults();
    return CompetitionPointsCalculator.computeLeaderboard(
      members: members,
      results: results,
    );
  }

  static Future<List<CompetitionResult>> _loadCachedResults() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cachedResultsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => CompetitionResult.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<CompetitionResult>> _loadPendingResults() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingResultsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => CompetitionResult.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }
}
