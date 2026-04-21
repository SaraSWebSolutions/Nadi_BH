import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nadi_user_app/core/network/dio_client.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class StreamChatService {
  static final StreamChatService _instance = StreamChatService._internal();

  factory StreamChatService() => _instance;

  StreamChatService._internal();

  final _dio = DioClient.dio;

  late final StreamChatClient _client = StreamChatClient(
    '3e97f3da7ndg',
    logLevel: Level.INFO,
  );

  StreamChatClient get client => _client;

  /// ✅ Check ACTUAL connection state instead of a stale boolean flag.
  /// The old `_isConnected` flag could get out of sync when the WebSocket
  /// silently disconnects (token expiry, network change, server restart).
  bool get _isActuallyConnected {
    final user = _client.state.currentUser;
    final wsState = _client.wsConnectionStatus;
    return user != null && wsState == ConnectionStatus.connected;
  }

  Future<String> _getToken(String userId) async {
    final response = await _dio.post(
      'stream-chat/token',
      data: {
        'userId': userId,
        'role': 'user',
      },
    );

    return response.data['token'];
  }

  /// ✅ Connect only if not already connected — uses real connection state
  Future<void> connectUserIfNeeded(String userId) async {
    // If already connected as this user with an active WebSocket, skip
    if (_isActuallyConnected && _client.state.currentUser?.id == userId) {
      debugPrint("✅ Stream Chat already connected for $userId (ws: connected)");
      return;
    }

    // If connected as a different user, disconnect first
    if (_client.state.currentUser != null &&
        _client.state.currentUser?.id != userId) {
      debugPrint("🔄 Disconnecting previous Stream user: ${_client.state.currentUser?.id}");
      await _client.disconnectUser();
    }

    // If WebSocket died but user object is stale, force disconnect & reconnect
    if (_client.state.currentUser != null &&
        _client.wsConnectionStatus != ConnectionStatus.connected) {
      debugPrint("⚠️ Stream Chat WebSocket is ${_client.wsConnectionStatus} — forcing reconnect");
      try {
        await _client.disconnectUser();
      } catch (e) {
        debugPrint("⚠️ Disconnect during reconnect failed (OK to ignore): $e");
      }
    }

    debugPrint("🔵 Getting Stream Chat token for: $userId");
    final token = await _getToken(userId);
    debugPrint("🔵 Token received, connecting user...");

    await _client.connectUser(
      User(id: userId),
      token,
    );

    debugPrint("✅ User connected to Stream Chat (ws: ${_client.wsConnectionStatus})");

    // ✅ Register push token after connection
    await registerFCMToken();
  }

  /// ✅ Register FCM device token with Stream Chat for push notifications
  Future<void> registerFCMToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && _client.state.currentUser != null) {
        await _client.addDevice(
          fcmToken,
          PushProvider.firebase,
          pushProviderName: 'firebase-user',
        );
        debugPrint("✅ FCM token registered with Stream Chat (firebase-user)");
      }
      // Listen for token refresh and re-register
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        if (_client.state.currentUser != null) {
          await _client.addDevice(
            newToken,
            PushProvider.firebase,
            pushProviderName: 'firebase-user',
          );
          debugPrint("✅ Refreshed FCM token registered with Stream Chat (firebase-user)");
        }
      });
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
    }
  }

  Future<void> disconnect() async {
    if (_client.state.currentUser != null) {
      await _client.disconnectUser();
    }
  }
}