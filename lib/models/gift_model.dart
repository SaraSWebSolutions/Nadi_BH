import 'package:nadi_user_app/core/utils/logger.dart';

class GiftModel {
  final String title;
  final String caption;
  final int points;
  final bool read;
  final DateTime? createdAt;

  // Legacy compat
  bool get showAnimation => !read && points > 0;
  String? get message => caption.isNotEmpty ? caption : title;

  GiftModel({
    this.title = '',
    this.caption = '',
    this.points = 0,
    this.read = false,
    this.createdAt,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    try {
      AppLogger.info("🎁 Gift API Response: $json");
    } catch (_) {}

    return GiftModel(
      title: json['title']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      points: json['points'] is int
          ? json['points']
          : int.tryParse(json['points']?.toString() ?? '0') ?? 0,
      read: json['read'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['time'] != null
                ? DateTime.tryParse(json['time'].toString())
                : null),
    );
  }
}
