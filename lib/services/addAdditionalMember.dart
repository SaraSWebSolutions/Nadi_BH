import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:nadi_user_app/core/network/dio_client.dart';
import 'package:nadi_user_app/core/utils/logger.dart';

class AddAdditionalMember {
  final _dio = DioClient.dio;

  Future<Map<String, dynamic>> addAdditionalMember({
    required Map<String, dynamic> body,
  }) async {
    try {
      ///  LOG REQUEST BODY
      AppLogger.info("📤 REQUEST BODY:\n${jsonEncode(body)}");

      final response = await _dio.post(
        "user-account/add-additional-members",
        data: body,
      );

      ///  LOG RESPONSE
      AppLogger.success("✅ RESPONSE: ${jsonEncode(response.data)}");

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      AppLogger.error("❌ STATUS: ${e.response?.statusCode}");
      AppLogger.error("❌ ERROR: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? "API Error");
    }
  }
}
