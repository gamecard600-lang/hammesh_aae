import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import 'individual_chat_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ChatUser? _currentUser;
  List<ChatUser> _aspirants = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    // Auto-refresh aspirants every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => _loadAspirants());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = await ChatService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _currentUser = user;
    });
    await _loadAspirants();
  }

  Future<void> _loadAspirants() async {
    final list = await ChatService.fetchAspirants();
    if (!mounted) return;
    setState(() {
      _aspirants = list;
      _isLoading = false;
    });
  }

  void _saveProfile(BuildContext dialogContext, String text) {
    final name = text.trim();
    if (name.isNotEmpty) {
      Navigator.pop(dialogContext);
      ChatService.updateUserName(name).then((_) => _loadData());
    }
  }

  void _showEditProfileDialog() {
    if (_currentUser == null) return;
    final nameController = TextEditingController(text: _currentUser!.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Aspirant Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter your display name for Aspirants Chat:'),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'e.g. Mechanical Aspirant',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _saveProfile(ctx, nameController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredAspirants = _aspirants.where((u) {
      if (_searchQuery.isEmpty) return true;
      return u.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aspirants Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Edit Profile Name',
            onPressed: _showEditProfileDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.forum_outlined), text: 'Global Channel'),
            Tab(icon: Icon(Icons.people_outline), text: 'Direct Messages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Global Community Channel
          _buildCommunityChannelTab(),

          // Direct P2P Aspirants List
          _buildDirectMessagesTab(filteredAspirants),
        ],
      ),
    );
  }

  Widget _buildCommunityChannelTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              const Icon(Icons.campaign, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Global Aspirants Discussion Channel. Discuss GSSSB AAE exam strategies, concepts & updates live!',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: IndividualChatScreen(
            recipientId: 'global',
            recipientName: 'Global Aspirants Channel',
            isCommunityChannel: true,
            embeddedMode: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDirectMessagesTab(List<ChatUser> aspirants) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search Aspirants by name...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val.trim();
              });
            },
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : aspirants.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isNotEmpty ? 'No aspirants matched your search.' : 'No other aspirants active online right now.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: aspirants.length,
                      itemBuilder: (context, index) {
                        final aspirant = aspirants[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              aspirant.name.isNotEmpty ? aspirant.name[0].toUpperCase() : 'A',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ),
                          title: Text(
                            aspirant.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('Tap to start 1-on-1 discussion', style: TextStyle(fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => IndividualChatScreen(
                                  recipientId: aspirant.id,
                                  recipientName: aspirant.name,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
