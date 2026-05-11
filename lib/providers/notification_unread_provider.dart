import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:nadi_user_app/providers/fetchpointsnodification.dart';

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final response = await ref.watch(fetchpointsnodification.future);

  final lastSeen = await AppPreferences.getLastSeenNotificationTime();

  final notifications = response.data;

  if (lastSeen == null) {
    return notifications.length;
  }

  return notifications.where((n) => n.time.isAfter(lastSeen)).length;
});
