import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/services/family_members_manage_service.dart';

final familyMembersManageServiceProvider =
    Provider<FamilyMembersManageService>((ref) => FamilyMembersManageService());

final familyMembersListProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(familyMembersManageServiceProvider);
  return service.listFamilyMembers();
});
final familyMembersVerifiedProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(familyMembersManageServiceProvider);
  return service.listVerifiedFamilyMembers();
});
