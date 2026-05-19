
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/providers/active_chat_provider.dart';
import 'package:nadi_user_app/services/Stream_Chat_Service.dart';

final streamUnreadCountsProvider =
    StreamProvider<Map<String, int>>((ref) async* {
  final userId = await AppPreferences.getUserId();

  if (userId == null || userId.isEmpty) {
    yield {};
    return;
  }

  final streamService = StreamChatService();
  await streamService.connectUserIfNeeded(userId);

  final client = streamService.client;

  /// FETCH UNREAD (fresh state each time)
  Future<Map<String, int>> fetchUnread() async {
    final channels = await client
        .queryChannels(
          filter: Filter.and([
            Filter.equal('type', 'messaging'),
            Filter.in_('members', [userId]),
          ]),
          state: true,
          watch: false,
        )
        .first;

    final Map<String, int> unreadMap = {};
    final activeChannelId = ref.read(activeChatChannelProvider);

    for (final channel in channels) {
  final unread = channel.state?.unreadCount ?? 0;

  debugPrint("CHANNEL=${channel.cid} unread=$unread");

  if (unread <= 0) continue;

  String? otherUserId;

  for (final member in channel.state?.members ?? []) {
    if (member.userId != null && member.userId != userId) {
      otherUserId = member.userId;
      break;
    }
  }

  if (otherUserId != null) {
    unreadMap[otherUserId] = unread;
  } else {
    debugPrint("⚠️ NO OTHER USER FOUND for ${channel.cid}");
  }
}

    debugPrint("FINAL UNREAD MAP = $unreadMap");
    return unreadMap;
  }

  /// INITIAL EMIT
  yield await fetchUnread();

  /// REAL-TIME UPDATES
  await for (final event in client.on(
    EventType.messageNew,
    EventType.notificationMessageNew,
    EventType.messageRead,
    EventType.notificationMarkRead,
  )) {
    debugPrint("🌍 EVENT = ${event.type} | cid=${event.cid}");

    yield await fetchUnread();
  }
});