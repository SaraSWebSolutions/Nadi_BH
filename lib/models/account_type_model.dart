class AccountType {
  final String id;
  final String name;
  final String type;

  AccountType({required this.id, required this.name, required this.type});

  factory AccountType.fromJson(Map<String, dynamic> json) {
    return AccountType(id: json['_id'], name: json['name'], type: json['type']);
  }
}

class AccountTypeResponse {
  final List<AccountType> data;

  AccountTypeResponse({required this.data});

  factory AccountTypeResponse.fromJson(Map<String, dynamic> json) {
    return AccountTypeResponse(
      data: (json['data'] as List).map((e) => AccountType.fromJson(e)).toList(),
    );
  }
}
