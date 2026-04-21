import 'package:dio/dio.dart';
import 'package:nadi_user_app/core/network/dio_client.dart';
import 'package:nadi_user_app/core/utils/logger.dart';

class FamilyMembersManageService {
  final _dio = DioClient.dio;

  Future<List<Map<String, dynamic>>> listFamilyMembers() async {
    try {
      final response = await _dio.get('points/family-members');
      final data = response.data['data'];
      if (data is List) {
        return data.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } on DioException catch (e) {
      final errmsg = e.response?.data?['message'] ?? 'Failed to load family members';
      throw errmsg.toString();
    }
  }
 /// 🔹 2. Verified members + points
Future<List<Map<String, dynamic>>> listVerifiedFamilyMembers() async {
  try {
    AppLogger.info("📡 Calling API: points/family-members-verified");

    final response = await _dio.post('points/family-members-verified');

    AppLogger.info("✅ API Status Code: ${response.statusCode}");
    AppLogger.info("📦 Full Response: ${response.data}");

    final data = response.data['data'];

    if (data is List) {
      AppLogger.info("👨‍👩‍👧‍👦 Members Count: ${data.length}");

      final result = data
          .map<Map<String, dynamic>>(
              (e) => Map<String, dynamic>.from(e as Map))
          .toList();

      /// 🔍 Optional: log each member
      for (var m in result) {
        AppLogger.info(
          "➡️ Member: ${m['basicInfo']?['fullName']} | Points: ${m['points']}",
        );
      }

      return result;
    }

    AppLogger.warn("⚠️ Data is not a List");
    return [];
  } on DioException catch (e) {
    AppLogger.error("❌ Dio Error: ${e.message}");
    AppLogger.error("❌ Response: ${e.response?.data}");

    final errmsg = e.response?.data?['message'] ??
        'Failed to load verified family members';

    throw errmsg.toString();
  } catch (e) {
    AppLogger.error("❌ Unexpected Error: $e");
    rethrow;
  }
}

  Future<void> removeFamilyMember(String memberId) async {
    try {
      await _dio.post(
        'points/remove-family-member',
        data: {'memberId': memberId},
      );
    } on DioException catch (e) {
      final errmsg = e.response?.data?['message'] ?? 'Failed to remove family member';
      throw errmsg.toString();
    }
  }
}
