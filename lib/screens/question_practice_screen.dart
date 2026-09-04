import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/question_status.dart';
import '../models/exam_result.dart';
import '../models/practice_mode.dart';
import '../services/answer_checker.dart';
import '../services/bookmark_service.dart';
import '../services/mistake_service.dart';
import '../services/local_storage_service.dart';
import '../models/mistake.dart';
import '../models/exam_history.dart';
import '../services/competition_service.dart';
import '../models/ai_context.dart';
import 'ai_assistant/ai_chat_dialog.dart';
import 'result_screen.dart';
import 'suggestion_report_screen.dart';

class QuestionPracticeScreen extends StatefulWidget {
  final List<Question> questions;
  final String subject;
  final String? subTopic;
  final PracticeConfig config;

  const QuestionPracticeScreen({
    super.key,
    required this.questions,
    required this.subject,
    this.subTopic,
    this.config = PracticeConfig.practice,
  });

  @override
  State<QuestionPracticeScreen> createState() => _QuestionPracticeScreenState();
}

class _QuestionPracticeScreenState extends State<QuestionPracticeScreen> {
  late List<Question> activeQuestions;
  int currentIndex = 0;

  final List<int?> selectedAnswers = [];
  final List<List<int>> selectedMSQAnswers = [];
  final List<int> questionTimeSpentSeconds = [];
  late DateTime _questionStartTime;
  late List<QuestionStatus> statuses;
  final Set<int> bookmarkedIds = {};
  final Map<String, int> topicMistakesMap = {};
  final Set<int> recordedMistakeQuestionIds = {};

  bool showInstantAnswer = false;
  Timer? _timer;
  int remainingSeconds = 30 * 60; // Default 30 mins
  bool isSubmitting = false;

  void _recordCurrentQuestionTime() {
    final elapsed = DateTime.now().difference(_questionStartTime).inSeconds;
    if (currentIndex < questionTimeSpentSeconds.length) {
      questionTimeSpentSeconds[currentIndex] += elapsed;
    }
    _questionStartTime = DateTime.now();
  }

  @override
  void initState() {
    super.initState();
    _questionStartTime = DateTime.now();
    
    // Handle Question Limit
    activeQuestions = List.from(widget.questions);
    if (widget.config.questionLimit != null && activeQuestions.length > widget.config.questionLimit!) {
      activeQuestions.shuffle();
      activeQuestions = activeQuestions.take(widget.config.questionLimit!).toList();
    }

    // Initialize answers
    selectedAnswers.addAll(
      List<int?>.filled(activeQuestions.length, null),
    );

    questionTimeSpentSeconds.addAll(
      List<int>.filled(activeQuestions.length, 0),
    );

    selectedMSQAnswers.addAll(
      List.generate(
        activeQuestions.length,
        (_) => <int>[],
      ),
    );

    statuses = List.generate(
      activeQuestions.length,
      (_) => QuestionStatus.unanswered,
    );

    _loadSavedData();
    
    if (widget.config.timerEnabled) {
      // Use config duration or default to 1 min per question
      if (widget.config.durationMinutes != null) {
        remainingSeconds = widget.config.durationMinutes! * 60;
      } else {
        remainingSeconds = (activeQuestions.length * 60);
      }
      _startTimer();
    }
  }

  Future<void> _loadSavedData() async {
    final bookmarks = await BookmarkService.loadBookmarks();
    final topicMistakes = await LocalStorageService.loadTopicMistakes();
    if (mounted) {
      setState(() {
        bookmarkedIds.addAll(bookmarks.map((q) => q.id));
        topicMistakesMap.addAll(topicMistakes);
      });
    }
  }

