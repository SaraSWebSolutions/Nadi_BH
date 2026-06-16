import 'package:dio/dio.dart';
import 'package:nadi_user_app/core/network/dio_client.dart';
import 'package:nadi_user_app/core/utils/logger.dart';
import 'dart:developer'; // for log()
import 'dart:convert'; // for pretty JSON
import 'package:flutter/foundation.dart'; // for kDebugMode

class ProfileService {
  final _dio = DioClient.dio;

  Future<Map<String, dynamic>?> profileData({required String userId}) async {
    try {
      final response = await _dio.post(
        "user-account/profile",
        data: {"userId": userId},
      );
      print("========== PROFILE API RESPONSE ==========");
      print("STATUS CODE => ${response.statusCode}");
      print("RESPONSE => ${response.data}");
      print("=========================================");
      if (kDebugMode) {
        log(
          "📥 RESPONSE DATA:\n${const JsonEncoder.withIndent('  ').convert(response.data)}",
          name: "PROFILE_API",
        );
      }

      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }

      return null;
    } on DioException catch (e) {
      log("❌ STATUS: ${e.response?.statusCode}", name: "PROFILE_API");
      log("❌ ERROR: ${e.response?.data}", name: "PROFILE_API");

      AppLogger.error("ProfileData DioError: ${e.response?.statusCode}");
      AppLogger.error("Message: ${e.response?.data}");
      return null;
    } catch (e) {
      log("❌ UNKNOWN ERROR: $e", name: "PROFILE_API");
      AppLogger.error("ProfileData Error: $e");
      return null;
    }
  }

  // Edit Profile
  Future<dynamic> editProfile({required FormData formData}) async {
    final response = await _dio.post(
      "user-account/profile-update",
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.data;
  }
}
