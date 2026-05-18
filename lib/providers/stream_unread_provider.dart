// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:stream_chat_flutter/stream_chat_flutter.dart';
// import 'package:nadi_user_app/preferences/preferences.dart';
// import 'package:nadi_user_app/providers/active_chat_provider.dart';
// import 'package:nadi_user_app/services/Stream_Chat_Service.dart';

// /// Real-time map of { otherUserId → unreadCount } from Stream Chat channels.
// /// Automatically refreshes when new messages arrive or messages are read.
// final streamUnreadCountsProvider = StreamProvider<Map<String, int>>((ref) async* {
//   final userId = await AppPreferences.getUserId();
//   if (userId == null) {
//     yield {};
//     return;
//   }

//   await StreamChatService().connectUserIfNeeded(userId);
//   final client = StreamChatService().client;

//   Future<Map<String, int>> fetchUnreadCounts() async {
//     try {
//       // Get the currently active chat channel so we can exclude it
//       final activeChannelId = ref.read(activeChatChannelProvider);

//       final channels = await client
//           .queryChannels(
//             filter: Filter.and([
//               Filter.equal('type', 'messaging'),
//               Filter.in_('members', [userId]),
//             ]),
//             channelStateSort: [SortOption.desc('last_message_at')],
//             state: true,
//             watch: true,
//             presence: false,
//           )
//           .first;

//       final Map<String, int> unreadMap = {};
//       for (final channel in channels) {
//         // Skip the channel the user is currently viewing
//         if (activeChannelId != null && channel.id == activeChannelId) continue;

//         final unread = channel.state?.unreadCount ?? 0;
//         if (unread == 0) continue;
//         final otherMember = channel.state?.members.firstWhere(
//           (m) => m.userId != userId,
//           orElse: () => Member(),
//         );
//         final otherId = otherMember?.userId;
//         if (otherId != null) unreadMap[otherId] = unread;
//       }
//       return unreadMap;
//     } catch (_) {
//       return {};
//     }
//   }

//   // Yield initial counts immediately
//   yield await fetchUnreadCounts();

//   // Re-yield whenever a new message arrives or messages are marked as read
//   await for (final _ in client.on(
//     EventType.notificationMessageNew,
//     EventType.messageNew,
//     EventType.messageRead,
//     EventType.notificationMarkRead,
//   )) {
//     yield await fetchUnreadCounts();
//   }
// });

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/providers/active_chat_provider.dart';
import 'package:nadi_user_app/services/Stream_Chat_Service.dart';

final streamUnreadCountsProvider = StreamProvider<Map<String, int>>((
  ref,
) async* {
  final userId = await AppPreferences.getUserId();

  if (userId == null || userId.isEmpty) {
    yield {};
    return;
  }

  await StreamChatService().connectUserIfNeeded(userId);
  final client = StreamChatService().client;

  Future<Map<String, int>> fetchUnreadCounts() async {
    try {
      // Get the currently active chat channel so we can exclude it
      final activeChannelId = ref.read(activeChatChannelProvider);

      final channels = await client
          .queryChannels(
            filter: Filter.and([
              Filter.equal('type', 'messaging'),
              Filter.in_('members', [userId]),
            ]),
            channelStateSort: const [SortOption('last_message_at')],
            state: true,
            watch: true,
            presence: false,
          )
          .first;

      final Map<String, int> unreadMap = {};
      for (final channel in channels) {
        // Skip the channel the user is currently viewing
        if (activeChannelId != null && channel.id == activeChannelId) continue;

        final unread = channel.state?.unreadCount ?? 0;
        if (unread == 0) continue;
        final otherMember = channel.state?.members.firstWhere(
          (m) => m.userId != userId,
          orElse: () => Member(),
        );
        final otherId = otherMember?.userId;
        if (otherId != null) unreadMap[otherId] = unread;
      }
      return unreadMap;
    } catch (_) {
      return {};
    }
  }

  // Yield initial counts immediately
  yield await fetchUnreadCounts();

  // Re-yield whenever a new message arrives or messages are marked as read
  await for (final _ in client.on(
    EventType.notificationMessageNew,
    EventType.messageNew,
    EventType.messageRead,
    EventType.notificationMarkRead,
  )) {
    yield await fetchUnreadCounts();
  }
});
// final streamUnreadCountsProvider = StreamProvider<Map<String, int>>((
//   ref,
// ) async* {
//   final userId = await AppPreferences.getUserId();

//   if (userId == null || userId.isEmpty) {
//     yield {};
//     return;
//   }

//   final streamService = StreamChatService();
//   await streamService.connectUserIfNeeded(userId);

//   final client = streamService.client;

//   // 🔥 Step 1: Load channels ONCE
//   final channels = await client
//       .queryChannels(
//         filter: Filter.and([
//           Filter.equal('type', 'messaging'),
//           Filter.in_('members', [userId]),
//         ]),
//         state: true,
//         watch: false, // we will manually watch
//         presence: true,
//       )
//       .first;

//   // 🔥 Step 2: WATCH ALL CHANNELS (CRITICAL FIX)
//   for (final channel in channels) {
//     await channel.watch();
//   }

//   // Local cache for fast computation
//   final Map<String, Channel> channelMap = {for (final c in channels) c.id!: c};

//   Map<String, int> computeUnread() {
//     final activeChannelId = ref.read(activeChatChannelProvider);
//     final Map<String, int> unreadMap = {};

//     for (final channel in channelMap.values) {
//       if (activeChannelId != null && channel.id == activeChannelId) {
//         continue;
//       }

//       final unread = channel.state?.unreadCount ?? 0;
//       if (unread <= 0) continue;

//       final otherMember = channel.state?.members.firstWhere(
//         (m) => m.userId != userId,
//         orElse: () => Member(),
//       );

//       final otherUserId = otherMember?.userId;
//       if (otherUserId != null) {
//         unreadMap[otherUserId] = unread;
//       }
//     }

//     return unreadMap;
//   }

//   // 🔥 Initial emit
//   yield computeUnread();

//   // 🔥 Step 3: Real-time updates
//   await for (final event in client.on()) {
//     final type = event.type;

//     if (type == EventType.messageNew ||
//         type == EventType.notificationMessageNew ||
//         type == EventType.messageRead ||
//         type == EventType.notificationMarkRead ||
//         type == EventType.notificationAddedToChannel) {
//       final cid = event.cid;

//       // 🔥 IMPORTANT: refresh only affected channel
//       if (cid != null && channelMap.containsKey(cid)) {
//         await channelMap[cid]!.watch();
//       }

//       yield computeUnread();
//     }
//   }
// });
