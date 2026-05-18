import 'dart:convert';

class PointsNotifations {
  final bool success;
  final List<Datum> data;

  PointsNotifations({required this.success, required this.data});

  PointsNotifations copyWith({bool? success, List<Datum>? data}) {
    return PointsNotifations(
      success: success ?? this.success,
      data: data ?? this.data,
    );
  }

  factory PointsNotifations.fromRawJson(String str) =>
      PointsNotifations.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PointsNotifations.fromJson(Map<String, dynamic> json) {
    return PointsNotifations(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? List<Datum>.from(json['data'].map((x) => Datum.fromJson(x)))
          : <Datum>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': List<dynamic>.from(data.map((x) => x.toJson())),
    };
  }
}

class Datum {
  final String id;
  final String message;
  final String type;
  final String userId;
  final DateTime time;
  final int v;

  // ✅ ADD THIS
  final bool read;

  Datum({
    required this.id,
    required this.message,
    required this.type,
    required this.userId,
    required this.time,
    required this.v,

    // ✅ ADD THIS
    required this.read,
  });

  Datum copyWith({
    String? id,
    String? message,
    String? type,
    String? userId,
    DateTime? time,
    int? v,

    // ✅ ADD THIS
    bool? read,
  }) {
    return Datum(
      id: id ?? this.id,
      message: message ?? this.message,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      time: time ?? this.time,
      v: v ?? this.v,

      // ✅ ADD THIS
      read: read ?? this.read,
    );
  }

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json['_id'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      userId: json['userId'] ?? '',
      time: json['time'] != null
          ? DateTime.parse(json['time'])
          : DateTime.now(),
      v: json['__v'] ?? 0,

      // ✅ ADD THIS
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'message': message,
      'type': type,
      'userId': userId,
      'time': time.toIso8601String(),
      '__v': v,

      // ✅ ADD THIS
      'read': read,
    };
  }
}
