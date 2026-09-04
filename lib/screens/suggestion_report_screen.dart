import 'package:flutter/material.dart';
import '../models/report_issue.dart';
import '../services/report_service.dart';

class SuggestionReportScreen extends StatefulWidget {
  final String? initialCategory;
  final String? subject;
  final String? topic;
  final int? questionId;
  final String? questionText;
  final String? contentId;
  final String? currentScreen;

  const SuggestionReportScreen({
    super.key,
    this.initialCategory,
    this.subject,
    this.topic,
    this.questionId,
    this.questionText,
    this.contentId,
    this.currentScreen,
  });

  static const List<String> categories = [
    'Bug / App Problem',
    'Wrong MCQ / Answer',
    'Study Material Mistake',
    'Missing Content',
    'UI / Design Issue',
    'Feature Request',
    'Other',
  ];

  @override
  State<SuggestionReportScreen> createState() => _SuggestionReportScreenState();
}

class _SuggestionReportScreenState extends State<SuggestionReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();

  late String _selectedCategory;
  bool _isSubmitting = false;
  List<ReportIssue> _savedReports = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    // Default or passed initial category
    if (widget.initialCategory != null &&
        SuggestionReportScreen.categories.contains(widget.initialCategory)) {
      _selectedCategory = widget.initialCategory!;
    } else {
      _selectedCategory = SuggestionReportScreen.categories.first;
    }

    _loadReportHistory();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadReportHistory() async {
    final reports = await ReportService.loadReports();
    if (mounted) {
      setState(() {
        _savedReports = reports;
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final now = DateTime.now();
    final platform = ReportIssue.getOperatingPlatform();

    final report = ReportIssue(
      id: now.millisecondsSinceEpoch.toString(),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      subject: widget.subject,
      topic: widget.topic,
      questionId: widget.questionId,
      questionText: widget.questionText,
      contentId: widget.contentId,
      currentScreen: widget.currentScreen ?? 'SuggestionReportScreen',
      appVersion: '1.0.0',
      timestamp: now.toIso8601String(),
      platform: platform,
      status: 'Queued',
      isSynced: false,
    );

    final success = await ReportService.saveReport(report);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      _descriptionController.clear();
      await _loadReportHistory();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Thank you. Your feedback has been recorded.\n(આભાર! તમારી નોંધ સબમિટ થઈ ગઈ છે.)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('આ રિપોર્ટ અગાઉથી સબમિટ થયેલ છે (Duplicate submission prevented).'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  bool get _hasContextData {
    return (widget.subject != null && widget.subject!.isNotEmpty) ||
        (widget.topic != null && widget.topic!.isNotEmpty) ||
        widget.questionId != null ||
        (widget.contentId != null && widget.contentId!.isNotEmpty) ||
        (widget.questionText != null && widget.questionText!.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggestions & Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.rate_review_outlined, color: Colors.amber, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Suggestions & Feedback Box',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'તમારો અભિપ્રાય, ભૂલ અથવા સુધારો આપવા માટે નીચેનું ફોર્મ ભરો.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Dropdown
                  const Text(
                    'Category / કેટેગરી',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      prefixIcon: const Icon(Icons.category_outlined, color: Colors.blue),
                    ),
                    items: SuggestionReportScreen.categories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat, style: const TextStyle(fontSize: 14)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Automatic Context Display Card
                  if (_hasContextData) ...[
                    Card(
                      color: Colors.blue.shade50.withValues(alpha: 0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.blue.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.auto_awesome, color: Colors.blue.shade800, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Automatic Context Attached (આપમેળે જોડાયેલ)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            if (widget.subject != null && widget.subject!.isNotEmpty)
                              _buildContextRow('Subject:', widget.subject!),
                            if (widget.topic != null && widget.topic!.isNotEmpty)
                              _buildContextRow('Topic:', widget.topic!),
                            if (widget.questionId != null)
                              _buildContextRow('MCQ ID:', '#${widget.questionId}'),
                            if (widget.contentId != null && widget.contentId!.isNotEmpty)
                              _buildContextRow('Content:', widget.contentId!),
                            if (widget.questionText != null && widget.questionText!.isNotEmpty)
                              _buildContextRow('Question:', widget.questionText!),
                            _buildContextRow('App Version:', '1.0.0'),
                            _buildContextRow('Platform:', ReportIssue.getOperatingPlatform()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Description Input
                  const Text(
                    'Description / વિગતો',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'તમારી સમસ્યા અથવા suggestion અહીં લખો…',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'કૃપા કરીને વિગતો દાખલ કરો (Please enter description)';
                      }
                      if (value.trim().length < 5) {
                        return 'મહેરબાની કરીને થોડી વધુ વિગતો લખો (Minimum 5 characters)';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        _isSubmitting ? 'Submitting...' : 'Submit Report (સબમિટ કરો)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),

            // History / Queue View
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📋 Submitted Reports Queue',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (_savedReports.isNotEmpty)
                  TextButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Clear Report Queue?'),
                          content: const Text('Do you want to clear your local report history?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Yes, Clear'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ReportService.clearReports();
                        await _loadReportHistory();
                      }
                    },
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    label: const Text('Clear', style: TextStyle(fontSize: 12, color: Colors.red)),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            if (_isLoadingHistory)
              const Center(child: CircularProgressIndicator())
            else if (_savedReports.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.inbox_outlined, color: Colors.grey, size: 36),
                    SizedBox(height: 8),
                    Text(
                      'હજુ સુધી કોઈ રિપોર્ટ સબમિટ થયો નથી.\n(No saved reports yet)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _savedReports.length,
                itemBuilder: (context, index) {
                  final item = _savedReports[index];
                  final formattedDate = item.timestamp.replaceFirst('T', ' ').split('.').first;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Text(
                                  item.category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.status,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                                    onPressed: () async {
                                      await ReportService.deleteReport(item.id);
                                      await _loadReportHistory();
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.description,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                          ),
                          if (item.subject != null || item.questionId != null || item.contentId != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              [
                                if (item.subject != null) 'Subject: ${item.subject}',
                                if (item.topic != null) 'Topic: ${item.topic}',
                                if (item.questionId != null) 'MCQ ID: #${item.questionId}',
                                if (item.contentId != null) 'Content: ${item.contentId}',
                              ].join(' • '),
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            '$formattedDate • v${item.appVersion} (${item.platform})',
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