  Future<void> toggleBookmark(Question question) async {
    await BookmarkService.toggleBookmark(question);
    setState(() {
      if (bookmarkedIds.contains(question.id)) {
        bookmarkedIds.remove(question.id);
      } else {
        bookmarkedIds.add(question.id);
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (remainingSeconds <= 0) {
          timer.cancel();
          submitExam(autoSubmit: true);
        } else {
          setState(() {
            remainingSeconds--;
          });
          if (remainingSeconds == 300) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('5 મિનિટ બાકી છે!'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Question get currentQuestion => activeQuestions[currentIndex];

  String get formattedTime {
    final hours = remainingSeconds ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;
    final seconds = remainingSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void selectAnswer(int index) {
    if (showInstantAnswer && widget.config.instantResult) return; // Locked when instant feedback is active

    setState(() {
      final question = currentQuestion;
      if (question.isMSQ) {
        if (selectedMSQAnswers[currentIndex].contains(index)) {
          selectedMSQAnswers[currentIndex].remove(index);
        } else {
          selectedMSQAnswers[currentIndex].add(index);
        }
      } else {
        selectedAnswers[currentIndex] = index;
      }

      // Update status
      bool hasAnswer = question.isMSQ 
          ? selectedMSQAnswers[currentIndex].isNotEmpty 
          : selectedAnswers[currentIndex] != null;

      if (statuses[currentIndex] == QuestionStatus.markedForReview ||
          statuses[currentIndex] == QuestionStatus.answeredAndMarked) {
        statuses[currentIndex] = hasAnswer 
            ? QuestionStatus.answeredAndMarked 
            : QuestionStatus.markedForReview;
      } else {
        statuses[currentIndex] = hasAnswer 
            ? QuestionStatus.answered 
            : QuestionStatus.unanswered;
      }

      // Trigger instant feedback for single-choice questions immediately upon selection
      if (widget.config.instantResult && !question.isMSQ) {
        _checkCurrentAnswerInstant();
      }
    });
  }

  void checkAnswer() {
    setState(() {
      _checkCurrentAnswerInstant();
    });
  }

  void _checkCurrentAnswerInstant() {
    showInstantAnswer = true;
    final question = currentQuestion;
    final isCorrect = AnswerChecker.isCorrect(
      isMSQ: question.isMSQ,
      selectedAnswer: selectedAnswers[currentIndex],
      selectedAnswers: selectedMSQAnswers[currentIndex],
      correctAnswer: question.correctAnswer,
      correctAnswers: question.correctAnswers,
    );

    if (!isCorrect) {
      _recordMistake(
        question,
        userWrongAnswer: selectedAnswers[currentIndex],
        userWrongAnswers: selectedMSQAnswers[currentIndex],
      );
    }
  }

  Future<void> _recordMistake(
    Question question, {
    int? userWrongAnswer,
    List<int>? userWrongAnswers,
  }) async {
    if (recordedMistakeQuestionIds.contains(question.id)) return;
    recordedMistakeQuestionIds.add(question.id);

    topicMistakesMap[question.subTopic] = (topicMistakesMap[question.subTopic] ?? 0) + 1;
    await LocalStorageService.saveTopicMistakes(topicMistakesMap);

    await MistakeService.addOrUpdateMistake(
      Mistake(
        questionId: question.id,
        subject: question.subject,
        subTopic: question.subTopic,
        question: question.question,
        gujaratiQuestion: question.gujaratiQuestion,
        options: question.options,
        correctAnswer: question.correctAnswer,
        correctAnswers: question.correctAnswers,
        isMSQ: question.isMSQ,
        explanation: question.explanation,
        userWrongAnswer: userWrongAnswer,
        userWrongAnswers: userWrongAnswers ?? const [],
        lastWrongDate: DateTime.now().toIso8601String(),
      ),
    );
  }

  void toggleMarkForReview() {
    setState(() {
      final question = currentQuestion;
      bool hasAnswer = question.isMSQ 
          ? selectedMSQAnswers[currentIndex].isNotEmpty 
          : selectedAnswers[currentIndex] != null;

      if (statuses[currentIndex] == QuestionStatus.markedForReview) {
        statuses[currentIndex] = hasAnswer ? QuestionStatus.answered : QuestionStatus.unanswered;
      } else if (statuses[currentIndex] == QuestionStatus.answeredAndMarked) {
        statuses[currentIndex] = QuestionStatus.answered;
      } else {
        statuses[currentIndex] = hasAnswer ? QuestionStatus.answeredAndMarked : QuestionStatus.markedForReview;
      }
    });
  }

  void _updateQuestionIndex(int newIndex) {
    _recordCurrentQuestionTime();
    setState(() {
      currentIndex = newIndex;
      final q = activeQuestions[currentIndex];
      bool isAnswered = q.isMSQ
          ? selectedMSQAnswers[currentIndex].isNotEmpty
          : selectedAnswers[currentIndex] != null;

      showInstantAnswer = widget.config.instantResult && isAnswered;
    });
  }

  void nextQuestion() {
    if (currentIndex < activeQuestions.length - 1) {
      _updateQuestionIndex(currentIndex + 1);
    }
  }

  void previousQuestion() {
    if (currentIndex > 0) {
      _updateQuestionIndex(currentIndex - 1);
    }
  }

  int get correctCount {
    int count = 0;
    for (int i = 0; i < activeQuestions.length; i++) {
      final question = activeQuestions[i];
      if (AnswerChecker.isCorrect(
        isMSQ: question.isMSQ,
        selectedAnswer: selectedAnswers[i],
        selectedAnswers: selectedMSQAnswers[i],
        correctAnswer: question.correctAnswer,
        correctAnswers: question.correctAnswers,
      )) {
        count++;
      }
    }
    return count;
  }

  int get wrongCount {
    int count = 0;
    for (int i = 0; i < activeQuestions.length; i++) {
      final question = activeQuestions[i];
      
      bool isAnswered = question.isMSQ 
          ? selectedMSQAnswers[i].isNotEmpty 
          : selectedAnswers[i] != null;

      if (isAnswered && !AnswerChecker.isCorrect(
        isMSQ: question.isMSQ,
        selectedAnswer: selectedAnswers[i],
        selectedAnswers: selectedMSQAnswers[i],
        correctAnswer: question.correctAnswer,
        correctAnswers: question.correctAnswers,
      )) {
        count++;
      }
    }
    return count;
  }

  int get unansweredCount {
    int count = 0;
    for (int i = 0; i < activeQuestions.length; i++) {
      final question = activeQuestions[i];
      bool isAnswered = question.isMSQ 
          ? selectedMSQAnswers[i].isNotEmpty 
          : selectedAnswers[i] != null;
      if (!isAnswered) count++;
    }
    return count;
  }

  double get score {
    if (!widget.config.negativeMarking) return correctCount.toDouble();
    return correctCount - (wrongCount * 0.25);
  }

  void submitExam({bool autoSubmit = false}) async {
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    _timer?.cancel();

    if (autoSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('સમય પૂરો થયો! ઓટો સબમિટ થઈ રહ્યું છે...')),
      );
    }

    // Process Mistakes for all attempted wrong questions
    for (int i = 0; i < activeQuestions.length; i++) {
      final question = activeQuestions[i];
      bool isAnswered = question.isMSQ 
          ? selectedMSQAnswers[i].isNotEmpty 
          : selectedAnswers[i] != null;
      
      if (isAnswered) {
        final isCorrect = AnswerChecker.isCorrect(
          isMSQ: question.isMSQ,
          selectedAnswer: selectedAnswers[i],
          selectedAnswers: selectedMSQAnswers[i],
          correctAnswer: question.correctAnswer,
          correctAnswers: question.correctAnswers,
        );

        if (!isCorrect) {
          await _recordMistake(
            question,
            userWrongAnswer: selectedAnswers[i],
            userWrongAnswers: selectedMSQAnswers[i],
          );
        }
      }
    }

    final finalCorrect = correctCount;
    final finalWrong = wrongCount;
    final finalSkipped = unansweredCount;
    final finalScore = score;
    final finalPercentage = (finalScore / activeQuestions.length) * 100;
    
    final attempted = finalCorrect + finalWrong;
    final finalAccuracy = attempted == 0 ? 0.0 : (finalCorrect / attempted) * 100;

    final examHistory = ExamHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: widget.subject,
      subTopic: widget.subTopic ?? 'Practice',
      date: DateTime.now().toIso8601String(),
      totalQuestions: activeQuestions.length,
      correct: finalCorrect,
      wrong: finalWrong,
      skipped: finalSkipped,
      score: finalScore,
      percentage: finalPercentage,
      accuracy: finalAccuracy,
      questions: activeQuestions,
      selectedAnswers: List.from(selectedAnswers),
      selectedMSQAnswers: selectedMSQAnswers.map((l) => List<int>.from(l)).toList(),
      questionTimeSpent: List.from(questionTimeSpentSeconds),
    );

    _recordCurrentQuestionTime();

    await LocalStorageService.addExamToHistory(examHistory);

    final examResult = ExamResult(
      subject: widget.subject,
      subTopic: widget.subTopic ?? 'Practice',
      totalQuestions: activeQuestions.length,
      correct: finalCorrect,
      wrong: finalWrong,
      skipped: finalSkipped,
      score: finalScore,
      percentage: finalPercentage,
      accuracy: finalAccuracy,
      questions: activeQuestions,
      selectedAnswers: List.from(selectedAnswers),
      selectedMSQAnswers: selectedMSQAnswers.map((l) => List<int>.from(l)).toList(),
      questionTimeSpent: questionTimeSpentSeconds,
    );

    // Sync competition result if participating in a Study Competition
    try {
      await CompetitionService.recordTestResult(examResult);
    } catch (e) {
      debugPrint('Error recording competition result: $e');
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(result: examResult),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (activeQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.subject)),
        body: const Center(child: Text('પ્રશ્નો ઉપલબ્ધ નથી')),
      );
    }

    final question = currentQuestion;
    bool isAnswered = question.isMSQ 
        ? selectedMSQAnswers[currentIndex].isNotEmpty 
        : selectedAnswers[currentIndex] != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject),
        actions: [
          IconButton(
            icon: const Icon(Icons.report_problem_outlined, color: Colors.orange),
            tooltip: 'Report MCQ (રિપોર્ટ કરો)',
            onPressed: () => _openReportQuestionScreen(currentQuestion),
          ),
          if (widget.config.timerEnabled)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 18, color: Colors.redAccent),
                    const SizedBox(width: 4),
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      endDrawer: widget.config.timerEnabled ? _buildPaletteDrawer() : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'પ્રશ્ન ${currentIndex + 1} / ${activeQuestions.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      if (question.isMSQ && widget.config.instantResult && isAnswered && !showInstantAnswer)
                        TextButton.icon(
                          onPressed: checkAnswer,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('જવાબ ચકાસો'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (currentIndex + 1) / activeQuestions.length,
                    backgroundColor: Colors.blue.shade50,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (question.explanation.toUpperCase().contains('PYQ') || question.explanation.toUpperCase().contains('GSSSB'))
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history_edu, size: 14, color: Colors.amber.shade900),
                            const SizedBox(width: 4),
                            Text(
                              'Genuine PYQ',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                            ),
                          ],
                        ),
                      ),
                    if (question.gujaratiQuestion.isNotEmpty) ...[
                      Text(
                        question.gujaratiQuestion,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Text(
                      question.question,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(question.options.length, (index) {
                      final isSelected = question.isMSQ
                          ? selectedMSQAnswers[currentIndex].contains(index)
                          : selectedAnswers[currentIndex] == index;
                      
                      final isCorrect = question.isMSQ 
                          ? question.correctAnswers.contains(index) 
                          : question.correctAnswer == index;

                      Color? cardColor;
                      BorderSide borderSide = BorderSide.none;
                      Widget? trailing;

                      if (showInstantAnswer) {
                        if (isCorrect) {
                          cardColor = Colors.green.shade50;
                          borderSide = BorderSide(color: Colors.green.shade400, width: 1.5);
                          trailing = const Icon(Icons.check_circle, color: Colors.green);
                        } else if (isSelected) {
                          cardColor = Colors.red.shade50;
                          borderSide = BorderSide(color: Colors.red.shade400, width: 1.5);
                          trailing = const Icon(Icons.cancel, color: Colors.red);
                        }
                      } else if (isSelected) {
                        cardColor = Colors.blue.shade50;
                        borderSide = BorderSide(color: Colors.blue.shade400, width: 1.5);
                      }

                      return Card(
                        color: cardColor,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: borderSide,
                        ),
                        child: ListTile(
                          onTap: showInstantAnswer ? null : () => selectAnswer(index),
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? (showInstantAnswer
                                    ? (isCorrect ? Colors.green : Colors.red)
                                    : Colors.blue)
                                : (showInstantAnswer && isCorrect ? Colors.green : null),
                            foregroundColor: isSelected || (showInstantAnswer && isCorrect)
                                ? Colors.white
                                : null,
                            child: Text(String.fromCharCode(65 + index)),
                          ),
                          title: Text(
                            question.options[index],
                            style: TextStyle(
                              fontWeight: isSelected || (showInstantAnswer && isCorrect)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: trailing,
                        ),
                      );
                    }),
                    
                    if (showInstantAnswer) ...[
                      const SizedBox(height: 8),
                      _buildInstantFeedbackBanner(question),
                      if (question.explanation.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildExplanationCard(question),
                      ],
                      const SizedBox(height: 12),
                      _buildAiActionButtons(question),
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomBar(question),
          ],
        ),
      ),
    );
  }

  Widget _buildInstantFeedbackBanner(Question question) {
    final isCorrect = AnswerChecker.isCorrect(
      isMSQ: question.isMSQ,
      selectedAnswer: selectedAnswers[currentIndex],
      selectedAnswers: selectedMSQAnswers[currentIndex],
      correctAnswer: question.correctAnswer,
      correctAnswers: question.correctAnswers,
    );

    final correctOptionLetter = question.isMSQ
        ? question.correctAnswers.map((i) => String.fromCharCode(65 + i)).join(', ')
        : String.fromCharCode(65 + question.correctAnswer);

    final correctOptionText = question.isMSQ
        ? question.correctAnswers.map((i) => question.options[i]).join(', ')
        : question.options[question.correctAnswer];

    if (isCorrect) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 22),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'સાચો જવાબ! (Correct Answer)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cancel, color: Colors.red.shade700, size: 22),
                const SizedBox(width: 10),
                const Text(
                  'ખોટો જવાબ! (Wrong Answer)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'સાચો જવાબ: $correctOptionLetter. $correctOptionText',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildExplanationCard(Question question) {
    return Card(
      color: Colors.blue.shade50.withValues(alpha: 0.4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue.shade800, size: 20),
                const SizedBox(width: 8),
                Text(
                  'સ્પષ્ટીકરણ (Explanation):',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              question.explanation,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  void _openReportQuestionScreen(Question question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuggestionReportScreen(
          initialCategory: 'Wrong MCQ / Answer',
          subject: question.subject.isNotEmpty ? question.subject : widget.subject,
          topic: widget.subTopic ?? question.subTopic,
          questionId: question.id,
          questionText: question.question,
          currentScreen: 'QuestionPracticeScreen',
        ),
      ),
    );
  }

  Widget _buildAiActionButtons(Question question) {
    final isCorrect = AnswerChecker.isCorrect(
      isMSQ: question.isMSQ,
      selectedAnswer: selectedAnswers[currentIndex],
      selectedAnswers: selectedMSQAnswers[currentIndex],
      correctAnswer: question.correctAnswer,
      correctAnswers: question.correctAnswers,
    );

    final aiContext = AiContext(
      subject: question.subject,
      topic: widget.subTopic ?? question.subTopic,
      subtopic: question.subTopic,
      questionText: question.question,
      gujaratiQuestionText: question.gujaratiQuestion,
      options: question.options,
      correctAnswer: question.isMSQ ? question.correctAnswers : question.correctAnswer,
      userSelectedAnswer: question.isMSQ
          ? selectedMSQAnswers[currentIndex]
          : selectedAnswers[currentIndex],
      existingExplanation: question.explanation,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ActionChip(
            avatar: const Icon(Icons.smart_toy, size: 16, color: Colors.blue),
            label: const Text('🤖 Ask AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            backgroundColor: Colors.blue.shade50,
            onPressed: () {
              AiChatDialog.show(
                context,
                contextData: aiContext,
                initialAction: AiQuickAction.askAi,
              );
            },
          ),
          if (!isCorrect)
            ActionChip(
              avatar: const Icon(Icons.error_outline, size: 16, color: Colors.red),
              label: const Text('🤖 Explain My Mistake', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red)),
              backgroundColor: Colors.red.shade50,
              onPressed: () {
                AiChatDialog.show(
                  context,
                  contextData: aiContext,
                  initialAction: AiQuickAction.whyWrong,
                );
              },
            ),
          ActionChip(
            avatar: const Icon(Icons.help_outline, size: 16, color: Colors.indigo),
            label: const Text('Why other options wrong?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            backgroundColor: Colors.indigo.shade50,
            onPressed: () {
              AiChatDialog.show(
                context,
                contextData: aiContext,
                initialAction: AiQuickAction.otherOptions,
              );
            },
          ),
          ActionChip(
            avatar: const Icon(Icons.calculate_outlined, size: 16, color: Colors.teal),
            label: const Text('🧮 Solve with AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            backgroundColor: Colors.teal.shade50,
            onPressed: () {
              AiChatDialog.show(
                context,
                contextData: aiContext,
                initialAction: AiQuickAction.solveStepByStep,
              );
            },
          ),
          ActionChip(
            avatar: const Icon(Icons.report_problem_outlined, size: 16, color: Colors.orange),
            label: const Text('🚩 Report MCQ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange)),
            backgroundColor: Colors.orange.shade50,
            onPressed: () => _openReportQuestionScreen(question),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Question question) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: currentIndex > 0 ? previousQuestion : null,
            icon: const Icon(Icons.arrow_back_ios),
            tooltip: 'અગાઉનો પ્રશ્ન',
          ),
          const Spacer(),
          IconButton(
            onPressed: () => toggleBookmark(question),
            icon: Icon(
              bookmarkedIds.contains(question.id) ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.amber,
            ),
            tooltip: 'બુકમાર્ક કરો',
          ),
          IconButton(
            onPressed: () => _openReportQuestionScreen(question),
            icon: const Icon(
              Icons.report_problem_outlined,
              color: Colors.orange,
            ),
            tooltip: 'રિપોર્ટ કરો (Report Question)',
          ),
          if (!widget.config.instantResult)
            IconButton(
              onPressed: toggleMarkForReview,
              icon: Icon(
                statuses[currentIndex] == QuestionStatus.markedForReview ||
                        statuses[currentIndex] == QuestionStatus.answeredAndMarked
                    ? Icons.flag
                    : Icons.flag_outlined,
                color: Colors.purple,
              ),
              tooltip: 'રિવ્યુ માટે ફ્લેગ કરો',
            ),
          const Spacer(),
          if (currentIndex == activeQuestions.length - 1)
            ElevatedButton(
              onPressed: submitExam,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('ટેસ્ટ પૂર્ણ કરો', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          else
            ElevatedButton(
              onPressed: nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('આગળનો પ્રશ્ન', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildPaletteDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('પ્રશ્નો વિહંગાવલોકન (Palette)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: activeQuestions.length,
                itemBuilder: (context, index) {
                  final status = statuses[index];
                  Color bgColor = Colors.grey.shade200;
                  Color textColor = Colors.black;

                  if (index == currentIndex) bgColor = Colors.blue.shade100;

                  switch (status) {
                    case QuestionStatus.answered:
                      bgColor = Colors.green.shade400;
                      textColor = Colors.white;
                      break;
                    case QuestionStatus.markedForReview:
                      bgColor = Colors.purple.shade400;
                      textColor = Colors.white;
                      break;
                    case QuestionStatus.answeredAndMarked:
                      bgColor = Colors.deepPurple.shade600;
                      textColor = Colors.white;
                      break;
                    case QuestionStatus.unanswered:
                      break;
                  }

                  return InkWell(
                    onTap: () {
                      _updateQuestionIndex(index);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: index == currentIndex ? Border.all(color: Colors.blue, width: 2) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text('${index + 1}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
