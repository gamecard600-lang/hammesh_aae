import 'package:flutter/material.dart';

import '../../models/study_material.dart';
import '../../models/question.dart';
import '../../models/practice_mode.dart';
import '../../services/question_service.dart';
import '../../services/question_filter.dart';
import '../../services/local_storage_service.dart';
import '../../models/study_bookmark.dart';
import '../../models/ai_context.dart';
import '../ai_assistant/ai_chat_dialog.dart';
import '../question_practice_screen.dart';
import '../suggestion_report_screen.dart';
import 'animated_topic_visual_widget.dart';
import 'concept_story_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class StudyMaterialScreen extends StatefulWidget {
  final StudyMaterial material;
  final List<StudyMaterial> subjectMaterials;

  const StudyMaterialScreen({
    super.key,
    required this.material,
    this.subjectMaterials = const [],
  });

  @override
  State<StudyMaterialScreen> createState() => _StudyMaterialScreenState();
}

class _StudyMaterialScreenState extends State<StudyMaterialScreen> {
  late StudyMaterial currentMaterial;

  List<Question> relatedQuestions = [];

  bool isLoadingQuestions = true;
  bool isCompleted = false;
  bool isBookmarked = false;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentMaterial = widget.material;
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      isLoadingQuestions = true;
    });

    await Future.wait([
      _loadRelatedQuestions(),
      _loadProgressStatus(),
      _loadBookmarkStatus(),
      _loadPersonalNote(),
    ]);
  }

  Future<void> _loadPersonalNote() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'note_${currentMaterial.subject}_${currentMaterial.topic}';
    final savedNote = prefs.getString(key) ?? '';
    if (!mounted) return;
    setState(() {
      _noteController.text = savedNote;
    });
  }

  Future<void> _savePersonalNote() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'note_${currentMaterial.subject}_${currentMaterial.topic}';
    await prefs.setString(key, _noteController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personal note saved!')),
    );
  }

  Future<void> _loadProgressStatus() async {
    final progress = await LocalStorageService.loadStudyProgress();

    final status = progress.any(
      (p) =>
          p.subject.trim().toLowerCase() == currentMaterial.subject.trim().toLowerCase() &&
          p.topic.trim().toLowerCase() == currentMaterial.topic.trim().toLowerCase() &&
          p.completed,
    );

    if (!mounted) return;

    setState(() {
      isCompleted = status;
    });
  }

  Future<void> _loadBookmarkStatus() async {
    final bookmarks = await LocalStorageService.loadStudyBookmarks();

    final status = bookmarks.any(
      (b) =>
          b.subject.trim() == currentMaterial.subject.trim() &&
          b.topic.trim() == currentMaterial.topic.trim(),
    );

    if (!mounted) return;

    setState(() {
      isBookmarked = status;
    });
  }

  Future<void> _loadRelatedQuestions() async {
    try {
      final allQuestions =
          await QuestionService.loadQuestionsBySubject(
        currentMaterial.subject,
      );

      final filtered = getRelatedQuestions(
        questions: allQuestions,
        subject: currentMaterial.subject,
        topic: currentMaterial.topic,
      );

      if (!mounted) return;

      setState(() {
        relatedQuestions = filtered;
        isLoadingQuestions = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        relatedQuestions = [];
        isLoadingQuestions = false;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    final bookmark = StudyBookmark(
      subject: currentMaterial.subject,
      topic: currentMaterial.topic,
      title: currentMaterial.title,
    );

    await LocalStorageService.toggleStudyBookmark(bookmark);
    await _loadBookmarkStatus();
  }

  Future<void> _toggleCompletion() async {
    await LocalStorageService.markTopicCompleted(
      currentMaterial.subject,
      currentMaterial.topic,
    );

    await _loadProgressStatus();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Topic marked as completed!'),
      ),
    );
  }

  Future<void> _exportToPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(currentMaterial.subject.toUpperCase(), 
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.blue700)),
                  pw.SizedBox(height: 4),
                  pw.Text(currentMaterial.title, 
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            
            if (currentMaterial.overview.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Text('Overview', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(currentMaterial.overview),
            ],

            if (currentMaterial.concept.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Text('Concept', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(currentMaterial.concept),
            ],

            if (currentMaterial.detailedTheory.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Text('Detailed Theory', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(currentMaterial.detailedTheory),
            ],

            if (currentMaterial.keyPoints.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Text('Key Points', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              ...currentMaterial.keyPoints.map((p) => pw.Text('• $p')),
            ],

            if (currentMaterial.formulas.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Text('Formulas', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              ...currentMaterial.formulas.map((f) => pw.Text('• $f', style: pw.TextStyle(font: pw.Font.courierBold()))),
            ],

            pw.SizedBox(height: 40),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Generated by Ham\'s AAE App', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${currentMaterial.topic.replaceAll(' ', '_')}.pdf',
    );
  }

  void _navigateToMaterial(StudyMaterial material) {
    setState(() {
      currentMaterial = material;
    });

    _loadData();
  }

  double _fontSize = 14.5;
  String _readingTheme = 'Default'; // Default, Sepia, Dark
  bool _isPlayingAudio = false;

  Color get _backgroundColor {
    if (_readingTheme == 'Sepia') return const Color(0xFFFBF0D9);
    if (_readingTheme == 'Dark') return const Color(0xFF1E1E1E);
    return Theme.of(context).scaffoldBackgroundColor;
  }

  Color get _textColor {
    if (_readingTheme == 'Dark') return Colors.white;
    if (_readingTheme == 'Sepia') return const Color(0xFF3B2F2F);
    return Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    final material = currentMaterial;

    final currentIndex = widget.subjectMaterials.indexWhere(
      (m) => m.topic.trim().toLowerCase() == material.topic.trim().toLowerCase(),
    );

    final totalTopics = widget.subjectMaterials.length;

    final hasNavigation =
        widget.subjectMaterials.isNotEmpty && currentIndex != -1;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(material.title),
        actions: [
          IconButton(
            icon: Icon(_isPlayingAudio ? Icons.pause_circle_filled : Icons.volume_up_outlined, color: Colors.amber.shade700),
            tooltip: '🎧 Audio Summary Player',
            onPressed: () {
              setState(() => _isPlayingAudio = !_isPlayingAudio);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text(_isPlayingAudio
                      ? '🎧 Playing Audio Summary: ${material.topic}...'
                      : '⏸️ Audio Summary Paused'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.report_problem_outlined, color: Colors.orange),
            tooltip: 'Report Material (રિપોર્ટ કરો)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SuggestionReportScreen(
                    initialCategory: 'Study Material Mistake',
                    subject: currentMaterial.subject,
                    topic: currentMaterial.topic,
                    contentId: currentMaterial.title,
                    currentScreen: 'StudyMaterialScreen',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Export as PDF',
            onPressed: _exportToPdf,
          ),
          IconButton(
            icon: Icon(
              isBookmarked
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: isBookmarked ? Colors.blue : null,
            ),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReadingComfortControls(),
            const SizedBox(height: 12),
            if (hasNavigation) ...[
              LinearProgressIndicator(
                value: (currentIndex + 1) / totalTopics,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(
                  Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Topic ${currentIndex + 1} of $totalTopics',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  if (isCompleted)
                    const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            Text(
              material.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 12),
            _buildAiBar(),
            const SizedBox(height: 8),

            _buildDiagramSection(material),

            _buildConceptExplanationSection(material),
            _buildVisualLearningSection(material),
            _buildTopicDetailsSection(material),
            _buildExamImportantPointsSection(material),
            _buildConfusionPointsSection(material),
            _buildPersonalNotesSection(),

            const SizedBox(height: 24),

            if (hasNavigation) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: currentIndex > 0
                          ? () => _navigateToMaterial(
                                widget.subjectMaterials[
                                    currentIndex - 1],
                              )
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          currentIndex < totalTopics - 1
                              ? () => _navigateToMaterial(
                                    widget.subjectMaterials[
                                        currentIndex + 1],
                                  )
                              : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    isCompleted ? null : _toggleCompletion,
                icon: Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                ),
                label: Text(
                  isCompleted
                      ? 'Completed'
                      : 'Mark as Completed',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isCompleted
                          ? Colors.green.shade50
                          : null,
                  foregroundColor:
                      isCompleted
                          ? Colors.green
                          : null,
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    (isLoadingQuestions ||
                            relatedQuestions.isEmpty)
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    QuestionPracticeScreen(
                                  questions: relatedQuestions,
                                  subject: material.subject,
                                  subTopic: material.topic,
                                  config:
                                      PracticeConfig.practice,
                                ),
                              ),
                            );
                          },
                icon: isLoadingQuestions
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.assignment_turned_in, size: 22),
                label: Text(
                  isLoadingQuestions
                      ? 'Loading Topic MCQs...'
                      : relatedQuestions.isEmpty
                          ? 'No MCQs Available for this Topic'
                          : '📝 Practice MCQs (${relatedQuestions.length} Questions)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingComfortControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _readingTheme == 'Dark'
            ? Colors.grey.shade900
            : _readingTheme == 'Sepia'
                ? const Color(0xFFF3E5AB)
                : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _readingTheme == 'Dark' ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Icon(Icons.text_fields, size: 18, color: _textColor),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.remove, size: 16, color: _textColor),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                if (_fontSize > 12) setState(() => _fontSize -= 1.5);
              },
            ),
            const SizedBox(width: 4),
            Text('${_fontSize.toInt()}pt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textColor)),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.add, size: 16, color: _textColor),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                if (_fontSize < 24) setState(() => _fontSize += 1.5);
              },
            ),
            const SizedBox(width: 12),
            Row(
              children: ['Default', 'Sepia', 'Dark'].map((mode) {
                final selected = _readingTheme == mode;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: ChoiceChip(
                    label: Text(mode, style: const TextStyle(fontSize: 11)),
                    selected: selected,
                    onSelected: (_) => setState(() => _readingTheme = mode),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  AiContext _getAiContext({String? sectionTitle, String? sectionContent}) {
    return AiContext(
      subject: currentMaterial.subject,
      topic: currentMaterial.topic,
      studyMaterialText: sectionContent ?? '''
Title: ${currentMaterial.title}
Overview: ${currentMaterial.overview}
Concept: ${currentMaterial.concept}
Detailed Theory: ${currentMaterial.detailedTheory}
Formulas: ${currentMaterial.formulas.join(', ')}
''',
    );
  }

  Widget _buildAiBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aiContext = _getAiContext();
    final chipBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.blue.shade50.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.blueAccent.withValues(alpha: 0.4) : Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy, color: isDark ? Colors.blueAccent : Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                '🤖 AI Study Assistant',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.blueAccent : Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ActionChip(
                  avatar: const Icon(Icons.auto_stories, size: 16, color: Colors.purpleAccent),
                  label: const Text('🎭 AI Concept Story', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
                  backgroundColor: isDark ? const Color(0xFF2E1065) : Colors.purple.shade50,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConceptStoryScreen(
                          topic: currentMaterial.topic,
                          subject: currentMaterial.subject,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),
                ActionChip(
                  avatar: const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.blueAccent),
                  label: Text('Ask AI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                  backgroundColor: chipBg,
                  onPressed: () {
                    AiChatDialog.show(
                      context,
                      contextData: aiContext,
                      initialAction: AiQuickAction.askAi,
                    );
                  },
                ),
                const SizedBox(width: 6),
                ActionChip(
                  avatar: const Icon(Icons.lightbulb_outline, size: 16, color: Colors.orangeAccent),
                  label: Text('💡 Explain Topic', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                  backgroundColor: chipBg,
                  onPressed: () {
                    AiChatDialog.show(
                      context,
                      contextData: aiContext,
                      initialAction: AiQuickAction.explain,
                    );
                  },
                ),
                const SizedBox(width: 6),
                ActionChip(
                  avatar: const Icon(Icons.bolt, size: 16, color: Colors.amberAccent),
                  label: Text('📚 Quick Revision', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                  backgroundColor: chipBg,
                  onPressed: () {
                    AiChatDialog.show(
                      context,
                      contextData: aiContext,
                      initialAction: AiQuickAction.quickRevision,
                    );
                  },
                ),
                const SizedBox(width: 6),
                ActionChip(
                  avatar: const Icon(Icons.warning_amber_outlined, size: 16, color: Colors.redAccent),
                  label: Text('⚠️ Exam Traps', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                  backgroundColor: chipBg,
                  onPressed: () {
                    AiChatDialog.show(
                      context,
                      contextData: aiContext,
                      initialAction: AiQuickAction.commonMistakes,
                    );
                  },
                ),
                const SizedBox(width: 6),
                ActionChip(
                  avatar: const Icon(Icons.report_problem_outlined, size: 16, color: Colors.orangeAccent),
                  label: const Text('🚩 Report Material', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                  backgroundColor: chipBg,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SuggestionReportScreen(
                          initialCategory: 'Study Material Mistake',
                          subject: currentMaterial.subject,
                          topic: currentMaterial.topic,
                          contentId: currentMaterial.title,
                          currentScreen: 'StudyMaterialScreen',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConceptExplanationSection(StudyMaterial material) {
    if (material.overview.isEmpty && material.concept.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      color: Colors.blue.shade50.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue.shade800, size: 22),
                const SizedBox(width: 8),
                Text(
                  '1. Concept Explanation',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: _fontSize + 1.5, color: Colors.blue.shade900),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (material.overview.isNotEmpty) ...[
              Text(
                material.overview,
                style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w600, height: 1.5, color: _textColor),
              ),
              const SizedBox(height: 8),
            ],
            if (material.concept.isNotEmpty) ...[
              Text(
                material.concept,
                style: TextStyle(fontSize: _fontSize - 0.5, height: 1.5, color: _textColor),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopicDetailsSection(StudyMaterial material) {
    final String detailedText = material.detailedTheory.trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.description, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '2. Detailed Theory',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: _fontSize + 1.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    AiChatDialog.show(
                      context,
                      contextData: _getAiContext(sectionTitle: 'Detailed Theory', sectionContent: detailedText),
                      initialAction: AiQuickAction.explain,
                    );
                  },
                  icon: const Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
                  label: const Text('Explain', style: TextStyle(fontSize: 12, color: Colors.orange)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (detailedText.isNotEmpty)
              _buildFormattedText(detailedText)
            else
              const Text('Detailed theory available in subtopics.', style: TextStyle(color: Colors.grey)),
            if (material.definitions.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('Definitions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: _fontSize, color: Colors.blue)),
              const SizedBox(height: 8),
              ...material.definitions.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildDefinitionItem(d),
                  )),
            ],
            if (material.solvedExamples.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('Solved Examples:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: _fontSize, color: Colors.blue)),
              const SizedBox(height: 8),
              ...material.solvedExamples.map((ex) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('✓ $ex', style: TextStyle(fontSize: _fontSize - 0.5, height: 1.45, color: _textColor)),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedText(String text) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      if (line.startsWith('- ') || line.startsWith('• ')) {
        final content = line.substring(2).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: _fontSize, height: 1.5, color: _textColor)),
                Expanded(
                  child: Text(
                    content,
                    style: TextStyle(fontSize: _fontSize, height: 1.55, color: _textColor),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line,
              style: TextStyle(fontSize: _fontSize, height: 1.55, color: _textColor),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildDefinitionItem(String definition) {
    final text = definition.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('• $text', style: TextStyle(fontSize: _fontSize - 0.5, height: 1.45, fontWeight: FontWeight.w500, color: _textColor)),
    );
  }

  Widget _buildDiagramSection(StudyMaterial material) {
    String imgPath = material.imagePath.trim();
    if (imgPath.isEmpty) {
      imgPath = material.visualLearning?.imageUrl?.trim() ?? '';
    }

    if (imgPath.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool isAsset = !imgPath.startsWith('http://') && !imgPath.startsWith('https://');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  const Icon(Icons.schema_outlined, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '📐 Engineering Diagram (ઇજનેરી આકૃતિ)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: _fontSize,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _showDiagramDialog(context, imgPath, material.topic),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.fullscreen, color: Colors.blue, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showDiagramDialog(context, imgPath, material.topic),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 320),
                width: double.infinity,
                child: isAsset
                    ? Image.asset(
                        imgPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => _buildDiagramFallback(material.topic),
                      )
                    : Image.network(
                        imgPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => _buildDiagramFallback(material.topic),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagramFallback(String topicTitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.grey.shade100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_motion, size: 40, color: Colors.blue.shade400),
          const SizedBox(height: 8),
          Text(
            '📐 $topicTitle - Technical Diagram',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'આ વિઝ્યુઅલ સરકિટ / ડાયાગ્રામની સંપૂર્ણ સમજૂતી નીચેના વિસ્તૃત થિયરી વિભાગમાં ઉપલબ્ધ છે.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDiagramDialog(BuildContext context, String imgPath, String title) {
    final bool isAsset = !imgPath.startsWith('http://') && !imgPath.startsWith('https://');
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(title, style: const TextStyle(fontSize: 16)),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            Flexible(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: isAsset
                    ? Image.asset(imgPath, errorBuilder: (context, error, stackTrace) => _buildDiagramFallback(title))
                    : Image.network(imgPath, errorBuilder: (context, error, stackTrace) => _buildDiagramFallback(title)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualLearningSection(StudyMaterial material) {
    return AnimatedTopicVisualWidget(material: material);
  }

  Widget _buildExamPointItem(String point) {
    final text = point.trim();
    if (text.isEmpty) return const SizedBox.shrink();

    final isQuestion = text.contains('**પ્રશ્ન:') || text.startsWith('પ્રશ્ન:');

    if (isQuestion || text.contains('\nજવાબ:')) {
      final lines = text.split('\n');
      String qText = '';
      String aText = '';

      for (var l in lines) {
        final trimmedLine = l.trim();
        if (trimmedLine.startsWith('**પ્રશ્ન:') || trimmedLine.startsWith('પ્રશ્ન:')) {
          qText = trimmedLine.replaceAll('**', '').trim();
        } else if (trimmedLine.startsWith('જવાબ:')) {
          aText = trimmedLine.trim();
        } else if (qText.isEmpty) {
          qText = trimmedLine.replaceAll('**', '').trim();
        } else {
          aText += ' $trimmedLine';
        }
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              qText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: _fontSize,
                color: Colors.blue,
                height: 1.45,
              ),
            ),
            if (aText.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                aText,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: _fontSize - 0.5,
                  height: 1.45,
                  color: _textColor,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎯 ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(
              text.replaceAll('**', ''),
              style: TextStyle(fontSize: _fontSize - 0.5, height: 1.5, fontWeight: FontWeight.w500, color: _textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamImportantPointsSection(StudyMaterial material) {
    final List<String> allPoints = [
      ...material.keyPoints,
      ...material.importantPoints,
      ...material.examPoints,
      ...material.quickRevision,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.stars, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'પરીક્ષા માટેના મહત્વના મુદ્દા',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: _fontSize + 1.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    AiChatDialog.show(
                      context,
                      contextData: _getAiContext(sectionTitle: 'પરીક્ષા માટેના મહત્વના મુદ્દા', sectionContent: allPoints.join('\n')),
                      initialAction: AiQuickAction.quickRevision,
                    );
                  },
                  icon: const Icon(Icons.bolt, size: 16, color: Colors.amber),
                  label: const Text('Revision', style: TextStyle(fontSize: 12, color: Colors.amber)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (material.formulas.isNotEmpty) ...[
              Text('Important Formulas:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: _fontSize, color: Colors.blue)),
              const SizedBox(height: 8),
              ...material.formulas.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Text('📐 ', style: TextStyle(fontSize: 12)),
                          Expanded(child: Text(f, style: TextStyle(fontWeight: FontWeight.bold, fontSize: _fontSize - 0.5, color: _textColor))),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 12),
            ],
            if (allPoints.isNotEmpty)
              ...allPoints.map((p) => _buildExamPointItem(p))
            else
              const Text('Review formulas and key concepts before solving MCQs.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildConfusionPointsSection(StudyMaterial material) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '3. Confusion Points & Traps',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: _fontSize + 1.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    AiChatDialog.show(
                      context,
                      contextData: _getAiContext(sectionTitle: 'Confusion Points', sectionContent: material.commonMistakes.join('\n')),
                      initialAction: AiQuickAction.commonMistakes,
                    );
                  },
                  icon: const Icon(Icons.psychology, size: 16, color: Colors.red),
                  label: const Text('Traps', style: TextStyle(fontSize: 12, color: Colors.red)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (material.commonMistakes.isNotEmpty)
              ...material.commonMistakes.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚠️ ', style: TextStyle(fontSize: 12)),
                        Expanded(child: Text(m, style: TextStyle(fontSize: _fontSize - 0.5, height: 1.45, color: _textColor))),
                      ],
                    ),
                  ))
            else
              const Text('Avoid common unit conversion and sign convention errors during the exam.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalNotesSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📌 My Personal Notes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: _savePersonalNote,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Add your custom notes or revision tricks here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
