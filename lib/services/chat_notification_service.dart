import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chat_service.dart';

class ChatNotificationService {
  static const MethodChannel _notificationChannel =
      MethodChannel('com.example.hammesh_aae/notification');

  static Timer? _pollingTimer;
  static int _lastCheckedTimestamp = DateTime.now().millisecondsSinceEpoch;
  static bool _initialized = false;

  /// Starts background polling for new incoming chat messages
  static void startNotificationListener(BuildContext context) {
    if (_initialized) return;
    _initialized = true;
    _lastCheckedTimestamp = DateTime.now().millisecondsSinceEpoch;

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await checkForNewMessages(context);
    });
  }

  static void stopNotificationListener() {
    _pollingTimer?.cancel();
    _initialized = false;
  }

  /// Checks for any new messages sent after _lastCheckedTimestamp
  static Future<void> checkForNewMessages([BuildContext? context]) async {
    try {
      final currentUser = await ChatService.getCurrentUser();
      final globalMessages = await ChatService.fetchMessages('global');

      final newMessages = globalMessages.where((msg) =>
          msg.senderId != currentUser.id &&
          msg.timestamp > _lastCheckedTimestamp).toList();

      if (newMessages.isNotEmpty) {
        for (var msg in newMessages) {
          _lastCheckedTimestamp = msg.timestamp;

          // 1. Show Native Android Status Bar Notification
          _showNativeNotification(
            title: '💬 Chat: ${msg.senderName}',
            body: msg.text,
          );

          // 2. Show In-App SnackBar Notification Banner if Context is available
          if (context != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.senderName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            msg.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF2563EB),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking chat notifications: $e');
    }
  }

  static Future<void> _showNativeNotification({
    required String title,
    required String body,
  }) async {
    try {
      await _notificationChannel.invokeMethod('showNotification', {
        'title': title,
        'body': body,
      });
    } catch (e) {
      debugPrint('Error invoking native notification: $e');
    }
  }
}
