import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/providers/fetchpointsnodification.dart';

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final response = await ref.watch(fetchpointsnodification.future);

  final lastSeen = await AppPreferences.getLastSeenNotificationTime();

  final notifications = response.data;

  // ✅ First app open
  if (lastSeen == null) {
    return notifications.where((n) => n.read == false).length;
  }

  // ✅ Count only unread + newer than last seen
  return notifications.where((n) {
    return n.read == false && n.time.isAfter(lastSeen);
  }).length;
});
