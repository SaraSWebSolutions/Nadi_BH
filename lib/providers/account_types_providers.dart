import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/account_type_model.dart';
import '../core/network/dio_client.dart';

final accountTypesProvider = FutureProvider.autoDispose<AccountTypeResponse>((
  ref,
) async {
  final dio = DioClient.dio;

  final response = await dio.get('account-type/');
  print("🔥 RAW RESPONSE: ${response.data}");

  return AccountTypeResponse.fromJson(response.data);
});
