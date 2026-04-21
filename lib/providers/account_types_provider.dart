import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/services/auth_service.dart';

const String individualAccountTypeId = "693175af976ca992c877f99d";
const String familyAccountTypeId = "693175a0976ca992c877f99b";

class AccountTypeAvailability {
  final bool individualEnabled;
  final bool familyEnabled;

  const AccountTypeAvailability({
    required this.individualEnabled,
    required this.familyEnabled,
  });
}

bool _isEnabled(Map<String, dynamic> entry) {
  final dynamic active = entry['isActive'] ?? entry['isEnabled'] ?? entry['active'];
  if (active is bool) return active;
  if (active is String) return active.toLowerCase() == 'true';
  if (active is num) return active != 0;
  // If the admin never flags it, default to enabled.
  return true;
}

bool _matchesId(Map<String, dynamic> entry, String id) {
  final candidate = entry['_id'] ?? entry['id'];
  return candidate?.toString() == id;
}

bool _matchesName(Map<String, dynamic> entry, String name) {
  final raw = (entry['name'] ?? entry['type'] ?? entry['code'] ?? '')
      .toString()
      .toLowerCase();
  return raw.contains(name.toLowerCase());
}

final accountTypeAvailabilityProvider =
    FutureProvider<AccountTypeAvailability>((ref) async {
  final service = AuthService();
  final list = await service.acountype();

  if (list.isEmpty) {
    // Fail open: if we can't reach the endpoint, show both as before.
    return const AccountTypeAvailability(
      individualEnabled: true,
      familyEnabled: true,
    );
  }

  bool individualEnabled = true;
  bool familyEnabled = true;

  final individualEntry = list.firstWhere(
    (e) => _matchesId(e, individualAccountTypeId) || _matchesName(e, 'individual'),
    orElse: () => <String, dynamic>{},
  );
  if (individualEntry.isNotEmpty) {
    individualEnabled = _isEnabled(individualEntry);
  }

  final familyEntry = list.firstWhere(
    (e) => _matchesId(e, familyAccountTypeId) || _matchesName(e, 'family'),
    orElse: () => <String, dynamic>{},
  );
  if (familyEntry.isNotEmpty) {
    familyEnabled = _isEnabled(familyEntry);
  }

  return AccountTypeAvailability(
    individualEnabled: individualEnabled,
    familyEnabled: familyEnabled,
  );
});
