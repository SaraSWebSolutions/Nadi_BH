import 'dart:convert';

class Advertisementmodel {
    final bool success;
    final List<Datum> data;

    Advertisementmodel({
        required this.success,
        required this.data,
    });

    Advertisementmodel copyWith({
        bool? success,
        List<Datum>? data,
    }) => 
        Advertisementmodel(
            success: success ?? this.success,
            data: data ?? this.data,
        );

    factory Advertisementmodel.fromRawJson(String str) => Advertisementmodel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Advertisementmodel.fromJson(Map<String, dynamic> json) => Advertisementmodel(
        success: json["success"] ?? false,
        data: json["data"] is List
            ? List<Datum>.from((json["data"] as List).map((x) => Datum.fromJson(x)))
            : <Datum>[],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    final String id;
    final dynamic video;
    final List<Ad> ads;
    final bool status;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final int v;

    Datum({
        required this.id,
        required this.video,
        required this.ads,
        required this.status,
        this.createdAt,
        this.updatedAt,
        required this.v,
    });

    Datum copyWith({
        String? id,
        dynamic video,
        List<Ad>? ads,
        bool? status,
        DateTime? createdAt,
        DateTime? updatedAt,
        int? v,
    }) => 
        Datum(
            id: id ?? this.id,
            video: video ?? this.video,
            ads: ads ?? this.ads,
            status: status ?? this.status,
            createdAt: createdAt ?? this.createdAt,
            updatedAt: updatedAt ?? this.updatedAt,
            v: v ?? this.v,
        );

    factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: (json["_id"] ?? "").toString(),
        video: json["video"],
        ads: json["ads"] is List
            ? List<Ad>.from((json["ads"] as List).map((x) => Ad.fromJson(x)))
            : <Ad>[],
        status: json["status"] ?? true,
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"].toString())
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"].toString())
            : null,
        v: json["__v"] ?? 0,
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "video": video,
        "ads": List<dynamic>.from(ads.map((x) => x.toJson())),
        "status": status,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
    };
}

class Ad {
    final String image;
    final String link;
    final String id;

    Ad({
        required this.image,
        required this.link,
        required this.id,
    });

    Ad copyWith({
        String? image,
        String? link,
        String? id,
    }) => 
        Ad(
            image: image ?? this.image,
            link: link ?? this.link,
            id: id ?? this.id,
        );

    factory Ad.fromRawJson(String str) => Ad.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Ad.fromJson(Map<String, dynamic> json) => Ad(
        image: (json["image"] ?? "").toString(),
        link: (json["link"] ?? "").toString(),
        id: (json["_id"] ?? "").toString(),
    );

    Map<String, dynamic> toJson() => {
        "image": image,
        "link": link,
        "_id": id,
    };
}
