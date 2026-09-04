import 'package:flutter/material.dart';
import 'screens/subjects_screen.dart';
import 'screens/bookmarks_screen.dart';
import 'screens/mistakes_screen.dart';
import 'screens/mock_test_setup_screen.dart';
import 'screens/settings_screen.dart';

import 'screens/question_practice_screen.dart';
import 'screens/result_screen.dart';
import 'screens/study_material/study_material_subjects_screen.dart';
import 'models/exam_history.dart';
import 'models/exam_result.dart';
import 'models/study_progress.dart';
import 'models/practice_mode.dart';
import 'models/daily_task.dart';
import 'services/local_storage_service.dart';
import 'services/question_service.dart';
import 'services/competition_service.dart';
import 'services/apk_share_service.dart';
import 'services/daily_task_service.dart';
import 'services/chat_notification_service.dart';
import 'services/auto_update_service.dart';
import 'screens/competition/competition_leaderboard_screen.dart';
import 'screens/ai_assistant/ai_dashboard_view.dart';
import 'screens/chat/chat_screen.dart';

void main() {
  runApp(const GsssbAaeApp());
}

class GsssbAaeApp extends StatefulWidget {
  const GsssbAaeApp({super.key});

  @override
  State<GsssbAaeApp> createState() => _GsssbAaeAppState();
}

