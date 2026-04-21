import 'package:app_badge_plus/app_badge_plus.dart';

class BadgeService {
  static Future<void> update(int count) async {
    try {
      await AppBadgePlus.updateBadge(count); // 0 = clear
    } catch (e) {
      print("Badge error: $e");
    }
  }
}