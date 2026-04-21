import 'package:nadi_user_app/core/utils/logger.dart';

class ServiceoverviewModel {
  final int serviceCompletedCount;
  final int servicePendingCount;
  final int serviceProgressCount;

  ServiceoverviewModel({
    required this.serviceCompletedCount,
    required this.servicePendingCount,
    required this.serviceProgressCount,
  });

  factory ServiceoverviewModel.fromJson(Map<String, dynamic> json) {
    try {
      AppLogger.info("Pie Chart Received Data: $json");
    } catch (_) {}

    return ServiceoverviewModel(
      serviceCompletedCount: _parseInt(json, ["serviceCompletedCount", "completedCount", "completed"]),
      servicePendingCount: _parseInt(json, ["servicePendingCount", "pendingCount", "pending"]),
      serviceProgressCount: _parseInt(json, ["serviceProgressCount", "progressCount", "inProgress", "in_progress"]),
    );
  }

  static int _parseInt(Map<String, dynamic> json, List<String> keys) {
    for (var key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        return int.tryParse(json[key].toString()) ?? 0;
      }
    }
    return 0;
  }
}