class _GsssbAaeAppState extends State<GsssbAaeApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final mode = await LocalStorageService.loadThemeMode();
    if (mounted) {
      setState(() {
        _themeMode = mode == 'dark' ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  void _updateThemeMode(String mode) {
    setState(() {
      _themeMode = mode == 'dark' ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GSSSB AAE Mechanical',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
          primary: const Color(0xFF0F172A),
          secondary: const Color(0xFF2563EB),
          surfaceContainerHighest: const Color(0xFFF1F5F9),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF38BDF8),
          brightness: Brightness.dark,
          primary: const Color(0xFF38BDF8),
          surface: const Color(0xFF0F172A),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF020617),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          color: const Color(0xFF0F172A),
        ),
      ),
      themeMode: _themeMode,
      home: MainNavigationScreen(onThemeChanged: _updateThemeMode),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final Function(String mode)? onThemeChanged;

  const MainNavigationScreen({super.key, this.onThemeChanged});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ChatNotificationService.startNotificationListener(context);
        AutoUpdateService.checkForUpdates();
      }
    });
  }

  @override
  void dispose() {
    ChatNotificationService.stopNotificationListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(onNavigateTab: (index) {
        setState(() => _currentIndex = index);
      }),
      const StudyMaterialSubjectsScreen(category: 'Technical'),
      const ChatScreen(),
      const CompetitionLeaderboardScreen(),
      SettingsScreen(
        onDataChanged: () => setState(() {}),
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.blue),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Colors.blue),
            label: 'Study',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: Colors.blue),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events, color: Colors.blue),
            label: 'Leaderboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_outlined),
            selectedIcon: Icon(Icons.more_horiz, color: Colors.blue),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const HomePage({super.key, this.onNavigateTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bookmarkCount = 0;
  int _mistakeCount = 0;
  int _completedTopics = 0;
  final int _totalTopics = 165;
  List<ExamHistory> _recentTests = [];
  double _avgScore = 0;
  int _totalSolved = 0;
  int _totalCorrect = 0;
  double _accuracy = 0;
  DailyTaskSession? _dailyTaskSession;
  // ignore: unused_field
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        LocalStorageService.loadBookmarks(),
        LocalStorageService.loadMistakes(),
        LocalStorageService.loadTopicMistakes(),
        LocalStorageService.loadExamHistory(),
        LocalStorageService.loadStudyProgress(),
        DailyTaskService.getTodaySession(),
      ]);

      final bookmarks = results[0] as Set<int>;
      final mistakes = results[1] as Set<int>;
      final history = results[3] as List<ExamHistory>;
      final progress = results[4] as List<StudyProgress>;
      final dailySession = results[5] as DailyTaskSession;

      double totalScore = 0;
      int solved = 0;
      int correct = 0;

      if (history.isNotEmpty) {
        for (final h in history) {
          totalScore += h.percentage;
          solved += h.totalQuestions;
          correct += h.correct;
        }
      }

      final today = DailyTaskService.getTodayDateString();
      final todayHistory = history.where((h) => h.subTopic.contains('Daily Task ($today)')).toList();
      DailyTaskSession updatedSession = dailySession;
      if (todayHistory.isNotEmpty) {
        final lastAttempt = todayHistory.first;
        updatedSession = DailyTaskSession(
          date: today,
          questionIds: dailySession.questionIds,
          completed: true,
          correctCount: lastAttempt.correct,
          wrongCount: lastAttempt.wrong,
          score: lastAttempt.score,
          accuracy: lastAttempt.accuracy,
        );
        await DailyTaskService.saveSession(updatedSession);
      }

      // Async background sync for competition results
      CompetitionService.syncPendingResults();

      if (!mounted) return;

      setState(() {
        _bookmarkCount = bookmarks.length;
        _mistakeCount = mistakes.length;
        _completedTopics = progress.where((p) => p.completed).length;
        _recentTests = history.take(3).toList();
        _avgScore = history.isEmpty ? 0 : totalScore / history.length;
        _totalSolved = solved;
        _totalCorrect = correct;
        _accuracy = solved > 0 ? (correct / solved) * 100 : 0;
        _dailyTaskSession = updatedSession;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading home data: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> _startDailyTask() async {
    final session = _dailyTaskSession ?? await DailyTaskService.getTodaySession();
    if (!mounted) return;
    if (session.questionIds.isEmpty) {
      _showSnackBar('No daily task questions available.');
      return;
    }

    setState(() => _isLoading = true);
    final questions = await QuestionService.getQuestionsByIds(session.questionIds);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (questions.isEmpty) {
      _showSnackBar('Failed to load daily task questions.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionPracticeScreen(
          questions: questions,
          subject: 'GSSSB AAE',
          subTopic: 'Daily Task (${session.date})',
          config: PracticeConfig.topicTest,
        ),
      ),
    ).then((_) {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double overallProgress = _totalTopics > 0 ? _completedTopics / _totalTopics : 0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF0F172A),
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, AAE Aspirant!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('Prepare smartly today...', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share App',
            onPressed: () {
              ApkShareService.shareInstalledApk();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildExamCountdownBanner(),
            const SizedBox(height: 16),
            const AiDashboardView(),
            const SizedBox(height: 16),
            _buildProgressCard(overallProgress),
            const SizedBox(height: 16),
            _buildDailyTaskCard(),
            const SizedBox(height: 20),
            _buildQuickAccessSection(),
            const SizedBox(height: 20),
            _buildTechnicalCard(),
            if (_recentTests.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildRecentActivity(),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCountdownBanner() {
    final examDate = DateTime(2026, 12, 7);
    final now = DateTime.now();
    final daysRemaining = examDate.difference(now).inDays;

    if (daysRemaining <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer, color: Colors.amber.shade900, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'GSSSB AAE Exam: $daysRemaining Days Left! (07.12.2026)',
                style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(double overallProgress) {
    final percentageInt = (overallProgress * 100).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: CircularProgressIndicator(
                      value: overallProgress,
                      strokeWidth: 5,
                      backgroundColor: Colors.blue.shade50,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                    ),
                  ),
                  Text(
                    '$percentageInt%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Progress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Solved: $_totalSolved', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('Correct: $_totalCorrect', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('Accuracy: ${_accuracy.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('Avg: ${_avgScore.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTaskCard() {
    final session = _dailyTaskSession;
    final int totalCount = session?.questionIds.length ?? 10;
    final bool isCompleted = session?.completed ?? false;
    final int attempted = isCompleted ? totalCount : (session?.selectedAnswers.length ?? 0);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _startDailyTask,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.assignment_turned_in_outlined, color: Colors.amber, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Task', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        SizedBox(height: 2),
                        Text('Today\'s Challenge • 10 Important PYQs', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: const Text('Complete ✓', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: totalCount > 0 ? (attempted / totalCount) : 0,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.green : const Color(0xFF2563EB)),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isCompleted
                        ? 'Score: ${session?.correctCount ?? 0}/$totalCount (${session?.accuracy.toStringAsFixed(0) ?? 0}%)'
                        : 'Progress: $attempted / $totalCount Questions',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.green.shade800 : Colors.black87,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted ? Colors.green : const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _startDailyTask,
                    child: Text(
                      isCompleted ? 'Review Task' : (attempted > 0 ? 'Continue' : 'Start Task'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickIconItem('MCQ Practice', Icons.assignment_outlined, Colors.blue, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SubjectsScreen(category: 'Technical'))).then((_) => _loadData());
              }),
            ),
            Expanded(
              child: _buildQuickIconItem('Mock Test', Icons.timer_outlined, Colors.orange, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MockTestSetupScreen())).then((_) => _loadData());
              }),
            ),
            Expanded(
              child: _buildQuickIconItem('Bookmarks', Icons.star_outlined, Colors.indigo, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen())).then((_) => _loadData());
              }, badge: _bookmarkCount > 0 ? '$_bookmarkCount' : null),
            ),
            Expanded(
              child: _buildQuickIconItem('Mistakes', Icons.error_outline, Colors.red, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MistakesScreen())).then((_) => _loadData());
              }, badge: _mistakeCount > 0 ? '$_mistakeCount' : null),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickIconItem(String label, IconData icon, Color color, VoidCallback onTap, {String? badge}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        badge,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalCard() {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SubjectsScreen(category: 'Technical'),
            ),
          ).then((_) => _loadData());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.engineering, color: Colors.blue, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Technical Subjects (14 Subjects)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text('165 Verified Technical Topics', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ..._recentTests.map((test) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            dense: true,
            onTap: () async {
              final result = test.toExamResult();
              if (result.questions.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(result: result),
                  ),
                );
              } else {
                final questions = await QuestionService.loadQuestionsBySubject(test.subject);
                final fallbackResult = ExamResult(
                  subject: test.subject,
                  subTopic: test.subTopic,
                  totalQuestions: test.totalQuestions,
                  correct: test.correct,
                  wrong: test.wrong,
                  skipped: test.skipped,
                  score: test.score,
                  percentage: test.percentage,
                  accuracy: test.accuracy,
                  questions: questions.take(test.totalQuestions).toList(),
                  selectedAnswers: List.filled(test.totalQuestions, null),
                  selectedMSQAnswers: List.generate(test.totalQuestions, (_) => []),
                  date: test.date,
                );
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(result: fallbackResult),
                    ),
                  );
                }
              }
            },
            leading: Icon(
              test.percentage >= 70 ? Icons.check_circle : Icons.info,
              color: test.percentage >= 70 ? Colors.green : Colors.orange,
            ),
            title: Text(test.subject),
            subtitle: Text(test.subTopic),
            trailing: Text(
              '${test.percentage.toStringAsFixed(0)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        )),
      ],
    );
  }
}
