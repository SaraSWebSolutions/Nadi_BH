import 'package:dio/dio.dart';
import 'package:nadi_user_app/models/gift_model.dart';
import 'package:nadi_user_app/core/utils/logger.dart';

class GiftService {
  final Dio _dio;
  GiftService(this._dio);

  /// Fetch gift list — POST /api/gift (EXACT backend endpoint)
  Future<List<GiftModel>> fetchGifts() async {
    try {
      final response = await _dio.post('gift');  // EXACT endpoint — POST not GET
      final data = response.data;

      if (data is Map && data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => GiftModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      AppLogger.error("Gift API fetch error: $e");
      return [];
    }
  }

  /// Get first unread gift (to show animation) — backward compat for dashboard
  Future<GiftModel> checkStatus() async {
    try {
      final gifts = await fetchGifts();
      // Find first gift where read == false
      final unread = gifts.where((g) => !g.read);
      if (unread.isNotEmpty) {
        return unread.first;
      }
      // No unread gifts — return a "no animation" model
      return GiftModel(read: true);
    } catch (e) {
      AppLogger.error("Gift API check error: $e");
      return GiftModel(read: true);
    }
  }

  /// Mark all gifts as read — POST /api/gift/mark-as-read (EXACT endpoint)
  Future<void> dismiss() async {
    try {
      await _dio.post('gift/mark-as-read');  // EXACT endpoint
    } catch (e) {
      AppLogger.error("Gift API dismiss error: $e");
    }
  }
}
