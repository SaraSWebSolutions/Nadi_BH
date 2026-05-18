import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/core/network/dio_client.dart';
import 'package:nadi_user_app/models/gift_model.dart';
import 'package:nadi_user_app/services/gift_service.dart';

final giftServiceProvider = Provider<GiftService>((ref) {
  return GiftService(DioClient.dio);
});

/// GIFT STATUS NOTIFIER
class GiftStatusNotifier extends AsyncNotifier<GiftModel?> {
  Timer? _timer;

  @override
  Future<GiftModel?> build() async {
    /// first load
    final data = await _fetchGift();

    /// auto refresh every 30 seconds
    _timer ??= Timer.periodic(const Duration(seconds: 30), (_) async {
      final latest = await _fetchGift();

      state = AsyncData(latest);
    });

    ref.onDispose(() {
      _timer?.cancel();
    });

    return data;
  }

  Future<GiftModel?> _fetchGift() async {
    try {
      return await ref.read(giftServiceProvider).checkStatus();
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshGift() async {
    state = const AsyncLoading();

    final data = await _fetchGift();

    state = AsyncData(data);
  }
}

final giftStatusProvider =
    AsyncNotifierProvider<GiftStatusNotifier, GiftModel?>(
      GiftStatusNotifier.new,
    );

/// OVERLAY STATE
class ShowGiftOverlayNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void updateState(bool value) {
    state = value;
  }
}

final showGiftOverlayProvider = NotifierProvider<ShowGiftOverlayNotifier, bool>(
  ShowGiftOverlayNotifier.new,
);
