import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hammesh_aae/services/chat_service.dart';
import 'package:hammesh_aae/services/competition_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('v1.2.2 Chat & Leaderboard Verification Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Chat message model serialization & deserialization', () {
      final msg = ChatMessage(
        id: 'msg_123',
        senderId: 'user_a',
        senderName: 'Aspirant A',
        recipientId: 'user_b',
        text: 'Hello test',
        timestamp: 1680000000000,
      );

      final json = msg.toJson();
      expect(json['id'], equals('msg_123'));
      expect(json['senderId'], equals('user_a'));

      final fromJson = ChatMessage.fromJson(json);
      expect(fromJson.id, equals('msg_123'));
      expect(fromJson.senderId, equals('user_a'));
      expect(fromJson.text, equals('Hello test'));
    });

    test('ChatUser model serialization', () {
      final user = ChatUser(
        id: 'uid_123',
        name: 'Test Aspirant',
        isOnline: true,
        lastSeen: 1680000000000,
      );

      final json = user.toJson();
      expect(json['id'], equals('uid_123'));
      expect(json['name'], equals('Test Aspirant'));

      final restored = ChatUser.fromJson(json);
      expect(restored.id, equals('uid_123'));
      expect(restored.name, equals('Test Aspirant'));
    });

    test('CompetitionService local member ID fallback when unauthenticated', () async {
      final memberId = await CompetitionService.getMemberId();
      expect(memberId, startsWith('asp_'));

      final displayName = await CompetitionService.getDisplayName();
      expect(displayName, contains('Aspirant'));
    });
  });
}
