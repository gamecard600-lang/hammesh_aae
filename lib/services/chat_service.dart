import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'competition_backend_service.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String recipientId; // 'global' or userId
  final String text;
  final int timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? 'Aspirant',
      recipientId: json['recipientId'] as String? ?? 'global',
      text: json['text'] as String? ?? '',
      timestamp: (json['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'recipientId': recipientId,
      'text': text,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}

class ChatUser {
  final String id;
  final String name;
  final bool isOnline;
  final int lastSeen;

  ChatUser({
    required this.id,
    required this.name,
    this.isOnline = true,
    required this.lastSeen,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Aspirant',
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: (json['lastSeen'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
    };
  }
}

class ChatService {
  static const String _userIdKey = 'chat_user_id_v1';
  static const String _userNameKey = 'chat_user_name_v1';
  static const String _blockedUsersKey = 'chat_blocked_users_v1';

  static DateTime? _lastMessageTime;

  static String get _baseUrl => CompetitionBackendService.baseUrl;

  /// Gets current user profile or initializes a unique aspirant ID
  static Future<ChatUser> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_userIdKey);
    String? name = prefs.getString(_userNameKey);

    if (id == null || id.isEmpty) {
      id = 'asp_${DateTime.now().millisecondsSinceEpoch % 1000000}';
      await prefs.setString(_userIdKey, id);
    }

    if (name == null || name.isEmpty) {
      name = 'Aspirant #${id.replaceAll('asp_', '')}';
      await prefs.setString(_userNameKey, name);
    }

    final user = ChatUser(
      id: id,
      name: name,
      isOnline: true,
      lastSeen: DateTime.now().millisecondsSinceEpoch,
    );

    // Sync user heartbeat online
    _syncUserHeartbeat(user);

    return user;
  }

  static Future<void> updateUserName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, newName.trim());
    final currentUser = await getCurrentUser();
    await _syncUserHeartbeat(currentUser);
  }

  static Future<void> _syncUserHeartbeat(ChatUser user) async {
    try {
      final url = Uri.parse('$_baseUrl/chat_users/${user.id}.json');
      await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Error syncing chat heartbeat: $e');
    }
  }

  /// Sends a message (Rate limiting: max 1 per 1.5 seconds)
  static Future<bool> sendMessage({
    required String recipientId,
    required String text,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return false;

    // Rate limiting check
    if (_lastMessageTime != null) {
      final diff = DateTime.now().difference(_lastMessageTime!).inMilliseconds;
      if (diff < 1200) {
        debugPrint('Rate limited message');
        return false;
      }
    }
    _lastMessageTime = DateTime.now();

    final user = await getCurrentUser();
    final msgId = 'msg_${DateTime.now().millisecondsSinceEpoch}';

    final message = ChatMessage(
      id: msgId,
      senderId: user.id,
      senderName: user.name,
      recipientId: recipientId,
      text: cleanText,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    try {
      final String channel = recipientId == 'global' ? 'global' : _getChannelId(user.id, recipientId);
      final url = Uri.parse('$_baseUrl/messages/$channel/$msgId.json');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(message.toJson()),
      ).timeout(const Duration(seconds: 8));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('Error sending chat message: $e');
      return false;
    }
  }

  /// Fetches messages for a channel
  static Future<List<ChatMessage>> fetchMessages(String recipientId) async {
    try {
      final user = await getCurrentUser();
      final String channel = recipientId == 'global' ? 'global' : _getChannelId(user.id, recipientId);
      final url = Uri.parse('$_baseUrl/messages/$channel.json');

      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 && response.body != 'null' && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        final List<ChatMessage> list = [];
        final blocked = await getBlockedUsers();

        if (decoded is Map) {
          decoded.forEach((key, value) {
            if (value is Map) {
              final msg = ChatMessage.fromJson(Map<String, dynamic>.from(value));
              if (!blocked.contains(msg.senderId)) {
                list.add(msg);
              }
            }
          });
        }
        list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return list;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching chat messages: $e');
      return [];
    }
  }

  /// Fetches online aspirants list
  static Future<List<ChatUser>> fetchAspirants() async {
    try {
      final url = Uri.parse('$_baseUrl/chat_users.json');
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 && response.body != 'null' && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        final List<ChatUser> users = [];
        final currentUser = await getCurrentUser();
        final blocked = await getBlockedUsers();

        if (decoded is Map) {
          decoded.forEach((key, value) {
            if (value is Map) {
              final u = ChatUser.fromJson(Map<String, dynamic>.from(value));
              if (u.id != currentUser.id && !blocked.contains(u.id)) {
                users.add(u);
              }
            }
          });
        }
        return users;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching chat users: $e');
      return [];
    }
  }

  /// Safety: Block User
  static Future<void> blockUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final blocked = await getBlockedUsers();
    blocked.add(userId);
    await prefs.setStringList(_blockedUsersKey, blocked.toList());
  }

  static Future<Set<String>> getBlockedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_blockedUsersKey) ?? [];
    return list.toSet();
  }

  /// Safety: Report User
  static Future<bool> reportUser(String userId, String reason) async {
    try {
      final currentUser = await getCurrentUser();
      final reportId = 'rep_${DateTime.now().millisecondsSinceEpoch}';
      final url = Uri.parse('$_baseUrl/reports/$reportId.json');

      final body = jsonEncode({
        'reporterId': currentUser.id,
        'reportedUserId': userId,
        'reason': reason,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      await http.put(url, headers: {'Content-Type': 'application/json'}, body: body);
      await blockUser(userId);
      return true;
    } catch (e) {
      debugPrint('Error reporting user: $e');
      return false;
    }
  }

  static String _getChannelId(String user1, String user2) {
    final sorted = [user1, user2]..sort();
    return 'p2p_${sorted[0]}_${sorted[1]}';
  }
}
