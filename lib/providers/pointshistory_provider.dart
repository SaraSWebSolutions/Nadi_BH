import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/services/pointshistory_service.dart';
import 'package:nadi_user_app/services/gift_service.dart';
import 'package:nadi_user_app/core/network/dio_client.dart';
import 'package:nadi_user_app/models/PointsHistory_Model.dart';
import 'package:nadi_user_app/core/utils/logger.dart';

final pointshistoryprovider = FutureProvider<PointsHistory>((ref) async {
  final historyResult = await PointshistoryService().fetchpointhistory();

  try {
    final gifts = await GiftService(DioClient.dio).fetchGifts();
    if (gifts.isNotEmpty) {
      final giftDatumList = gifts.map((gift) {
        final date = gift.createdAt ?? DateTime.now();
        return Datum(
          id: "gift_${date.millisecondsSinceEpoch}",
          userId: "",
          history: gift.message ?? "Gift Points",
          points: gift.points,
          time: date,
          status: "credit",
          createdAt: date,
          updatedAt: date,
          v: 0,
        );
      }).toList();

      final updatedData = List<Datum>.from(historyResult.data)
        ..addAll(giftDatumList);
      updatedData.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return historyResult.copyWith(data: updatedData);
    }
  } catch (e) {
    AppLogger.error("Failed to merge gifts into history: $e");
  }

  return historyResult;
});
