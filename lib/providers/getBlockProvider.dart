import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/services/addressService.dart';

final addressServiceProvider = Provider<AddressService>((ref) {
  return AddressService();
});

final getBlockProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final service = ref.read(addressServiceProvider);
  return await service.getBlocks();
});
