import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/core/network/dio_client.dart';
import 'package:nadi_user_app/models/gift_model.dart';
import 'package:nadi_user_app/services/gift_service.dart';

final giftServiceProvider = Provider<GiftService>((ref) {
  // Use the existing static Dio instance as Nadi app structure is statically initialized
  return GiftService(DioClient.dio);
});

final giftStatusProvider = FutureProvider.autoDispose<GiftModel>((ref) async {
  return await ref.read(giftServiceProvider).checkStatus();
});

class ShowGiftOverlayNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void updateState(bool value) => state = value;
}

final showGiftOverlayProvider = NotifierProvider<ShowGiftOverlayNotifier, bool>(
  () => ShowGiftOverlayNotifier(),
);
