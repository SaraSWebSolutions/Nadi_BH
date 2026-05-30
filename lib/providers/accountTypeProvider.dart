import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadi_user_app/preferences/preferences.dart';

final accountTypeProvider = FutureProvider<String?>((ref) async {
  return await AppPreferences.getaccounttype();
});
