
import 'package:dio/dio.dart';
import 'package:nadi_user_app/core/auth/force_logout.dart';
import 'package:nadi_user_app/preferences/preferences.dart';
import 'package:flutter/foundation.dart'; // ✅ add this

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://srv1252888.hstgr.cloud/api/",
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AppPreferences.getToken();
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          /// ✅ Add Language automatically
          // final prefs = await SharedPreferences.getInstance();
          // final lang = prefs.getString('lang') ?? 'en';

          // options.queryParameters['lang'] = lang;
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Retry logic for 429 Too Many Requests
          if (error.response?.statusCode == 429) {
            int retryCount = error.requestOptions.extra['retryCount'] ?? 0;
            if (retryCount < 3) {
              // Exponential backoff: 2^retryCount seconds
              final delay = Duration(seconds: 1 << retryCount);
              await Future.delayed(delay);
              final options = error.requestOptions;
              options.extra['retryCount'] = retryCount + 1;
              try {
                final response = await dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }

          // Auto-logout when an authenticated request returns disabled/rejected
          // or an auth failure. We skip auth-entry endpoints so login errors
          // keep their inline handling.
          final path = error.requestOptions.path.toLowerCase();
          final isAuthEntryPath = path.contains('signin') ||
              path.contains('login') ||
              path.contains('send-signin-otp') ||
              path.contains('signin-otp') ||
              path.contains('forgot-password') ||
              path.contains('reset-password') ||
              path.contains('user-account/signin');

          if (!isAuthEntryPath) {
  final status = error.response?.statusCode;

  final rawMessage =
      error.response?.data is Map ? error.response?.data['message'] : null;

  final message = rawMessage?.toString().toLowerCase() ?? '';

  final path = error.requestOptions.path.toLowerCase();

  ForceLogoutReason? reason;

  /// ✅ Disabled / Rejected (highest priority)
  if (message.contains('disabled')) {
    reason = ForceLogoutReason.disabled;
  } else if (message.contains('reject')) {
    reason = ForceLogoutReason.rejected;
  }

  /// ✅ Unauthorized (ONLY real cases)
 else if (status == 401 || status == 403) {
  final token = await AppPreferences.getToken();

  final isTokenExpired =
      message.contains('token') ||
      message.contains('expired') ||
      message.contains('unauthorized');

  // 🔥 ONLY logout if backend clearly says token issue
  if (token.isNotEmpty && isTokenExpired) {
    reason = ForceLogoutReason.unauthorized;
  } else {
    debugPrint("⚠️ Ignoring 401 (not real auth issue)");
  }
}

  /// ✅ Trigger logout safely
 if (reason != null) {
  final token = await AppPreferences.getToken();

  /// ✅ Allow rejected & disabled WITHOUT token
  if (reason == ForceLogoutReason.rejected ||
      reason == ForceLogoutReason.disabled) {
    debugPrint("🚨 Force logout (no token needed): $reason");
    await ForceLogout.trigger(reason);
  }

  /// ✅ Unauthorized still needs token
  else if (token.isNotEmpty) {
    debugPrint("🚨 Force logout (unauthorized): $reason");
    await ForceLogout.trigger(reason);
  } else {
    debugPrint("⚠️ Skip logout → token empty");
  }
}
}

          return handler.next(error);
        },
      ),
    );
}

// onRequest -Runs before every API
// options.headers[...] -  Adds header automatically 


class ImageBaseUrl {
  static const baseUrl = "https://srv1252888.hstgr.cloud/uploads";
}

class ImageAssetUrl{
  static const baseUrl = "https://srv1252888.hstgr.cloud";
}
 