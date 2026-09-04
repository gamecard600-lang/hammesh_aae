import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/chat_service.dart';

class IndividualChatScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final bool isCommunityChannel;
  final bool embeddedMode;

  const IndividualChatScreen({
    super.key,
    required this.recipientId,
    required this.recipientName,
    this.isCommunityChannel = false,
    this.embeddedMode = false,
  });

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;
  ChatUser? _currentUser;
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _fetchMessages();
    // Auto refresh messages every 3 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) => _fetchMessages());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await ChatService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _fetchMessages() async {
    final list = await ChatService.fetchMessages(widget.recipientId);
    if (!mounted) return;
    setState(() {
      _messages.clear();
      _messages.addAll(list);
      _isLoading = false;
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSending) return;

    _inputController.clear();
    setState(() => _isSending = true);

    final success = await ChatService.sendMessage(
      recipientId: widget.recipientId,
      text: text,
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    if (success) {
      _fetchMessages();
      _scrollToBottom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message. Please wait a moment before sending again.')),
      );
    }
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

  void _reportAndBlockUser(BuildContext dialogContext, String text) {
    final reason = text.trim().isEmpty ? 'Spam / Abusive message' : text.trim();
    Navigator.pop(dialogContext);
    if (!widget.embeddedMode) {
      if (mounted) Navigator.pop(context);
    }
    ChatService.reportUser(widget.recipientId, reason).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User reported & blocked successfully.')),
        );
      }
    });
  }

  void _showReportDialog() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report / Block User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report user "${widget.recipientName}" for inappropriate behavior or spam:'),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for report...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => _reportAndBlockUser(dialogContext, reasonController.text),
            child: const Text('Report & Block'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          widget.isCommunityChannel
                              ? 'No messages in community channel yet. Be the first to say Hi!'
                              : 'No messages yet. Say hello to ${widget.recipientName}!',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMe = _currentUser != null && msg.senderId == _currentUser!.id;
                          final dateStr = DateTime.fromMillisecondsSinceEpoch(msg.timestamp);
                          final timeFormatted = '${dateStr.hour.toString().padLeft(2, '0')}:${dateStr.minute.toString().padLeft(2, '0')}';

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.78,
                              ),
                              decoration: BoxDecoration(
                                color: isMe ? const Color(0xFF2563EB) : Colors.grey.shade200,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(14),
                                  topRight: const Radius.circular(14),
                                  bottomLeft: Radius.circular(isMe ? 14 : 2),
                                  bottomRight: Radius.circular(isMe ? 2 : 14),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isMe && widget.isCommunityChannel) ...[
                                    Text(
                                      msg.senderName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                  ],
                                  SelectableText(
                                    msg.text,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      timeFormatted,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: isMe ? Colors.white70 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton.filled(
                  onPressed: _isSending ? null : _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.embeddedMode) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientName),
        actions: [
          if (!widget.isCommunityChannel)
            IconButton(
              icon: const Icon(Icons.report_problem_outlined, color: Colors.red),
              tooltip: 'Report / Block User',
              onPressed: _showReportDialog,
            ),
        ],
      ),
      body: body,
    );
  }
}
