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
      appBar: AppBar(
        title: Text(material.title),
        actions: [
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

            // IMAGE SUPPORT
            // આ સેક્શન ત્યારે જ દેખાશે જ્યારે JSON માં imagePath હશે
            // ignore: unnecessary_null_comparison
            if (material.toJson().containsKey('imagePath') && material.toJson()['imagePath'] != null && material.toJson()['imagePath'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    material.toJson()['imagePath'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.image_not_supported, color: Colors.grey),
                            SizedBox(width: 10),
                            Text('Diagram not available yet', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

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
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.quiz),
                label: Text(
                  isLoadingQuestions
                      ? 'Loading Questions...'
                      : relatedQuestions.isEmpty
                          ? 'No Questions Available'
                          : 'Practice ${relatedQuestions.length} Questions',
                ),
              ),
            ),

            const SizedBox(height: 32),
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
    final aiContext = _getAiContext();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smart_toy, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                '🤖 AI Study Assistant',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ActionChip(
                  avatar: const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.blue),
                  label: const Text('Ask AI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.white,
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
                  avatar: const Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
                  label: const Text('💡 Explain Topic', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.white,
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
                  avatar: const Icon(Icons.bolt, size: 16, color: Colors.amber),
                  label: const Text('📚 Quick Revision', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.white,
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
                  avatar: const Icon(Icons.warning_amber_outlined, size: 16, color: Colors.red),
                  label: const Text('⚠️ Exam Traps', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.white,
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
                  avatar: const Icon(Icons.report_problem_outlined, size: 16, color: Colors.orange),
                  label: const Text('🚩 Report Material', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
                  backgroundColor: Colors.white,
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue.shade900),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (material.overview.isNotEmpty) ...[
              Text(
                material.overview,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
              ),
              const SizedBox(height: 8),
            ],
            if (material.concept.isNotEmpty) ...[
              Text(
                material.concept,
                style: const TextStyle(fontSize: 13.5, height: 1.4),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopicDetailsSection(StudyMaterial material) {
    final StringBuffer sb = StringBuffer();
    if (material.overview.isNotEmpty) sb.writeln('Overview:\n${material.overview}\n');
    if (material.concept.isNotEmpty) sb.writeln('Concept:\n${material.concept}\n');
    if (material.detailedTheory.isNotEmpty) sb.writeln('Detailed Theory:\n${material.detailedTheory}');

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
                const Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.description, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '1. Topic Details',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      contextData: _getAiContext(sectionTitle: 'Topic Details', sectionContent: sb.toString()),
                      initialAction: AiQuickAction.explain,
                    );
                  },
                  icon: const Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
                  label: const Text('Explain', style: TextStyle(fontSize: 12, color: Colors.orange)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (sb.isNotEmpty)
              Text(sb.toString().trim(), style: const TextStyle(fontSize: 14.5, height: 1.5))
            else
              const Text('Topic details available in subtopics.', style: TextStyle(color: Colors.grey)),
            if (material.definitions.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Definitions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              const SizedBox(height: 6),
              ...material.definitions.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $d', style: const TextStyle(fontSize: 13.5, height: 1.4)),
                  )),
            ],
            if (material.solvedExamples.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Solved Examples:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              const SizedBox(height: 6),
              ...material.solvedExamples.map((ex) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('✓ $ex', style: const TextStyle(fontSize: 13.5, height: 1.4)),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVisualLearningSection(StudyMaterial material) {
    return AnimatedTopicVisualWidget(material: material);
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
                const Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.stars, color: Colors.amber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '2. Exam Important Points',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      contextData: _getAiContext(sectionTitle: 'Exam Important Points', sectionContent: allPoints.join('\n')),
                      initialAction: AiQuickAction.quickRevision,
                    );
                  },
                  icon: const Icon(Icons.bolt, size: 16, color: Colors.amber),
                  label: const Text('Revision', style: TextStyle(fontSize: 12, color: Colors.amber)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (material.formulas.isNotEmpty) ...[
              const Text('Important Formulas:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.blue)),
              const SizedBox(height: 6),
              ...material.formulas.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📐 ', style: TextStyle(fontSize: 12)),
                        Expanded(child: Text(f, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5))),
                      ],
                    ),
                  )),
              const SizedBox(height: 10),
            ],
            if (allPoints.isNotEmpty)
              ...allPoints.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🎯 ', style: TextStyle(fontSize: 12)),
                        Expanded(child: Text(p, style: const TextStyle(fontSize: 13.5, height: 1.4))),
                      ],
                    ),
                  ))
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
                const Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '3. Confusion Points & Traps',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                        Expanded(child: Text(m, style: const TextStyle(fontSize: 13.5, height: 1.4))),
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
