import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/services/ongoing_service.dart';

final ongoingServiceProvider = Provider<OngoingService>((ref) {
  return OngoingService();
});

// final approveTechProvider = FutureProvider((ref) async {
//   final service = OngoingService();
//   return await service.fetchaprovetech();
// });
final approveTechProvider = FutureProvider.autoDispose((ref) async {
  final service = ref.read(ongoingServiceProvider);
  try {
    return await service.fetchaprovetech();
  } catch (e, st) {
    debugPrint("Prallovider error: $e");
    debugPrint("$st");
    rethrow;
  }
});
