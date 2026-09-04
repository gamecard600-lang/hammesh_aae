import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/competition.dart';
import '../../services/competition_service.dart';

class CompetitionLeaderboardScreen extends StatefulWidget {
  const CompetitionLeaderboardScreen({super.key});

  @override
  State<CompetitionLeaderboardScreen> createState() =>
      _CompetitionLeaderboardScreenState();
}

class _CompetitionLeaderboardScreenState
    extends State<CompetitionLeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CompetitionLeaderboardEntry> _entries = [];
  String? _myMemberId;
  String _myDisplayName = 'Aspirant';
  bool _isLoading = true;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();

    // Auto refresh leaderboard every 15 seconds while on screen
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted && !_isLoading) {
        _syncData(showLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final memberId = await CompetitionService.getMemberId();
    final displayName = await CompetitionService.getDisplayName();
    final localEntries = await CompetitionService.getLocalLeaderboard();

    if (!mounted) return;

    setState(() {
      _myMemberId = memberId;
      _myDisplayName = displayName;
      _entries = localEntries;
      _isLoading = false;
    });

    // Background sync online data
    _syncData(showLoading: false);
  }

  Future<void> _syncData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }

    try {
      final entries = await CompetitionService.syncAndFetchLeaderboard();
      final displayName = await CompetitionService.getDisplayName();

      if (!mounted) return;
      setState(() {
        _myDisplayName = displayName;
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _myDisplayName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Your Display Name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the name you want to display on the Global Leaderboard:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'e.g. Mechanical Aspirant',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await CompetitionService.saveDisplayName(newName);
                if (!context.mounted) return;
                Navigator.pop(context);
                _syncData(showLoading: true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Global Aspirants Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Name',
            onPressed: _showEditNameDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => _syncData(showLoading: true),
          ),
        ],
      ),
      body: _isLoading && _entries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _syncData(showLoading: true),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 16),
                  _buildTabBarSection(),
                  const SizedBox(height: 20),
                  _buildComparisonCard(),
                  const SizedBox(height: 20),
                  _buildBadgesSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    final totalAspirants = _entries.length;
    final myEntry = _entries.firstWhere(
      (e) => e.memberId == _myMemberId,
      orElse: () => CompetitionLeaderboardEntry(
        memberId: _myMemberId ?? '',
        displayName: _myDisplayName,
        totalPoints: 0,
        weeklyPoints: 0,
        testsCompleted: 0,
        weeklyTestsCompleted: 0,
        accuracy: 0,
        weeklyAccuracy: 0,
        rank: totalAspirants + 1,
        weeklyRank: 0,
        badges: [],
        recentPercentages: [],
      ),
    );

    final isWeekly = _tabController.index == 0;
    final myRankStr = isWeekly && myEntry.weeklyRank > 0
        ? '#${myEntry.weeklyRank}'
        : '#${myEntry.rank}';
    final myPoints = isWeekly ? myEntry.weeklyPoints : myEntry.totalPoints;

    return Card(
      color: const Color(0xFF0F172A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber),
                  ),
                  child: const Icon(Icons.emoji_events, color: Colors.amber, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Global Aspirants Ranking',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Live Auto-Sync • $totalAspirants Aspirants Online',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Rank: $myRankStr', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('$myPoints Points | $_myDisplayName',
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showEditNameDialog,
                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text('Edit Name', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarSection() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black87,
            tabs: const [
              Tab(text: 'This Week'),
              Tab(text: 'All Time'),
            ],
            onTap: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 12),
        _tabController.index == 0
            ? _buildLeaderboardList(isWeekly: true)
            : _buildLeaderboardList(isWeekly: false),
      ],
    );
  }

  Widget _buildLeaderboardList({required bool isWeekly}) {
    List<CompetitionLeaderboardEntry> list = List.from(_entries);

    if (isWeekly) {
      list.sort((a, b) {
        if (b.weeklyPoints != a.weeklyPoints) {
          return b.weeklyPoints.compareTo(a.weeklyPoints);
        }
        return b.weeklyAccuracy.compareTo(a.weeklyAccuracy);
      });
    } else {
      list.sort((a, b) {
        if (b.totalPoints != a.totalPoints) {
          return b.totalPoints.compareTo(a.totalPoints);
        }
        return b.accuracy.compareTo(a.accuracy);
      });
    }

    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('No test attempts recorded yet. Start practicing to get on the board!', textAlign: TextAlign.center),
      );
    }

    return Column(
      children: list.asMap().entries.map((item) {
        final idx = item.key;
        final entry = item.value;
        final isMe = entry.memberId == _myMemberId;

        final rank = idx + 1;
        final points = isWeekly ? entry.weeklyPoints : entry.totalPoints;
        final tests = isWeekly ? entry.weeklyTestsCompleted : entry.testsCompleted;
        final acc = isWeekly ? entry.weeklyAccuracy : entry.accuracy;

        return Card(
          elevation: isMe ? 2 : 0,
          color: isMe ? Colors.blue.shade50.withValues(alpha: 0.5) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isMe ? Colors.blue : Colors.grey.shade200,
              width: isMe ? 1.5 : 1.0,
            ),
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: _buildRankBadge(rank),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    '${entry.displayName}${isMe ? ' (You)' : ''}',
                    style: TextStyle(
                      fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                      color: isMe ? Colors.blue.shade900 : null,
                    ),
                  ),
                ),
                Text(
                  '$points Pts',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Tests: $tests | Accuracy: ${acc.toStringAsFixed(0)}%'),
                if (entry.badges.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: entry.badges.map((b) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        b,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRankBadge(int rank) {
    if (rank == 1) {
      return const CircleAvatar(
        backgroundColor: Colors.amber,
        child: Text('🥇', style: TextStyle(fontSize: 20)),
      );
    } else if (rank == 2) {
      return CircleAvatar(
        backgroundColor: Colors.grey.shade300,
        child: const Text('🥈', style: TextStyle(fontSize: 20)),
      );
    } else if (rank == 3) {
      return CircleAvatar(
        backgroundColor: Colors.amber.shade200,
        child: const Text('🥉', style: TextStyle(fontSize: 20)),
      );
    }
    return CircleAvatar(
      backgroundColor: Colors.grey.shade100,
      child: Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildComparisonCard() {
    if (_entries.length < 2) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            '💡 Rankings update automatically as aspirants practice MCQs & Daily Tasks.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final myEntry = _entries.firstWhere(
      (e) => e.memberId == _myMemberId,
      orElse: () => _entries.first,
    );

    final topEntry = _entries.firstWhere(
      (e) => e.memberId != _myMemberId,
      orElse: () => _entries.first,
    );

    final isWeekly = _tabController.index == 0;
    final myPts = isWeekly ? myEntry.weeklyPoints : myEntry.totalPoints;
    final topPts = isWeekly ? topEntry.weeklyPoints : topEntry.totalPoints;

    final myTests = isWeekly ? myEntry.weeklyTestsCompleted : myEntry.testsCompleted;
    final topTests = isWeekly ? topEntry.weeklyTestsCompleted : topEntry.testsCompleted;

    final myAcc = isWeekly ? myEntry.weeklyAccuracy : myEntry.accuracy;
    final topAcc = isWeekly ? topEntry.weeklyAccuracy : topEntry.accuracy;

    final diff = myPts - topPts;
    final String diffText = diff > 0
        ? 'You are leading ${topEntry.displayName} by $diff points 🚀'
        : diff < 0
            ? 'You are trailing ${topEntry.displayName} by ${diff.abs()} points 💪'
            : 'Scores are tied! 🤝';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.compare_arrows, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'You vs ${topEntry.displayName}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: diff >= 0 ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: diff >= 0 ? Colors.green.shade200 : Colors.orange.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    diff >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: diff >= 0 ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      diffText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: diff >= 0 ? Colors.green.shade900 : Colors.orange.shade900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCompRow('Total Points', '$myPts Pts', '$topPts Pts'),
            const Divider(height: 16),
            _buildCompRow('Tests Completed', '$myTests Tests', '$topTests Tests'),
            const Divider(height: 16),
            _buildCompRow('Average Accuracy', '${myAcc.toStringAsFixed(0)}%', '${topAcc.toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildCompRow(String label, String myValue, String friendValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(myValue, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ),
        Expanded(
          flex: 3,
          child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        Expanded(
          flex: 2,
          child: Text(friendValue, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    final myEntry = _entries.firstWhere(
      (e) => e.memberId == _myMemberId,
      orElse: () => CompetitionLeaderboardEntry(
        memberId: '',
        displayName: '',
        totalPoints: 0,
        weeklyPoints: 0,
        testsCompleted: 0,
        weeklyTestsCompleted: 0,
        accuracy: 0,
        weeklyAccuracy: 0,
        rank: 0,
        weeklyRank: 0,
        badges: [],
        recentPercentages: [],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Badges & Achievements',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            myEntry.badges.isEmpty
                ? const Text(
                    'No badges unlocked yet. Complete your first test attempt to unlock the 🏅 First Test badge!',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: myEntry.badges.map((badge) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                          fontSize: 13,
                        ),
                      ),
                    )).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
