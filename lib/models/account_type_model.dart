class AccountType {
  final String id;
  final String nameEn;
  final String nameAr;
  final String type;

  AccountType({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.type,
  });

  factory AccountType.fromJson(Map<String, dynamic> json) {
    return AccountType(
      id: json['_id']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}

class AccountTypeResponse {
  final List<AccountType> data;

  AccountTypeResponse({required this.data});

  factory AccountTypeResponse.fromJson(Map<String, dynamic> json) {
    return AccountTypeResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => AccountType.fromJson(e))
          .toList(),
    );
  }
}
