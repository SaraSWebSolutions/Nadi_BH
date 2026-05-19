import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/providers/stream_unread_provider.dart';

final totalUnreadProvider = Provider<int>((ref) {
  final asyncMap = ref.watch(streamUnreadCountsProvider);

  return asyncMap.when(
    data: (map) => map.values.fold(0, (sum, c) => sum + c),
    loading: () => 0,
    error: (_, __) => 0,
  );
});