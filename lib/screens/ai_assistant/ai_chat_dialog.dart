import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/ai_context.dart';
import '../../services/ai_study_assistant_service.dart';

enum AiQuickAction {
  askAi,
  explain,
  whyWrong,
  solveStepByStep,
  quickRevision,
  examPoint,
  commonMistakes,
  otherOptions,
}

class AiChatDialog extends StatefulWidget {
  final AiContext contextData;
  final AiQuickAction initialAction;
  final String? initialQuery;

  const AiChatDialog({
    super.key,
    required this.contextData,
    this.initialAction = AiQuickAction.askAi,
    this.initialQuery,
  });

  static Future<void> show(
    BuildContext context, {
    required AiContext contextData,
    AiQuickAction initialAction = AiQuickAction.askAi,
    String? initialQuery,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AiChatDialog(
          contextData: contextData,
          initialAction: initialAction,
          initialQuery: initialQuery,
        ),
      ),
    );
  }

  @override
  State<AiChatDialog> createState() => _AiChatDialogState();
}

class _AiChatDialogState extends State<AiChatDialog> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _triggerInitialAction();
  }

  void _triggerInitialAction() {
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _sendMessage(widget.initialQuery!);
      return;
    }

    switch (widget.initialAction) {
      case AiQuickAction.explain:
        _runAction(
          '💡 Explain This Concept',
          () => AiStudyAssistantService.explainConcept(
            context: widget.contextData,
            conceptText: widget.contextData.studyMaterialText ??
                widget.contextData.questionText ??
                '',
          ),
        );
        break;
      case AiQuickAction.whyWrong:
        _runAction(
          '🤖 Explain My Mistake',
          () => AiStudyAssistantService.explainMistake(
            context: widget.contextData,
          ),
        );
        break;
      case AiQuickAction.otherOptions:
        _runAction(
          '❓ Why are other options wrong?',
          () => AiStudyAssistantService.explainOtherOptions(
            context: widget.contextData,
          ),
        );
        break;
      case AiQuickAction.solveStepByStep:
        _runAction(
          '🧮 Solve Step-by-Step',
          () => AiStudyAssistantService.solveStepByStep(
            context: widget.contextData,
          ),
        );
        break;
      case AiQuickAction.quickRevision:
        _runAction(
          '📚 AI Quick Revision',
          () => AiStudyAssistantService.generateQuickRevision(
            context: widget.contextData,
          ),
        );
        break;
      case AiQuickAction.commonMistakes:
      case AiQuickAction.examPoint:
        _runAction(
          '⚠️ Common Exam Traps',
          () => AiStudyAssistantService.detectExamTraps(
            context: widget.contextData,
          ),
        );
        break;
      case AiQuickAction.askAi:
        // Ready for user input
        break;
    }
  }

  Future<void> _runAction(String title, Future<String> Function() actionCall) async {
    setState(() {
      _messages.add({'role': 'user', 'text': title});
      _isLoading = true;
    });
    _scrollToBottom();

    final response = await actionCall();

    if (!mounted) return;
    setState(() {
      _messages.add({'role': 'assistant', 'text': response});
      _isLoading = false;
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage(String query) async {
    final text = query.trim();
    if (text.isEmpty || _isLoading) return;

    _inputController.clear();
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });
    _scrollToBottom();

    final response = await AiStudyAssistantService.askDoubt(
      context: widget.contextData,
      userQuery: text,
      chatHistory: _messages,
    );

    if (!mounted) return;
    setState(() {
      _messages.add({'role': 'assistant', 'text': response});
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contextTitle = widget.contextData.topic ??
        widget.contextData.subject ??
        'AAE AI Study Assistant';

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // App Bar Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy, color: Colors.blue, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AAE AI Assistant',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        contextTitle,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Quick Action Chips Scroll Area
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildActionChip(
                  label: '🤖 Ask AI',
                  onTap: () {
                    _inputController.text = 'Explain this concept in simple terms.';
                  },
                ),
                _buildActionChip(
                  label: '💡 Explain',
                  onTap: () => _runAction(
                    '💡 Explain Concept',
                    () => AiStudyAssistantService.explainConcept(
                      context: widget.contextData,
                      conceptText: widget.contextData.studyMaterialText ??
                          widget.contextData.questionText ??
                          '',
                    ),
                  ),
                ),
                _buildActionChip(
                  label: '❓ Why is this wrong?',
                  onTap: () => _runAction(
                    '🤖 Explain My Mistake',
                    () => AiStudyAssistantService.explainMistake(
                      context: widget.contextData,
                    ),
                  ),
                ),
                _buildActionChip(
                  label: '🧮 Solve Step-by-Step',
                  onTap: () => _runAction(
                    '🧮 Solve Step-by-Step',
                    () => AiStudyAssistantService.solveStepByStep(
                      context: widget.contextData,
                    ),
                  ),
                ),
                _buildActionChip(
                  label: '📚 Quick Revision',
                  onTap: () => _runAction(
                    '📚 Quick Revision',
                    () => AiStudyAssistantService.generateQuickRevision(
                      context: widget.contextData,
                    ),
                  ),
                ),
                _buildActionChip(
                  label: '⚠️ Common Mistakes',
                  onTap: () => _runAction(
                    '⚠️ Common Exam Traps',
                    () => AiStudyAssistantService.detectExamTraps(
                      context: widget.contextData,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: _messages.isEmpty && !_isLoading
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return _buildLoadingBubble();
                      }
                      final msg = _messages[index];
                      final isUser = msg['role'] == 'user';
                      return _buildChatBubble(msg['text'] ?? '', isUser);
                    },
                  ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: 'Ask about current topic or question...',
                        hintStyle: const TextStyle(fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isLoading
                        ? null
                        : () => _sendMessage(_inputController.text),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({required String label, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        onPressed: _isLoading ? null : onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.blue.shade50,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology_outlined, size: 56, color: Colors.blue.shade300),
            const SizedBox(height: 12),
            const Text(
              'AAE AI Study Assistant',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ask any doubt about the topic or question, clarify concepts, or get step-by-step solutions.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF2563EB)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser
              ? null
              : Border.all(color: Colors.blue.shade100, width: 1),
          boxShadow: [
            if (!isUser)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              text,
              style: TextStyle(
                color: isUser ? Colors.white : null,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (!isUser) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('Copy', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('AI is thinking...', style: TextStyle(fontSize: 13, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
