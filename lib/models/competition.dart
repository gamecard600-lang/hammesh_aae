class Competition {
  final String joinCode;
  final String name;
  final String creatorId;
  final String createdAt;
  final Map<String, CompetitionMember> members;

  Competition({
    required this.joinCode,
    required this.name,
    required this.creatorId,
    required this.createdAt,
    required this.members,
  });

  Map<String, dynamic> toJson() {
    return {
      'joinCode': joinCode,
      'name': name,
      'creatorId': creatorId,
      'createdAt': createdAt,
      'members': members.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  factory Competition.fromJson(Map<String, dynamic> json) {
    Map<String, CompetitionMember> memberMap = {};
    if (json['members'] != null) {
      if (json['members'] is Map) {
        (json['members'] as Map).forEach((key, value) {
          if (value is Map) {
            memberMap[key.toString()] = CompetitionMember.fromJson(
              Map<String, dynamic>.from(value),
            );
          }
        });
      } else if (json['members'] is List) {
        for (var item in (json['members'] as List)) {
          if (item is Map) {
            final m = CompetitionMember.fromJson(Map<String, dynamic>.from(item));
            memberMap[m.id] = m;
          }
        }
      }
    }

    return Competition(
      joinCode: json['joinCode'] ?? json['code'] ?? '',
      name: json['name'] ?? '',
      creatorId: json['creatorId'] ?? '',
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      members: memberMap,
    );
  }
}

class CompetitionMember {
  final String id;
  final String displayName;
  final String joinedAt;

  CompetitionMember({
    required this.id,
    required this.displayName,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'joinedAt': joinedAt,
    };
  }

  factory CompetitionMember.fromJson(Map<String, dynamic> json) {
    return CompetitionMember(
      id: json['id'] ?? '',
      displayName: json['displayName'] ?? '',
      joinedAt: json['joinedAt'] ?? DateTime.now().toIso8601String(),
    );
  }
}

class CompetitionResult {
  final String id;
  final String competitionCode;
  final String memberId;
  final String displayName;
  final String testKey;
  final String subject;
  final String subTopic;
  final String timestamp;
  final int correct;
  final int wrong;
  final int unattempted;
  final int totalQuestions;
  final double score;
  final double percentage;
  final double accuracy;
  final int competitionPoints;

  CompetitionResult({
    required this.id,
    required this.competitionCode,
    required this.memberId,
    required this.displayName,
    required this.testKey,
    required this.subject,
    required this.subTopic,
    required this.timestamp,
    required this.correct,
    required this.wrong,
    required this.unattempted,
    required this.totalQuestions,
    required this.score,
    required this.percentage,
    required this.accuracy,
    required this.competitionPoints,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'competitionCode': competitionCode,
      'memberId': memberId,
      'displayName': displayName,
      'testKey': testKey,
      'subject': subject,
      'subTopic': subTopic,
      'timestamp': timestamp,
      'correct': correct,
      'wrong': wrong,
      'unattempted': unattempted,
      'totalQuestions': totalQuestions,
      'score': score,
      'percentage': percentage,
      'accuracy': accuracy,
      'competitionPoints': competitionPoints,
    };
  }

  factory CompetitionResult.fromJson(Map<String, dynamic> json) {
    return CompetitionResult(
      id: json['id'] ?? '',
      competitionCode: json['competitionCode'] ?? '',
      memberId: json['memberId'] ?? '',
      displayName: json['displayName'] ?? '',
      testKey: json['testKey'] ?? '',
      subject: json['subject'] ?? '',
      subTopic: json['subTopic'] ?? '',
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      correct: (json['correct'] ?? 0) as int,
      wrong: (json['wrong'] ?? 0) as int,
      unattempted: (json['unattempted'] ?? 0) as int,
      totalQuestions: (json['totalQuestions'] ?? 0) as int,
      score: (json['score'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      competitionPoints: (json['competitionPoints'] ?? 0) as int,
    );
  }
}

class CompetitionLeaderboardEntry {
  final String memberId;
  final String displayName;
  final int totalPoints;
  final int weeklyPoints;
  final int testsCompleted;
  final int weeklyTestsCompleted;
  final double accuracy;
  final double weeklyAccuracy;
  final int rank;
  final int weeklyRank;
  final List<String> badges;
  final List<double> recentPercentages;

  CompetitionLeaderboardEntry({
    required this.memberId,
    required this.displayName,
    required this.totalPoints,
    required this.weeklyPoints,
    required this.testsCompleted,
    required this.weeklyTestsCompleted,
    required this.accuracy,
    required this.weeklyAccuracy,
    required this.rank,
    required this.weeklyRank,
    required this.badges,
    required this.recentPercentages,
  });
}

class CompetitionPointsCalculator {
  /// Calculates competition points for an individual test attempt.
  /// Standard Formula:
  /// - 10 points per correct answer
  /// - Accuracy Bonus: +25 if >=90%, +15 if >=80%, +10 if >=70%
  /// - Completion Bonus: +10 points
  static int calculateAttemptPoints({
    required int correct,
    required int totalQuestions,
    required double accuracy,
  }) {
    if (totalQuestions <= 0) return 0;

    int basePoints = correct * 10;
    int accuracyBonus = 0;
    if (accuracy >= 90) {
      accuracyBonus = 25;
    } else if (accuracy >= 80) {
      accuracyBonus = 15;
    } else if (accuracy >= 70) {
      accuracyBonus = 10;
    }
    int completionBonus = 10;

    return basePoints + accuracyBonus + completionBonus;
  }

  /// Calculates leaderboard entries from a list of competition results and members.
  /// Enforces repeat test protection: For each unique topic (testKey), only the
  /// BEST attempt points are credited to the member's total/weekly score.
  static List<CompetitionLeaderboardEntry> computeLeaderboard({
    required Map<String, CompetitionMember> members,
    required List<CompetitionResult> results,
  }) {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    Map<String, Map<String, CompetitionResult>> memberBestAllTime = {};
    Map<String, Map<String, CompetitionResult>> memberBestWeekly = {};

    Map<String, List<CompetitionResult>> memberAllResults = {};

    for (var memberId in members.keys) {
      memberBestAllTime[memberId] = {};
      memberBestWeekly[memberId] = {};
      memberAllResults[memberId] = [];
    }

    for (var res in results) {
      final mId = res.memberId;
      if (!members.containsKey(mId)) {
        // Also include members who submitted results even if not in members list
        members[mId] = CompetitionMember(
          id: mId,
          displayName: res.displayName,
          joinedAt: res.timestamp,
        );
        memberBestAllTime[mId] = {};
        memberBestWeekly[mId] = {};
        memberAllResults[mId] = [];
      }

      memberAllResults[mId]!.add(res);

      // Best attempt all-time for this testKey
      final existingAll = memberBestAllTime[mId]![res.testKey];
      if (existingAll == null || res.competitionPoints > existingAll.competitionPoints) {
        memberBestAllTime[mId]![res.testKey] = res;
      }

      // Check if weekly
      DateTime? resDate;
      try {
        resDate = DateTime.parse(res.timestamp);
      } catch (_) {}

      if (resDate != null && resDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1)))) {
        final existingWeekly = memberBestWeekly[mId]![res.testKey];
        if (existingWeekly == null || res.competitionPoints > existingWeekly.competitionPoints) {
          memberBestWeekly[mId]![res.testKey] = res;
        }
      }
    }

    List<CompetitionLeaderboardEntry> entries = [];

    for (var entry in members.entries) {
      final mId = entry.key;
      final mName = entry.value.displayName;

      final allBestMap = memberBestAllTime[mId] ?? {};
      final weeklyBestMap = memberBestWeekly[mId] ?? {};
      final allUserResults = memberAllResults[mId] ?? [];

      int totalPoints = 0;
      int totalCorrect = 0;
      int totalAttempted = 0;
      for (var r in allBestMap.values) {
        totalPoints += r.competitionPoints;
        totalCorrect += r.correct;
        totalAttempted += (r.correct + r.wrong);
      }

      int weeklyPoints = 0;
      int weeklyCorrect = 0;
      int weeklyAttempted = 0;
      for (var r in weeklyBestMap.values) {
        weeklyPoints += r.competitionPoints;
        weeklyCorrect += r.correct;
        weeklyAttempted += (r.correct + r.wrong);
      }

      double accuracy = totalAttempted > 0 ? (totalCorrect / totalAttempted) * 100 : 0.0;
      double weeklyAccuracy = weeklyAttempted > 0 ? (weeklyCorrect / weeklyAttempted) * 100 : 0.0;

      // Recent percentages (up to last 5 attempts)
      allUserResults.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final recentPercentages = allUserResults.take(5).map((e) => e.percentage).toList();

      // Badges
      List<String> badges = [];
      if (allBestMap.isNotEmpty) {
        badges.add('🏅 First Test');
      }
      if (accuracy >= 90 && allBestMap.isNotEmpty) {
        badges.add('🎯 90% Accuracy');
      }
      int totalQuestionsSolved = allUserResults.fold(0, (sum, item) => sum + item.totalQuestions);
      if (totalQuestionsSolved >= 100) {
        badges.add('📚 100 Questions');
      }
      // Streak calculation
      if (_hasSevenDayStreak(allUserResults)) {
        badges.add('🔥 7 Day Streak');
      }

      entries.add(CompetitionLeaderboardEntry(
        memberId: mId,
        displayName: mName,
        totalPoints: totalPoints,
        weeklyPoints: weeklyPoints,
        testsCompleted: allBestMap.length,
        weeklyTestsCompleted: weeklyBestMap.length,
        accuracy: accuracy,
        weeklyAccuracy: weeklyAccuracy,
        rank: 0,
        weeklyRank: 0,
        badges: badges,
        recentPercentages: recentPercentages,
      ));
    }

    // Rank All-Time
    entries.sort((a, b) {
      if (b.totalPoints != a.totalPoints) {
        return b.totalPoints.compareTo(a.totalPoints);
      }
      return b.accuracy.compareTo(a.accuracy);
    });

    List<CompetitionLeaderboardEntry> rankedEntries = [];
    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      rankedEntries.add(CompetitionLeaderboardEntry(
        memberId: e.memberId,
        displayName: e.displayName,
        totalPoints: e.totalPoints,
        weeklyPoints: e.weeklyPoints,
        testsCompleted: e.testsCompleted,
        weeklyTestsCompleted: e.weeklyTestsCompleted,
        accuracy: e.accuracy,
        weeklyAccuracy: e.weeklyAccuracy,
        rank: i + 1,
        weeklyRank: 0,
        badges: e.badges,
        recentPercentages: e.recentPercentages,
      ));
    }

    // Calculate Weekly Ranks & Weekly Champion Badge
    var weeklySorted = List<CompetitionLeaderboardEntry>.from(rankedEntries);
    weeklySorted.sort((a, b) {
      if (b.weeklyPoints != a.weeklyPoints) {
        return b.weeklyPoints.compareTo(a.weeklyPoints);
      }
      return b.weeklyAccuracy.compareTo(a.weeklyAccuracy);
    });

    Map<String, int> weeklyRankMap = {};
    for (int i = 0; i < weeklySorted.length; i++) {
      weeklyRankMap[weeklySorted[i].memberId] = i + 1;
    }

    final String? weeklyChampionId = weeklySorted.isNotEmpty && weeklySorted.first.weeklyPoints > 0
        ? weeklySorted.first.memberId
        : null;

    final finalEntries = rankedEntries.map((e) {
      final wRank = weeklyRankMap[e.memberId] ?? 0;
      final updatedBadges = List<String>.from(e.badges);
      if (e.memberId == weeklyChampionId && !updatedBadges.contains('🏆 Weekly Champion')) {
        updatedBadges.add('🏆 Weekly Champion');
      }
      return CompetitionLeaderboardEntry(
        memberId: e.memberId,
        displayName: e.displayName,
        totalPoints: e.totalPoints,
        weeklyPoints: e.weeklyPoints,
        testsCompleted: e.testsCompleted,
        weeklyTestsCompleted: e.weeklyTestsCompleted,
        accuracy: e.accuracy,
        weeklyAccuracy: e.weeklyAccuracy,
        rank: e.rank,
        weeklyRank: wRank,
        badges: updatedBadges,
        recentPercentages: e.recentPercentages,
      );
    }).toList();

    return finalEntries;
  }

  static bool _hasSevenDayStreak(List<CompetitionResult> results) {
    if (results.isEmpty) return false;
    Set<String> testDates = {};
    for (var r in results) {
      try {
        final dt = DateTime.parse(r.timestamp);
        final dateStr = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
        testDates.add(dateStr);
      } catch (_) {}
    }

    if (testDates.length < 7) return false;

    // Check if there are 7 consecutive days
    List<DateTime> dates = testDates.map((d) => DateTime.parse(d)).toList();
    dates.sort((a, b) => b.compareTo(a)); // Newest first

    int currentStreak = 1;
    for (int i = 0; i < dates.length - 1; i++) {
      final diff = dates[i].difference(dates[i + 1]).inDays;
      if (diff == 1) {
        currentStreak++;
        if (currentStreak >= 7) return true;
      } else if (diff > 1) {
        currentStreak = 1;
      }
    }
    return currentStreak >= 7;
  }
}
