import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/services/NotificationApiService.dart';

/// Auto-refreshing notification provider — polls every 30 seconds
final fetchpointsnodification = FutureProvider.autoDispose((ref) async {
  final result = await Notificationapiservice().fetchpointsnodification();

  // Auto-refresh every 30 seconds so the envelope badge stays current
  final timer = Future.delayed(const Duration(seconds: 30), () {
    ref.invalidateSelf();
  });
  ref.onDispose(() {}); // keep alive until disposed

  return result;
});
