import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:nadi_user_app/providers/active_chat_provider.dart';
import 'package:nadi_user_app/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MqttNotificationService {
  static MqttServerClient? _client;
  static ProviderContainer? _container;

  static void init(ProviderContainer container) {
    _container = container;
  }

  static Future<void> connect(String userId) async {
    try {
      await disconnect(); // clean up any existing connection

      final clientId = userId; // topic auth uses clientId as userId
      _client = MqttServerClient.withPort(
        'srv1252888.hstgr.cloud',
        clientId,
        1883,
      );

      _client!.keepAlivePeriod = 30;
      _client!.autoReconnect = true;
      _client!.logging(on: false);
      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = () => debugPrint('✅ MQTT connected for user: $userId');
      _client!.onAutoReconnected = () => _subscribe(userId);

      final connMsg = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .authenticateAs('nadi_app', 'NadiMqtt@2024')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      _client!.connectionMessage = connMsg;

      await _client!.connect();

      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        _subscribe(userId);
        _client!.updates!.listen(_onMessage);
      } else {
        debugPrint('❌ MQTT connection failed: ${_client!.connectionStatus!.state}');
        _client!.disconnect();
      }
    } catch (e) {
      debugPrint('❌ MQTT connect error: $e');
    }
  }

  static void _subscribe(String userId) {
    final topic = 'chat/notify/$userId';
    _client?.subscribe(topic, MqttQos.atLeastOnce);
    debugPrint('✅ MQTT subscribed to $topic');
  }

  static void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final msg in messages) {
      try {
        final payload = msg.payload as MqttPublishMessage;
        final data = MqttPublishPayload.bytesToStringAsString(
          payload.payload.message,
        );
        final decoded = jsonDecode(data);
        final channelId = decoded['channelId'] ?? '';

        debugPrint('📩 MQTT message received: title=${decoded['title']}, channelId=$channelId');

        // ✅ Suppress ONLY if user is currently viewing this EXACT chat
        final activeChannel = _container?.read(activeChatChannelProvider);
        if (activeChannel != null &&
            activeChannel.isNotEmpty &&
            channelId.isNotEmpty &&
            channelId == activeChannel) {
          debugPrint('🔇 Suppressed notification — user is viewing this chat');
          return;
        }

        debugPrint('🔔 Showing MQTT notification: ${decoded['title']}');
        NotificationService.show(
          title: decoded['title'] ?? 'New Message',
          body: decoded['body'] ?? 'You have a new message',
          channelId: 'chat_messages_channel',
          channelName: 'Chat Messages',
          payload: 'chat:$channelId',
        );
      } catch (e) {
        debugPrint('MQTT message parse error: $e');
      }
    }
  }

  static void _onDisconnected() {
    debugPrint('⚠️ MQTT disconnected');
  }

  static Future<void> disconnect() async {
    try {
      _client?.disconnect();
      _client = null;
    } catch (_) {}
  }
}
