import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'competition_backend_service.dart';
import 'online_auth_service.dart';

enum ChatSendStatus {
  success,
  rateLimited,
  networkError,
  serverError,
  emptyMessage,
}

class ChatSendResult {
  final ChatSendStatus status;
  final String errorMessage;

  ChatSendResult(this.status, [this.errorMessage = '']);

  bool get isSuccess => status == ChatSendStatus.success;
  bool get isNetworkOrServerError =>
      status == ChatSendStatus.networkError || status == ChatSendStatus.serverError;
  bool get isRateLimited => status == ChatSendStatus.rateLimited;
}

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

  static Future<Uri?> _authUri(String path) async { final token=await OnlineAuthService.getIdToken(); if(token==null||token.isEmpty)return null; return Uri.parse('$_baseUrl/$path.json?auth=${Uri.encodeQueryComponent(token)}'); }

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
      final url = await _authUri('chat_users/${user.id}');
      if (url == null) return;
      await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Error syncing chat heartbeat: $e');
    }
  }

  /// Sends a message with rate-limiting, local optimistic cache & offline queuing
  static Future<ChatSendResult> sendMessage({
    required String recipientId,
    required String text,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      return ChatSendResult(ChatSendStatus.emptyMessage, 'Message cannot be empty.');
    }

    // Rate limiting check (800 ms)
    if (_lastMessageTime != null) {
      final diff = DateTime.now().difference(_lastMessageTime!).inMilliseconds;
      if (diff < 800) {
        debugPrint('Rate limited message');
        return ChatSendResult(
          ChatSendStatus.rateLimited,
          'Please wait a second before sending again.',
        );
      }
    }

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

    final String channel = recipientId == 'global' ? 'global' : _getChannelId(user.id, recipientId);

    // Optimistically add message to local cache
    await _addMessageToLocalCache(channel, message);

    try {
      final url = await _authUri('messages/$channel/$msgId');
      if (url == null) {
        await _addPendingMessage(channel, message);
        return ChatSendResult(
          ChatSendStatus.networkError,
          'Auth offline. Saved locally.',
        );
      }

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(message.toJson()),
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _lastMessageTime = DateTime.now();
        _syncPendingMessages();
        return ChatSendResult(ChatSendStatus.success);
      } else {
        await _addPendingMessage(channel, message);
        return ChatSendResult(
          ChatSendStatus.serverError,
          'Server error (${response.statusCode}). Saved locally.',
        );
      }
    } catch (e) {
      debugPrint('Error sending chat message: $e');
      await _addPendingMessage(channel, message);
      return ChatSendResult(
        ChatSendStatus.networkError,
        'Network offline. Saved locally, will sync when connected.',
      );
    }
  }

  /// Fetches messages for a channel with local cache fallback
  static Future<List<ChatMessage>> fetchMessages(String recipientId) async {
    final user = await getCurrentUser();
    final String channel = recipientId == 'global' ? 'global' : _getChannelId(user.id, recipientId);
    
    final cachedList = await _getCacheMessages(channel);
    final blocked = await getBlockedUsers();

    try {
      final url = await _authUri('messages/$channel');
      if (url == null) {
        return cachedList.where((msg) => !blocked.contains(msg.senderId)).toList();
      }
      final response = await http.get(url).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200 && response.body != 'null' && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        final List<ChatMessage> list = [];

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

        await _saveCacheMessages(channel, list);
        return list;
      }
    } catch (e) {
      debugPrint('Error fetching chat messages: $e');
    }

    return cachedList.where((msg) => !blocked.contains(msg.senderId)).toList();
  }

  /// Fetches online aspirants list with cache fallback
  static Future<List<ChatUser>> fetchAspirants() async {
    final cachedUsers = await _getCachedAspirants();

    try {
      final url = await _authUri('chat_users');
      if (url == null) {
        final currentUser = await getCurrentUser();
        final blocked = await getBlockedUsers();
        return cachedUsers.where((u) => u.id != currentUser.id && !blocked.contains(u.id)).toList();
      }
      final response = await http.get(url).timeout(const Duration(seconds: 6));

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
        await _saveCachedAspirants(users);
        return users;
      }
    } catch (e) {
      debugPrint('Error fetching chat users: $e');
    }

    final currentUser = await getCurrentUser();
    final blocked = await getBlockedUsers();
    return cachedUsers.where((u) => u.id != currentUser.id && !blocked.contains(u.id)).toList();
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
      final url = await _authUri('reports/$reportId');
      if (url == null) return false;

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

  // Helper Methods for Storage Caching & Offline Queue
  static Future<List<ChatMessage>> _getCacheMessages(String channel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('chat_cached_msg_$channel');
      if (raw == null || raw.isEmpty) return [];
      final List decoded = jsonDecode(raw);
      final list = decoded.map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e))).toList();
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return list;
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveCacheMessages(String channel, List<ChatMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(messages.map((e) => e.toJson()).toList());
      await prefs.setString('chat_cached_msg_$channel', raw);
    } catch (_) {}
  }

  static Future<void> _addMessageToLocalCache(String channel, ChatMessage msg) async {
    final list = await _getCacheMessages(channel);
    if (!list.any((m) => m.id == msg.id)) {
      list.add(msg);
      await _saveCacheMessages(channel, list);
    }
  }

  static Future<void> _addPendingMessage(String channel, ChatMessage msg) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('chat_pending_msg_v1');
      List list = raw != null && raw.isNotEmpty ? jsonDecode(raw) : [];
      list.add({'channel': channel, 'msg': msg.toJson()});
      await prefs.setString('chat_pending_msg_v1', jsonEncode(list));
    } catch (_) {}
  }

  static Future<void> _syncPendingMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('chat_pending_msg_v1');
      if (raw == null || raw.isEmpty) return;

      final List list = jsonDecode(raw);
      if (list.isEmpty) return;

      final remaining = [];
      for (var item in list) {
        if (item is Map) {
          final channel = item['channel'] as String?;
          final msgMap = item['msg'] as Map?;
          if (channel != null && msgMap != null) {
            final msg = ChatMessage.fromJson(Map<String, dynamic>.from(msgMap));
            final url = await _authUri('messages/$channel/${msg.id}');
            if (url != null) {
              try {
                final response = await http.put(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(msg.toJson()),
                ).timeout(const Duration(seconds: 5));
                if (response.statusCode < 200 || response.statusCode >= 300) {
                  remaining.add(item);
                }
              } catch (_) {
                remaining.add(item);
              }
            } else {
              remaining.add(item);
            }
          }
        }
      }
      await prefs.setString('chat_pending_msg_v1', jsonEncode(remaining));
    } catch (_) {}
  }

  static Future<List<ChatUser>> _getCachedAspirants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('chat_cached_aspirants_v1');
      if (raw == null || raw.isEmpty) return [];
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => ChatUser.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveCachedAspirants(List<ChatUser> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(users.map((e) => e.toJson()).toList());
      await prefs.setString('chat_cached_aspirants_v1', raw);
    } catch (_) {}
  }
}
